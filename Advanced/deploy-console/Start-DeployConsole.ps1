<#
.SYNOPSIS
  Local web console for Zero-Touch-Deploy.ps1. Binds 127.0.0.1 only.
#>
[CmdletBinding()]
param(
    [int]$Port = 8765
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$UiFile = Join-Path $Root 'ui\index.html'
$Engine = Join-Path $Root 'Zero-Touch-Deploy.ps1'

if (-not (Test-Path -LiteralPath $UiFile)) { throw "Missing $UiFile" }
if (-not (Test-Path -LiteralPath $Engine)) { throw "Missing $Engine" }

function Get-UsbDrives {
    $list = @()
    $vols = @(Get-CimInstance Win32_Volume -Filter "DriveType=2" -ErrorAction SilentlyContinue)
    foreach ($v in $vols) {
        if (-not $v.DriveLetter) { continue }
        $letter = $v.DriveLetter.TrimEnd(':').ToUpperInvariant()
        if ($letter -eq 'C' -or $letter -eq $env:SystemDrive.TrimEnd(':').ToUpperInvariant()) { continue }
        $cap = 0
        if ($v.Capacity) { $cap = [math]::Round($v.Capacity / 1GB, 2) }
        $list += [pscustomobject]@{
            letter = $letter
            label  = [string]$v.Label
            gb     = $cap
            fs     = [string]$v.FileSystem
        }
    }
    return $list
}

function Get-Prereq {
    $git = [bool](Get-Command git -ErrorAction SilentlyContinue)
    $gh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
    $ghUser = ''
    $ghOk = $false
    if ($gh) {
        $prev = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $ghUser = (gh api user --jq .login 2>$null)
            if ($LASTEXITCODE -eq 0 -and $ghUser) { $ghOk = $true }
        }
        finally { $ErrorActionPreference = $prev }
    }
    return [pscustomobject]@{
        git       = $git
        gh        = $gh
        ghUser    = [string]$ghUser
        ghAuthed  = $ghOk
        engine    = (Test-Path -LiteralPath $Engine)
    }
}

function Send-Json($Res, $Obj, [int]$Status = 200) {
    $json = $Obj | ConvertTo-Json -Depth 6 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $Res.StatusCode = $Status
    $Res.ContentType = 'application/json; charset=utf-8'
    $Res.ContentLength64 = $bytes.Length
    $Res.OutputStream.Write($bytes, 0, $bytes.Length)
    $Res.OutputStream.Close()
}

function Send-Text($Res, [string]$Body, [string]$Type = 'text/plain; charset=utf-8', [int]$Status = 200) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Body)
    $Res.StatusCode = $Status
    $Res.ContentType = $Type
    $Res.ContentLength64 = $bytes.Length
    $Res.OutputStream.Write($bytes, 0, $bytes.Length)
    $Res.OutputStream.Close()
}

