<#
.SYNOPSIS
  Zero-touch USB deploy for North Forge + private Kyocera (Hermes) edition.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DriveLetter,
    [string]$ConfirmFormat = '',
    [ValidateSet('full', 'basic')]
    [string]$Tier = 'full',
    [string]$Passcode = '',
    [switch]$SkipFormat,
    [switch]$SkipBootstrap,
    [string]$Label = 'NorthForge',
    [string]$AgentRepoUrl = 'https://github.com/kwalker7631/north-forge-agent.git',
    [string]$EditionRepoUrl = 'https://github.com/kwalker7631/north-forge-hermes-edition.git',
    [string]$Pin = 'kyocera',
    [string[]]$ExcludeSkills = $(if ($Tier -eq 'basic') { @('pinokio') } else { @() }),
    [double]$MinCapacityGb = 8,
    [double]$RecommendedCapacityGb = 32
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step([string]$Msg, [string]$Color = 'Cyan') {
    Write-Host ""
    Write-Host ("==> " + $Msg) -ForegroundColor $Color
}
function Write-Ok([string]$Msg) { Write-Host ("[+] " + $Msg) -ForegroundColor Green }
function Write-WarnLine([string]$Msg) { Write-Host ("[!] " + $Msg) -ForegroundColor Yellow }
function Write-Fail([string]$Msg) { Write-Host ("[x] " + $Msg) -ForegroundColor Red }

function Get-LetterOnly([string]$Raw) {
    $s = ($Raw -replace '\s', '').TrimEnd(':').ToUpperInvariant()
    if ($s.Length -ne 1 -or $s -notmatch '^[A-Z]$') {
        throw "DriveLetter must be a single letter (got '$Raw')."
    }
    return $s
}

function Test-IsSystemLetter([string]$Letter) {
    $sys = $env:SystemDrive.TrimEnd(':').ToUpperInvariant()
    return ($Letter -eq 'C' -or $Letter -eq $sys)
}

function Test-UsbAttachedVolume([string]$Letter) {
    try {
        $part = Get-Partition -DriveLetter $Letter -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $part) { return $false }
        $disk = Get-Disk -Number $part.DiskNumber -ErrorAction SilentlyContinue
        if (-not $disk -or $disk.IsBoot -or $disk.IsSystem) { return $false }
        $bus = [string]$disk.BusType
        if ($bus -eq 'USB' -or $bus -eq 'USBSTOR' -or $bus -eq 'SD' -or $bus -eq 'Multi-Media') { return $true }
        if ([string]$disk.FriendlyName -match 'USB|Flash|Foxconn|Enclosure|SanDisk|Kingston') { return $true }
    } catch { }
    return $false
}

function Get-TargetVolume([string]$Letter) {
    $vol = Get-CimInstance Win32_Volume |
        Where-Object { $_.DriveLetter -and $_.DriveLetter.TrimEnd(':').ToUpperInvariant() -eq $Letter } |
        Select-Object -First 1
    if (-not $vol) { return $null }
    $dt = 0; try { $dt = [int]$vol.DriveType } catch { }
    if ($dt -eq 2) { return $vol }
    if (Test-UsbAttachedVolume $Letter) { return $vol }
    return $null
}

