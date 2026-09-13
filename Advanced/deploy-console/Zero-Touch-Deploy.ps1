<#
.SYNOPSIS
  Zero-touch USB deploy for North Forge + private Kyocera (Hermes) edition.

.PARAMETER ExcludeSkills
  Skill names (as installed under profiles\<Pin>\skills\<name> and
  profiles\<Pin>\skills-source\shared\<name>) to remove after provisioning,
  before "DEPLOYMENT COMPLETE" prints.

  Defaults to  @('pinokio')  when -Tier is 'basic' (locked - a
  teammate-facing drive, which is what Excalibur always is per
  EXCALIBUR.md's own "Tier: Locked. Pin: Kyocera"), and to  @()  when
  -Tier is 'full' (the switcher stays open - the admin/lab case, where
  Pinokio belongs per Advanced/PINOKIO.md). Pass -ExcludeSkills explicitly
  (including  -ExcludeSkills @()  to keep Pinokio on a basic-tier build)
  to override either default.

  WHY THIS EXISTS: the private-edition profile install currently ships
  every skill in the edition's source tree to every drive, with no
  stick-class-aware curation (flagged, not solved at the source, in
  logs\CLAUDE_CODE_LAST_AUDIT.md, 2026-09-12/13). A real Excalibur build
  found `pinokio` installed and chat-reachable on a locked, teammate-facing
  drive - a direct violation of EXCALIBUR.md's own "Do not put on this
  stick: Pinokio." Tying the default to -Tier (rather than requiring a
  flag anyone has to remember) means the common Excalibur case is safe
  by default, using a distinction ("locked" vs "switcher stays open")
  this pipeline already makes for an unrelated reason - it does NOT
  invent a new "stick class" concept. Still not the full policy answer
  (a distribution-level split, or per-skill tier metadata, remain open),
  but the common case no longer depends on someone remembering a flag.
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
    [string[]]$ExcludeSkills = $(if ($Tier -eq 'basic') { @('pinokio') } else { @() })
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

function Get-RemovableVolume([string]$Letter) {
    $vol = Get-CimInstance Win32_Volume -Filter "DriveType=2" |
        Where-Object { $_.DriveLetter -and $_.DriveLetter.TrimEnd(':').ToUpperInvariant() -eq $Letter } |
        Select-Object -First 1
    return $vol
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

if (Test-IsSystemLetter $letter) {
    Write-Fail "Refusing to touch system drive $letter`:"
    exit 1
}

$vol = Get-RemovableVolume $letter
if (-not $vol) {
    Write-Fail "No removable USB volume found at ${letter}:  (Win32_Volume DriveType=2)."
    exit 1
}

$capGb = if ($vol.Capacity) { [math]::Round($vol.Capacity / 1GB, 2) } else { '?' }
Write-Host ("Target : {0}:  label={1}  {2} GB  fs={3}" -f $letter, $vol.Label, $capGb, $vol.FileSystem)

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
    Write-Fail "Admin passcode is required and must be at least 6 characters (-Passcode)."
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
        # Force-checkout, same repair pattern as the agent checkout above - not a
        # plain `pull --ff-only`. A repair pass on a drive where "someone messed
        # where they shouldn't" tampered with tracked files needs to actually fix
        # them, not just refuse to move when history has diverged. This only
        # discards local changes inside private-editions\kyocera\ itself - the
        # sibling venv/data folders (and the admin passcode inside them) are
        # untouched either way, and the private edition's own CLAUDE.md already
        # says only the Blacksmith commits there, so no legitimate uncommitted
        # work should ever be sitting in a deployed drive's checkout to lose.
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

    $bootstrap = Join-Path $agentDir 'scripts\bootstrap-north-forge.ps1'
    if (-not (Test-Path -LiteralPath $bootstrap)) { throw "Missing $bootstrap" }
    Write-Step "Bootstrapping venv + HERMES_HOME (siblings of the checkout)"
    & $bootstrap
    if ($LASTEXITCODE -ne 0) { throw "bootstrap-north-forge.ps1 failed (exit $LASTEXITCODE)." }
    Write-Ok "Bootstrap finished."
}
else {
    Write-Step "Skip clone/bootstrap" 'Yellow'
    if (-not (Test-Path -LiteralPath (Join-Path $agentDir 'scripts\nf-setup.ps1'))) {
        throw "SkipBootstrap set but $agentDir is not a North Forge checkout."
    }
}

$setup = Join-Path $agentDir 'scripts\nf-setup.ps1'
Write-Step "Provisioning tier=$Tier pin=$Pin and setting admin passcode"
& $setup -NonInteractive -Tier $Tier -Pin $Pin -Installed $Pin -SetPasscode -Passcode $Passcode
if ($LASTEXITCODE -ne 0) { throw "nf-setup.ps1 failed (exit $LASTEXITCODE)." }
Write-Ok "Drive provisioned and locked."

if ($ExcludeSkills.Count -gt 0) {
    # Same sibling-folder naming nf-setup.ps1 itself derives DataDir from
    # (parent-of-checkout\<checkout-leaf>-data) - not re-parameterized here,
    # just replicated, so this always agrees with where nf-setup.ps1 actually
    # provisioned the profile.
    $leaf = Split-Path -Leaf $agentDir
    $dataDir = Join-Path (Split-Path -Parent $agentDir) "$leaf-data"
    $profileDir = Join-Path $dataDir "profiles\$Pin"
    Write-Step "Excluding skill(s) from this build: $($ExcludeSkills -join ', ')"
    $excludeScript = Join-Path $PSScriptRoot 'exclude-profile-skills.ps1'
    & $excludeScript -ProfileDir $profileDir -SkillNames $ExcludeSkills
}

$launcher = Join-Path $agentDir 'north-forge.cmd'
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host "Launch: $launcher"
exit 0
