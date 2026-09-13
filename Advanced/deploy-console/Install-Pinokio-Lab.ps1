<#
.SYNOPSIS
  Admin/lab-only helper to point Pinokio (https://github.com/pinokiocomputer/pinokio)
  at a large, SEPARATE data disk - never the North Forge teammate/handoff drive.

.DESCRIPTION
  Pinokio is deliberately kept off the North Forge stick. See
  Advanced/deploy-console/EXCALIBUR.md ("Do not put on this stick: Pinokio,
  local model zoos, AppData installs, the research archive. Those bury the
  sale.") and Advanced/PINOKIO.md ("Same 32 GB Excalibur stick as North
  Forge: No. PINOKIO_HOME on a data SSD (500 GB-2 TB): the real design.").

  This script does NOT install Pinokio itself - it does not download or
  bundle it. It only (a) validates that a candidate target directory is a
  plausible, safe Pinokio lab disk via scripts/pinokio_lab_target.py, and
  (b) if Pinokio is already installed and its config.json exists, offers to
  point its Home directory at that validated target - the same field the
  Pinokio Settings screen edits. If Pinokio is not installed yet, this
  script prints the official download link and the exact path to paste into
  Pinokio's own first-run Home prompt, and stops there.

  This is intentionally NOT wired into north-forge.cmd, bootstrap-north-forge.ps1,
  nf-setup.ps1, or any teammate-path script. It is only reachable by running
  it directly from this admin console folder.

.PARAMETER TargetPath
  Candidate directory for Pinokio's Home folder, e.g. "D:\PinokioHome".
  Does not need to exist yet.

.PARAMETER MinFreeGB
  Hard floor below which the target is refused outright. Default 200 GB.

.PARAMETER WarnFreeGB
  Below this, the target is allowed but flagged as marginal. Default 500 GB
  (PINOKIO.md's own "real design" number).

.PARAMETER Force
  Skip the interactive "type YES" confirmation before writing config.json.
  Never skips the North-Forge-volume or too-small checks - those are not
  overridable from this script.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [double]$MinFreeGB = 200,
    [double]$WarnFreeGB = 500,
    [switch]$Force
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

Write-Step "Pinokio lab install helper (admin-only, never the teammate stick)"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Validator = Join-Path $RepoRoot "scripts\pinokio_lab_target.py"
if (-not (Test-Path $Validator)) {
    Write-Fail "Could not find scripts\pinokio_lab_target.py under $RepoRoot - is this being run from Advanced\deploy-console\ inside the repo checkout?"
    exit 2
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $python) {
    Write-Fail "No 'python' or 'python3' on PATH - needed to run the target-safety check."
    exit 2
}

Write-Step "Checking '$TargetPath' against the North-Forge-volume and free-space rules"
$json = & $python.Source $Validator $TargetPath --min-free-gb $MinFreeGB --warn-free-gb $WarnFreeGB
$exitCode = $LASTEXITCODE
Write-Host $json
$result = $json | ConvertFrom-Json

switch ($result.verdict) {
    "blocked_north_forge_volume" {
        Write-Fail $result.message
        Write-Fail "This check is not overridable by -Force. Pick a different, separate disk."
        exit 2
    }
    "blocked_too_small" {
        Write-Fail $result.message
        Write-Fail "This check is not overridable by -Force. Pick a bigger disk."
        exit 2
    }
    "blocked_missing_path" {
        Write-Fail $result.message
        exit 2
    }
    "warn_marginal" {
        Write-WarnLine $result.message
    }
    "ok" {
        Write-Ok $result.message
    }
    default {
        Write-Fail "Unrecognized verdict '$($result.verdict)' from pinokio_lab_target.py - stopping."
        exit 2
    }
}

$PinokioConfigPath = Join-Path $env:APPDATA "Pinokio\config.json"
$HomeDir = Join-Path $TargetPath "PinokioHome"

if (-not (Test-Path $PinokioConfigPath)) {
    Write-Step "Pinokio is not installed on this machine yet" "Yellow"
    Write-Host "  1. Download the installer from https://pinokio.computer/"
    Write-Host "  2. Run it, and on Pinokio's first-run Home-folder prompt, enter exactly:"
    Write-Host "       $HomeDir" -ForegroundColor White
    Write-Host "  3. Re-run this script afterward if you want it double-checked."
    Write-Ok "Target validated. Nothing was installed or changed - Pinokio's own installer owns this step."
    exit 0
}

Write-Step "Found an existing Pinokio config at $PinokioConfigPath"
if (-not $Force) {
    Write-Host "About to point Pinokio's Home directory at:"
    Write-Host "  $HomeDir" -ForegroundColor White
    Write-Host "A backup of the current config.json will be made first."
    $answer = Read-Host "Type YES to continue"
    if ($answer -ne "YES") {
        Write-WarnLine "Not confirmed - no changes made."
        exit 1
    }
}

New-Item -ItemType Directory -Path $HomeDir -Force | Out-Null

$backupPath = "$PinokioConfigPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -Path $PinokioConfigPath -Destination $backupPath -Force
Write-Ok "Backed up existing config to $backupPath"

$config = Get-Content $PinokioConfigPath -Raw | ConvertFrom-Json
$config | Add-Member -NotePropertyName "home" -NotePropertyValue $HomeDir -Force
$config | ConvertTo-Json -Depth 20 | Set-Content -Path $PinokioConfigPath -Encoding UTF8

Write-Ok "Pinokio's config.json 'home' field now points at $HomeDir"
Write-WarnLine "Restart Pinokio for this to take effect. If it already had apps installed under the old Home, use Pinokio's own Settings screen to trigger the move - this script only edits the pointer, it does not move existing app data (that path has been flaky per Pinokio's own GitHub issues; letting Pinokio's own UI do the move is the more reliable path)."