function Test-CommandOnPath([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-LoggedNative {
    param([Parameter(Mandatory = $true)][scriptblock]$Script, [string]$FailMessage)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Script
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            throw "$FailMessage (exit $LASTEXITCODE)"
        }
    }
    finally { $ErrorActionPreference = $prev }
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " NORTH FORGE  ·  ZERO-TOUCH DEPLOY" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$letter = Get-LetterOnly $DriveLetter
$root = "${letter}:\"

if ([string]::IsNullOrWhiteSpace($Passcode)) { $Passcode = [string]$env:NF_ADMIN_PASSCODE }

if (Test-IsSystemLetter $letter) {
    Write-Fail "Refusing to touch system drive $letter`:"
    exit 1
}

$vol = Get-TargetVolume $letter
if (-not $vol) {
    Write-Fail "No USB volume at ${letter}: (need DriveType=2 thumb OR USB-attached disk such as a Foxconn enclosure)."
    exit 1
}

$capGb = if ($vol.Capacity) { [math]::Round($vol.Capacity / 1GB, 2) } else { '?' }
Write-Host ("Target : {0}:  label={1}  {2} GB  fs={3}" -f $letter, $vol.Label, $capGb, $vol.FileSystem)

if ($capGb -is [double]) {
    if ($capGb -lt $MinCapacityGb) {
        Write-Fail ("Target is {0} GB - below the {1} GB floor. Refusing. Pass -MinCapacityGb to override." -f $capGb, $MinCapacityGb)
        exit 1
    } elseif ($capGb -lt $RecommendedCapacityGb) {
        Write-WarnLine ("Target is {0} GB - above the {1} GB floor but below the {2} GB recommend. Continuing." -f $capGb, $MinCapacityGb, $RecommendedCapacityGb)
    }
}

if (-not $SkipFormat) {
    if ($ConfirmFormat -cne 'FORMAT') {
        Write-Fail "Format not confirmed. Pass -ConfirmFormat FORMAT or use -SkipFormat."
        exit 1
    }
}

if (-not (Test-CommandOnPath 'git')) { Write-Fail "git is not on PATH."; exit 1 }
$hasGh = Test-CommandOnPath 'gh'
if (-not $hasGh) { Write-WarnLine "GitHub CLI (gh) not on PATH." }

if ([string]::IsNullOrWhiteSpace($Passcode) -or $Passcode.Length -lt 6) {
    Write-Fail "Admin passcode is required and must be at least 6 characters (-Passcode or NF_ADMIN_PASSCODE)."
    exit 1
}

if (-not $SkipFormat) {
    Write-Step "Formatting ${letter}: as exFAT ($Label) — ALL DATA WILL BE ERASED"
    Format-Volume -DriveLetter $letter -FileSystem exFAT -NewFileSystemLabel $Label -Confirm:$false | Out-Null
    Start-Sleep -Seconds 2
    if (-not (Test-Path -LiteralPath $root)) { Write-Fail "Format finished but ${letter}: is not mounted."; exit 1 }
    Write-Ok "Format complete."
}
else {
    Write-Step "Skip format — using existing ${letter}:" 'Yellow'
    if (-not (Test-Path -LiteralPath $root)) { Write-Fail "${letter}: is not mounted."; exit 1 }
}

$agentDir = Join-Path $root 'north-forge-agent'
$editionDir = Join-Path $agentDir 'private-editions\kyocera'
$chassisDir = Join-Path $PSScriptRoot 'chassis'

function Install-ChassisIntoEngine([string]$Agent, [string]$PackDir) {
    $src = Join-Path $PackDir 'Advanced\deploy-console\chassis'
    if (-not (Test-Path -LiteralPath $src)) { $src = $chassisDir }
    if (-not (Test-Path -LiteralPath $src)) { throw "Chassis scripts missing (expected $src)" }
    $scripts = Join-Path $Agent 'scripts'
    New-Item -ItemType Directory -Force -Path $scripts | Out-Null
    Copy-Item (Join-Path $src 'bootstrap-north-forge.ps1') (Join-Path $scripts 'bootstrap-north-forge.ps1') -Force
    Copy-Item (Join-Path $src 'nf-setup.ps1') (Join-Path $scripts 'nf-setup.ps1') -Force
    Copy-Item (Join-Path $src 'north-forge.cmd') (Join-Path $Agent 'north-forge.cmd') -Force
    if (Test-Path -LiteralPath (Join-Path $src 'install.cmd')) {
        Copy-Item (Join-Path $src 'install.cmd') (Join-Path $scripts 'install.cmd') -Force
    }
}

if (-not $SkipBootstrap) {
    Write-Step "Cloning public engine (shallow) → $agentDir"
    if (Test-Path -LiteralPath (Join-Path $agentDir '.git')) {
        Write-WarnLine "Checkout already present. Fetching latest main (depth 1)."
        Invoke-LoggedNative { git -C $agentDir fetch --depth 1 origin main } "git fetch failed"
        Invoke-LoggedNative { git -C $agentDir checkout --force FETCH_HEAD } "git checkout failed"
    }
    else {
        if (Test-Path -LiteralPath $agentDir) { throw "Folder exists but is not a git checkout: $agentDir" }
        Invoke-LoggedNative { git clone --depth 1 --branch main $AgentRepoUrl $agentDir } "Failed to clone north-forge-agent"
    }
    Write-Ok "Engine checkout ready."

    Write-Step "Cloning private Kyocera edition → private-editions\kyocera"
    New-Item -ItemType Directory -Force -Path (Join-Path $agentDir 'private-editions') | Out-Null
    if (Test-Path -LiteralPath (Join-Path $editionDir '.git')) {
        Write-WarnLine "Private edition already present. Fetching latest main (depth 1) and repairing any local tampering."
        Invoke-LoggedNative { git -C $editionDir fetch --depth 1 origin main } "private edition fetch failed"
        Invoke-LoggedNative { git -C $editionDir checkout --force FETCH_HEAD } "private edition checkout failed"
    }
    else {
        if (Test-Path -LiteralPath $editionDir) { throw "private-editions\kyocera exists but is not a git checkout." }
        $cloneOk = $false
        if ($hasGh) {
            $prev = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                gh repo clone kwalker7631/north-forge-hermes-edition $editionDir
                if ($LASTEXITCODE -eq 0) { $cloneOk = $true }
            }
            finally { $ErrorActionPreference = $prev }
        }
        if (-not $cloneOk) {
            Invoke-LoggedNative { git clone $EditionRepoUrl $editionDir } "Failed to clone north-forge-hermes-edition"
        }
    }

    $manifest = Join-Path $editionDir 'distribution.yaml'
    if (-not (Test-Path -LiteralPath $manifest)) {
        throw "Private edition clone is missing distribution.yaml — aborting before bootstrap."
    }
    Write-Ok "Private edition ready."

    Write-Step "Installing chassis scripts into the engine checkout (upstream Hermes has none)"
    Install-ChassisIntoEngine -Agent $agentDir -PackDir $editionDir
    Write-Ok "Chassis copied (bootstrap-north-forge.ps1, nf-setup.ps1, north-forge.cmd)."

    $bootstrap = Join-Path $agentDir 'scripts\bootstrap-north-forge.ps1'
    Write-Step "Bootstrapping venv + HERMES_HOME (official install.ps1, HERMES_HOME sibling *-data)"
    & $bootstrap -AgentDir $agentDir
    if ($LASTEXITCODE -ne 0) { throw "bootstrap-north-forge.ps1 failed (exit $LASTEXITCODE)." }
    Write-Ok "Bootstrap finished."
}
else {
    Write-Step "Skip clone/bootstrap" 'Yellow'
    if (-not (Test-Path -LiteralPath (Join-Path $agentDir 'scripts\nf-setup.ps1'))) {
        if (Test-Path -LiteralPath $editionDir) { Install-ChassisIntoEngine -Agent $agentDir -PackDir $editionDir }
        else { throw "SkipBootstrap set but chassis is not on $agentDir" }
    }
}