function Read-Body($Req) {
    if (-not $Req.HasEntityBody) { return '' }
    $reader = New-Object IO.StreamReader($Req.InputStream, $Req.ContentEncoding)
    try { return $reader.ReadToEnd() }
    finally { $reader.Close() }
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://127.0.0.1:$Port/"
$listener.Prefixes.Add($prefix)
try {
    $listener.Start()
}
catch {
    throw @"
Could not open the local web page at $prefix
$($_.Exception.Message)

Fix: close any old Deploy Console window, or right-click Launch-Deploy-Console.cmd and Run as administrator.
"@
}

Write-Host ""
Write-Host "North Forge Deploy Console" -ForegroundColor Cyan
Write-Host "  $prefix" -ForegroundColor Green
Write-Host "  Listening on localhost only. Close this window to stop."
Write-Host ""
Start-Process $prefix

$script:DeployLock = $false

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $path = $req.Url.AbsolutePath.TrimEnd('/')
        if ([string]::IsNullOrEmpty($path)) { $path = '/' }

        try {
            if ($req.HttpMethod -eq 'GET' -and ($path -eq '/' -or $path -eq '/index.html')) {
                $html = [IO.File]::ReadAllText($UiFile)
                Send-Text $res $html 'text/html; charset=utf-8'
                continue
            }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/drives') {
                Send-Json $res @{ drives = @(Get-UsbDrives) }
                continue
            }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/status') {
                Send-Json $res (Get-Prereq)
                continue
            }
            if ($req.HttpMethod -eq 'POST' -and $path -eq '/api/deploy') {
                if ($script:DeployLock) {
                    Send-Json $res @{ ok = $false; error = 'A deploy is already running.' } 409
                    continue
                }
                $raw = Read-Body $req
                $body = $raw | ConvertFrom-Json
                $letter = [string]$body.letter
                $confirm = [string]$body.confirm
                $tier = [string]$body.tier
                $pass = [string]$body.passcode
                $skipFormat = [bool]$body.skipFormat
                $label = [string]$body.label
                if ($letter -notmatch '^[A-Za-z]$') {
                    Send-Json $res @{ ok = $false; error = 'Pick a USB drive letter.' } 400
                    continue
                }
                if ($label -and ($label.Length -gt 32 -or $label -match '[\\/:*?"<>|]')) {
                    Send-Json $res @{ ok = $false; error = 'Volume label must be 32 characters or fewer, with none of \ / : * ? " < > |' } 400
                    continue
                }
                if (-not $skipFormat -and $confirm -cne 'FORMAT') {
                    Send-Json $res @{ ok = $false; error = 'Type FORMAT in capitals to allow wipe.' } 400
                    continue
                }
                if ($tier -notin @('full', 'basic')) { $tier = 'basic' }
                if ([string]::IsNullOrWhiteSpace($pass) -or $pass.Length -lt 6) {
                    Send-Json $res @{ ok = $false; error = 'Admin passcode must be at least 6 characters.' } 400
                    continue
                }
                $prereq = Get-Prereq
                if (-not $prereq.git) {
                    Send-Json $res @{ ok = $false; error = 'Git is not installed. Install Git for Windows, then retry.' } 400
                    continue
                }
                if (-not $prereq.ghAuthed) {
                    Send-Json $res @{ ok = $false; error = 'GitHub is not signed in. On this PC open a terminal and run: gh auth login' } 400
                    continue
                }
                $script:DeployLock = $true
                $logDir = Join-Path $env:TEMP 'north-forge-deploy'
                New-Item -ItemType Directory -Force -Path $logDir | Out-Null
                $logFile = Join-Path $logDir ("deploy-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".log")
                $argList = @(
                    '-NoProfile', '-ExecutionPolicy', 'Bypass',
                    '-File', $Engine,
                    '-DriveLetter', $letter.ToUpperInvariant(),
                    '-Tier', $tier
                )
                if ($skipFormat) { $argList += '-SkipFormat' }
                else { $argList += @('-ConfirmFormat', 'FORMAT') }
                if ($label) { $argList += @('-Label', $label) }
                try {
                    $prevPass = $env:NF_ADMIN_PASSCODE
                    $env:NF_ADMIN_PASSCODE = $pass
                    $p = Start-Process -FilePath 'powershell.exe' -ArgumentList $argList `
                        -RedirectStandardOutput $logFile `
                        -RedirectStandardError "$logFile.err" `
                        -PassThru -WindowStyle Hidden
                    Send-Json $res @{ ok = $true; pid = $p.Id; logFile = $logFile }
                }
                catch {
                    $script:DeployLock = $false
                    Send-Json $res @{ ok = $false; error = "Could not start deploy: $($_.Exception.Message)" } 500
                }
                finally {
                    if ($null -eq $prevPass) { Remove-Item Env:NF_ADMIN_PASSCODE -ErrorAction SilentlyContinue }
                    else { $env:NF_ADMIN_PASSCODE = $prevPass }
                }
                continue
            }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/log') {
                $logFile = [string]$req.QueryString['file']
                if (-not $logFile -or $logFile -notmatch 'north-forge-deploy' -or -not (Test-Path -LiteralPath $logFile)) {
                    Send-Json $res @{ text = ''; running = $false }
                    continue
                }
                $text = [IO.File]::ReadAllText($logFile)
                $errFile = "$logFile.err"
                if (Test-Path -LiteralPath $errFile) {
                    $err = [IO.File]::ReadAllText($errFile)
                    if ($err) { $text += "`n" + $err }
                }
                $running = $false
                $pidQ = $req.QueryString['pid']
                if ($pidQ) {
                    $proc = Get-Process -Id ([int]$pidQ) -ErrorAction SilentlyContinue
                    $running = [bool]$proc
                    if (-not $running) { $script:DeployLock = $false }
                }
                Send-Json $res @{ text = $text; running = $running }
                continue
            }
            Send-Text $res 'not found' 'text/plain' 404
        }
        catch {
            try { Send-Json $res @{ ok = $false; error = $_.Exception.Message } 500 } catch {}
        }
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
