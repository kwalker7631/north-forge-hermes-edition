<#
.SYNOPSIS
  Admin/lab-only helper to cleanly remove a Pinokio install and its Home
  directory. Companion to Install-Pinokio-Lab.ps1.

.DESCRIPTION
  Pinokio has no single first-party "remove everything" command - the
  normal path is the Windows uninstaller plus manually deleting leftover
  AppData folders and the Home directory (see Advanced/PINOKIO.md). This
  script automates that sequence, always shows exactly what it is about to
  delete before deleting it, and never runs without explicit confirmation.

  This is intentionally NOT wired into any teammate-path script - it is
  only reachable by running it directly from this admin console folder.

.PARAMETER RemoveHomeData
  Also delete the Home directory (recorded in Pinokio's config.json) after
  the uninstaller runs. Without this switch, only the launcher app and its
  AppData config are removed; your model/app data under the Home directory
  is left alone.

.PARAMETER Force
  Skip the interactive "type YES" confirmation. Off by default - this is a
  destructive action.
#>
[CmdletBinding()]
param(
    [switch]$RemoveHomeData,
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

Write-Step "Pinokio removal helper (admin/lab-only)"

$PinokioConfigPath = Join-Path $env:APPDATA "Pinokio\config.json"
$PinokioRoamingDir = Join-Path $env:APPDATA "Pinokio"
$PinokioLocalDir = Join-Path $env:LOCALAPPDATA "Programs\Pinokio"

$homeDir = $null
if (Test-Path $PinokioConfigPath) {
    try {
        $config = Get-Content $PinokioConfigPath -Raw | ConvertFrom-Json
        if ($config.home) { $homeDir = $config.home }
    } catch {
        Write-WarnLine "Could not parse $PinokioConfigPath - continuing without a known Home path."
    }
}

Write-Host "Plan:"
$uninstallerPath = $null
$uninstallEntry = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "*Pinokio*" } |
    Select-Object -First 1
if ($uninstallEntry -and $uninstallEntry.UninstallString) {
    $uninstallerPath = $uninstallEntry.UninstallString
    Write-Host "  1. Run uninstaller: $uninstallerPath (silent)"
} else {
    Write-WarnLine "No registered uninstaller found for Pinokio - skipping that step."
}
Write-Host "  2. Remove AppData config folder: $PinokioRoamingDir"
Write-Host "  3. Remove installed-program folder: $PinokioLocalDir"
if ($RemoveHomeData) {
    if ($homeDir) {
        Write-Host "  4. Remove Home data directory: $homeDir" -ForegroundColor Red
    } else {
        Write-WarnLine "-RemoveHomeData was set, but no Home path was found in config.json - nothing extra to remove there."
    }
} else {
    Write-Host "  (Home data directory left alone - pass -RemoveHomeData to also delete it.)"
}

if (-not $Force) {
    $answer = Read-Host "Type YES to proceed with the plan above"
    if ($answer -ne "YES") {
        Write-WarnLine "Not confirmed - nothing was removed."
        exit 1
    }
}

if ($uninstallerPath) {
    Write-Step "Running uninstaller"
    try {
        if ($uninstallerPath -match '^"?(.*?\.exe)"?\s*(.*)$') {
            $exe = $Matches[1]
            $extraArgs = $Matches[2]
            Start-Process -FilePath $exe -ArgumentList ($extraArgs + " /S") -Wait -NoNewWindow
        } else {
            Start-Process -FilePath $uninstallerPath -ArgumentList "/S" -Wait -NoNewWindow
        }
        Write-Ok "Uninstaller finished."
    } catch {
        Write-WarnLine "Uninstaller did not run cleanly ($_) - continuing with folder cleanup anyway."
    }
}

foreach ($dir in @($PinokioRoamingDir, $PinokioLocalDir)) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force
        Write-Ok "Removed $dir"
    }
}

if ($RemoveHomeData -and $homeDir -and (Test-Path $homeDir)) {
    Remove-Item -Path $homeDir -Recurse -Force
    Write-Ok "Removed Home data directory $homeDir"
}

Write-Ok "Pinokio removal complete."