$setup = Join-Path $agentDir 'scripts\nf-setup.ps1'
Write-Step "Provisioning tier=$Tier pin=$Pin and setting admin passcode"
& $setup -NonInteractive -Tier $Tier -Pin $Pin -Installed $Pin -SetPasscode -Passcode $Passcode -AgentDir $agentDir
if ($LASTEXITCODE -ne 0) { throw "nf-setup.ps1 failed (exit $LASTEXITCODE)." }
Write-Ok "Drive provisioned and locked."

if ($ExcludeSkills.Count -gt 0) {
    $leaf = Split-Path -Leaf $agentDir
    $dataDir = Join-Path (Split-Path -Parent $agentDir) "$leaf-data"
    $profileDir = Join-Path $dataDir "profiles\$Pin"
    Write-Step "Excluding skill(s) from this build: $($ExcludeSkills -join ', ')"
    $excludeScript = Join-Path $PSScriptRoot 'exclude-profile-skills.ps1'
    if (Test-Path -LiteralPath $excludeScript) {
        & $excludeScript -ProfileDir $profileDir -SkillNames $ExcludeSkills
    }
}

$launcher = Join-Path $agentDir 'north-forge.cmd'
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "Launch: $launcher"
Write-Host "Or:     $(Join-Path $root 'Start North Forge.cmd')"
exit 0
