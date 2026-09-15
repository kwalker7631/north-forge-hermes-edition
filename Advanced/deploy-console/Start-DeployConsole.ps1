<#
.SYNOPSIS
  Local web console for Zero-Touch-Deploy.ps1. Binds 127.0.0.1 only.
  Lists removable volumes AND raw/unpartitioned USB disks (no letter).
#>
[CmdletBinding()]
param([int]$Port = 8765)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$UiFile = Join-Path $Root 'ui\index.html'
$Engine = Join-Path $Root 'Zero-Touch-Deploy.ps1'
$LogDir = Join-Path $env:TEMP 'north-forge-deploy'
if (-not (Test-Path -LiteralPath $UiFile)) { throw "Missing $UiFile" }
if (-not (Test-Path -LiteralPath $Engine)) { throw "Missing $Engine" }
function Write-ConsoleLog([string]$Msg) {
    try {
        New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
        Add-Content -LiteralPath (Join-Path $LogDir 'console.log') -Value (('{0} | {1}' -f (Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'), $Msg)) -Encoding UTF8
    } catch { }
}
function Test-IsSystemLetter([string]$Letter) {
    if (-not $Letter) { return $false }
    $sys = $env:SystemDrive.TrimEnd(':').ToUpperInvariant()
    return ($Letter.ToUpperInvariant() -eq 'C' -or $Letter.ToUpperInvariant() -eq $sys)
}
function Get-UsbDrives {
    $list = New-Object System.Collections.Generic.List[object]
    Write-ConsoleLog 'drive-scan start'
    $vols = @(); try { $vols = @(Get-CimInstance Win32_Volume -ErrorAction SilentlyContinue) } catch { Write-ConsoleLog ('Win32_Volume failed: ' + $_.Exception.Message) }
    foreach ($v in $vols) {
        $letter = ''; if ($v.DriveLetter) { $letter = $v.DriveLetter.TrimEnd(':').ToUpperInvariant() }
        $dt = 0; try { $dt = [int]$v.DriveType } catch { }
        if ($dt -ne 2) { continue }
        if (-not $letter) { Write-ConsoleLog ('skip volume DriveType=2 no letter ' + $v.DeviceID); continue }
        if (Test-IsSystemLetter $letter) { continue }
        $cap = 0; if ($v.Capacity) { $cap = [math]::Round($v.Capacity / 1GB, 2) }
        $lab = [string]$v.Label
        $list.Add([pscustomobject]@{ letter=$letter; diskNumber=$null; raw=$false; label=$lab; gb=$cap; fs=[string]$v.FileSystem; id=$letter; caption=('{0}:  {1}  {2} GB  {3}' -f $letter, $(if ($lab) {$lab} else {'(no label)'}), $cap, $v.FileSystem) })
        Write-ConsoleLog ('volume {0}: {1} {2}GB {3}' -f $letter, $lab, $cap, $v.FileSystem)
    }
    $disks = @(); try { $disks = @(Get-Disk -ErrorAction SilentlyContinue) } catch { Write-ConsoleLog ('Get-Disk failed: ' + $_.Exception.Message) }
    foreach ($d in $disks) {
        if ($d.IsBoot -or $d.IsSystem -or $d.IsOffline) { continue }
        $bus = [string]$d.BusType
        $usbish = ($bus -eq 'USB' -or $bus -eq 'USBSTOR' -or [string]$d.FriendlyName -match 'USB|Flash|Card|SD ')
        if (-not $usbish) { continue }
        $parts = @(); try { $parts = @(Get-Partition -DiskNumber $d.Number -ErrorAction SilentlyContinue) } catch { }
        $raw = (([string]$d.PartitionStyle -eq 'RAW') -or ($parts.Count -eq 0))
        if (-not $raw) { continue }
        $cap = [math]::Round(($d.Size / 1GB), 2)
        $list.Add([pscustomobject]@{ letter=''; diskNumber=[int]$d.Number; raw=$true; label=''; gb=$cap; fs='RAW'; id=('DISK-' + $d.Number); caption=('RAW Disk {0}  {1} GB  {2}  (no letter - format assigns one)' -f $d.Number, $cap, $d.FriendlyName) })
        Write-ConsoleLog ('raw disk# {0} {1}GB bus={2} style={3}' -f $d.Number, $cap, $bus, $d.PartitionStyle)
    }
    Write-ConsoleLog ('drive-scan done count=' + $list.Count)
    return @($list)
}
function Initialize-RawUsbDisk {
    param([Parameter(Mandatory=$true)][int]$Number)
    Write-ConsoleLog ('initialize raw disk ' + $Number)
    $disk = Get-Disk -Number $Number -ErrorAction Stop
    if ($disk.IsBoot -or $disk.IsSystem) { throw "Disk $Number is a system disk. Refusing." }
    $bus = [string]$disk.BusType
    if ($bus -ne 'USB' -and $bus -ne 'USBSTOR') { throw "Disk $Number bus=$bus is not USB. Refusing." }
    if ($disk.IsOffline) { Set-Disk -Number $Number -IsOffline $false }
    if ($disk.IsReadOnly) { Set-Disk -Number $Number -IsReadOnly $false }
    if ([string]$disk.PartitionStyle -eq 'RAW') { Initialize-Disk -Number $Number -PartitionStyle GPT -Confirm:$false; Write-ConsoleLog ('initialized GPT on disk ' + $Number) }
    $parts = @(Get-Partition -DiskNumber $Number -ErrorAction SilentlyContinue)
    if ($parts.Count -eq 0) { $part = New-Partition -DiskNumber $Number -UseMaximumSize -AssignDriveLetter; Write-ConsoleLog ('created partition letter=' + $part.DriveLetter) }
    else {
        $part = $parts | Where-Object { $_.DriveLetter } | Select-Object -First 1
        if (-not $part) { $part = New-Partition -DiskNumber $Number -UseMaximumSize -AssignDriveLetter }
    }
    $letter = ([string]$part.DriveLetter).TrimEnd(':').ToUpperInvariant()
    if (-not $letter) { throw "Disk $Number partitioned but no letter assigned." }
    Write-ConsoleLog ('raw disk ' + $Number + ' now ' + $letter + ':')
    return $letter
}
function Get-Prereq {
    $git = [bool](Get-Command git -ErrorAction SilentlyContinue)
    $gh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
    $ghUser = ''; $ghOk = $false
    if ($gh) {
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        try { $ghUser = (gh api user --jq .login 2>$null); if ($LASTEXITCODE -eq 0 -and $ghUser) { $ghOk = $true } }
        finally { $ErrorActionPreference = $prev }
    }
    return [pscustomobject]@{ git=$git; gh=$gh; ghUser=[string]$ghUser; ghAuthed=$ghOk; engine=(Test-Path -LiteralPath $Engine); logFile=(Join-Path $LogDir 'console.log') }
}
function Send-Json($Res, $Obj, [int]$Status = 200) {
    $json = $Obj | ConvertTo-Json -Depth 6 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $Res.StatusCode = $Status; $Res.ContentType = 'application/json; charset=utf-8'; $Res.ContentLength64 = $bytes.Length
    $Res.OutputStream.Write($bytes, 0, $bytes.Length); $Res.OutputStream.Close()
}
function Send-Text($Res, [string]$Body, [string]$Type = 'text/plain; charset=utf-8', [int]$Status = 200) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Body)
    $Res.StatusCode = $Status; $Res.ContentType = $Type; $Res.ContentLength64 = $bytes.Length
    $Res.OutputStream.Write($bytes, 0, $bytes.Length); $Res.OutputStream.Close()
}
function Read-Body($Req) {
    if (-not $Req.HasEntityBody) { return '' }
    $reader = New-Object IO.StreamReader($Req.InputStream, $Req.ContentEncoding)
    try { return $reader.ReadToEnd() } finally { $reader.Close() }
}
$listener = New-Object System.Net.HttpListener
$prefix = "http://127.0.0.1:$Port/"
$listener.Prefixes.Add($prefix)
try { $listener.Start() } catch { throw "Could not open $prefix`n$($_.Exception.Message)`nClose the old console or Run as administrator." }
Write-Host ''; Write-Host 'North Forge Deploy Console' -ForegroundColor Cyan
Write-Host ('  ' + $prefix) -ForegroundColor Green
Write-Host '  Localhost only. Close this window to stop.'
Write-Host ('  Scan log: ' + (Join-Path $LogDir 'console.log'))
Start-Process $prefix
Write-ConsoleLog ('console listening ' + $prefix)
$script:DeployLock = $false
try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext(); $req = $ctx.Request; $res = $ctx.Response
        $path = $req.Url.AbsolutePath.TrimEnd('/'); if ([string]::IsNullOrEmpty($path)) { $path = '/' }
        try {
            if ($req.HttpMethod -eq 'GET' -and ($path -eq '/' -or $path -eq '/index.html')) { Send-Text $res ([IO.File]::ReadAllText($UiFile)) 'text/html; charset=utf-8'; continue }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/drives') { Send-Json $res @{ drives = @(Get-UsbDrives); logFile = (Join-Path $LogDir 'console.log') }; continue }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/status') { Send-Json $res (Get-Prereq); continue }
            if ($req.HttpMethod -eq 'POST' -and $path -eq '/api/deploy') {
                if ($script:DeployLock) { Send-Json $res @{ ok = $false; error = 'A deploy is already running.' } 409; continue }
                $body = (Read-Body $req) | ConvertFrom-Json
                $letter = [string]$body.letter; $diskNumber = $body.diskNumber; $confirm = [string]$body.confirm
                $tier = [string]$body.tier; $pass = [string]$body.passcode; $skipFormat = [bool]$body.skipFormat
                $label = [string]$body.label; $browse = [string]$body.browse
                Write-ConsoleLog ('deploy request letter={0} disk={1} browse={2}' -f $letter, $diskNumber, $browse)
                if ($browse) {
                    $b = $browse.Trim().ToUpperInvariant()
                    if ($b -match '^[A-Z]:?$') { $letter = $b.TrimEnd(':') }
                    elseif ($b -match '^(DISK[-\s]?)?(\d+)$') { $diskNumber = [int]$Matches[2]; $letter = '' }
                }
                $hasLetter = ($letter -match '^[A-Za-z]$'); $hasDisk = $false
                try { if ($null -ne $diskNumber -and "$diskNumber" -ne '' -and [int]$diskNumber -ge 0) { $hasDisk = $true; $diskNumber = [int]$diskNumber } } catch { }
                if (-not $hasLetter -and -not $hasDisk) { Write-ConsoleLog 'rejected: no target'; Send-Json $res @{ ok=$false; error='Pick a USB volume or RAW disk, or type a letter / Disk N in Browse.' } 400; continue }
                if ($hasLetter -and (Test-IsSystemLetter $letter)) { Send-Json $res @{ ok=$false; error='System drive is blocked.' } 400; continue }
                if ($label -and ($label.Length -gt 32 -or $label -match '[\\/:*?"<>|]')) { Send-Json $res @{ ok=$false; error='Bad volume label.' } 400; continue }
                if (-not $skipFormat -and $confirm -cne 'FORMAT') { Send-Json $res @{ ok=$false; error='Type FORMAT in capitals to allow wipe.' } 400; continue }
                if ($hasDisk -and $skipFormat) { Send-Json $res @{ ok=$false; error='A RAW disk has no filesystem. Uncheck Skip format.' } 400; continue }
                if ($tier -notin @('full','basic')) { $tier = 'basic' }
                if ([string]::IsNullOrWhiteSpace($pass) -or $pass.Length -lt 6) { Send-Json $res @{ ok=$false; error='Admin passcode must be at least 6 characters.' } 400; continue }
                $prereq = Get-Prereq
                if (-not $prereq.git) { Send-Json $res @{ ok=$false; error='Git is not installed.' } 400; continue }
                if (-not $prereq.ghAuthed) { Send-Json $res @{ ok=$false; error='Run gh auth login on this PC.' } 400; continue }
                if ($hasDisk -and -not $hasLetter) {
                    try { $letter = Initialize-RawUsbDisk -Number $diskNumber; $hasLetter = $true; Write-ConsoleLog ('raw disk promoted to ' + $letter) }
                    catch { Write-ConsoleLog ('raw init failed: ' + $_.Exception.Message); Send-Json $res @{ ok=$false; error=('Could not initialize RAW disk {0}: {1}' -f $diskNumber, $_.Exception.Message) } 500; continue }
                }
                $script:DeployLock = $true
                New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
                $logFile = Join-Path $LogDir ('deploy-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
                $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$Engine,'-DriveLetter',$letter.ToUpperInvariant(),'-Tier',$tier)
                if ($skipFormat) { $argList += '-SkipFormat' } else { $argList += @('-ConfirmFormat','FORMAT') }
                if ($label) { $argList += @('-Label',$label) }
                Write-ConsoleLog ('spawn ' + ($argList -join ' '))
                try {
                    $prevPass = $env:NF_ADMIN_PASSCODE; $env:NF_ADMIN_PASSCODE = $pass
                    $p = Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -RedirectStandardOutput $logFile -RedirectStandardError ($logFile + '.err') -PassThru -WindowStyle Hidden
                    Send-Json $res @{ ok=$true; pid=$p.Id; logFile=$logFile }
                } catch {
                    $script:DeployLock = $false
                    Write-ConsoleLog ('spawn failed: ' + $_.Exception.Message)
                    Send-Json $res @{ ok=$false; error=('Could not start deploy: ' + $_.Exception.Message) } 500
                } finally {
                    if ($null -eq $prevPass) { Remove-Item Env:NF_ADMIN_PASSCODE -ErrorAction SilentlyContinue } else { $env:NF_ADMIN_PASSCODE = $prevPass }
                }
                continue
            }
            if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/log') {
                $logFile = [string]$req.QueryString['file']
                if (-not $logFile -or $logFile -notmatch 'north-forge-deploy' -or -not (Test-Path -LiteralPath $logFile)) { Send-Json $res @{ text=''; running=$false }; continue }
                $text = [IO.File]::ReadAllText($logFile)
                if (Test-Path -LiteralPath ($logFile + '.err')) { $err = [IO.File]::ReadAllText($logFile + '.err'); if ($err) { $text += "`n" + $err } }
                $running = $false; $pidQ = $req.QueryString['pid']
                if ($pidQ) { $proc = Get-Process -Id ([int]$pidQ) -ErrorAction SilentlyContinue; $running = [bool]$proc; if (-not $running) { $script:DeployLock = $false } }
                Send-Json $res @{ text=$text; running=$running }; continue
            }
            Send-Text $res 'not found' 'text/plain' 404
        } catch { Write-ConsoleLog ('request error: ' + $_.Exception.Message); try { Send-Json $res @{ ok=$false; error=$_.Exception.Message } 500 } catch {} }
    }
} finally { $listener.Stop(); $listener.Close(); Write-ConsoleLog 'console stopped' }
