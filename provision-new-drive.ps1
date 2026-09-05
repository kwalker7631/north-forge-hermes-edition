# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: provision-new-drive.ps1 | Script version: 1.0.1 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
#
# North Forge - safe drive provisioning
#
# Run this from PowerShell on any Windows machine. It finds the right drive,
# refuses to ever touch C:, checks the filesystem is safe to use, then clones
# (or updates) North Forge onto it and launches.
#
# Does NOT assume any specific drive letter - handles D, E, F, G, whatever.

$ErrorActionPreference = "Stop"
Write-Host "== North Forge drive provisioning ==" -ForegroundColor Cyan

$cloneUrl = "https://YOUR_TOKEN_HERE@github.com/kwalker7631/north-forge-hermes-edition.git"
if ($cloneUrl -match "YOUR_TOKEN_HERE") {
    Write-Host ""
    Write-Host "STOP - this is a message for KENNETH, not whoever is running this script:" -ForegroundColor Red
    Write-Host "The clone URL below still has the placeholder token. Before handing this" -ForegroundColor Red
    Write-Host "drive to anyone, edit the line that sets cloneUrl near the top of this file" -ForegroundColor Red
    Write-Host "and replace YOUR_TOKEN_HERE with the real read-only access token (see README.md for how to generate one)." -ForegroundColor Red
    Write-Host "This is a one-time edit you do before distributing - team members should" -ForegroundColor Red
    Write-Host "never see this message." -ForegroundColor Red
    exit 1
}

$systemDrive = $env:SystemDrive.TrimEnd(':')

$volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveLetter -ne $systemDrive }

Write-Host ""
Write-Host "Drives found on this machine (excluding the $systemDrive`: system drive):"
if (-not $volumes) {
    Write-Host "  None found." -ForegroundColor Red
    Write-Host "Plug in your thumb drive, wait a few seconds for Windows to recognize it, and run this again." -ForegroundColor Red
    exit 1
}
$volumes | ForEach-Object {
    $sizeGB = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { "?" }
    Write-Host "  $($_.DriveLetter): - $($_.FileSystem) - ${sizeGB}GB - $($_.FileSystemLabel)"
}
Write-Host ""

$volumeArray = @($volumes)
if ($volumeArray.Count -eq 1) {
    $target = $volumeArray[0].DriveLetter
    Write-Host "Only one drive found besides $systemDrive`: - using ${target}: automatically." -ForegroundColor Green
} else {
    $target = Read-Host "Multiple drives found. Type the LETTER of your thumb drive (just the letter, e.g. E)"
    $target = $target.Trim().Trim(':').ToUpper()
}

# Hard safety gate - never proceed against the system drive, however it was selected
if ($target -eq $systemDrive) {
    Write-Host ""
    Write-Host "STOP: $target`: is this computer's Windows system drive." -ForegroundColor Red
    Write-Host "Refusing to continue - this would damage the Windows installation on this machine." -ForegroundColor Red
    exit 1
}

$vol = Get-Volume -DriveLetter $target -ErrorAction SilentlyContinue
if (-not $vol) {
    Write-Host "ERROR: no drive found at ${target}:. Check the letter and try again." -ForegroundColor Red
    exit 1
}

if ($vol.FileSystem -eq "FAT32" -or $vol.FileSystem -eq "FAT") {
    Write-Host ""
    Write-Host "ERROR: ${target}: is formatted $($vol.FileSystem)." -ForegroundColor Red
    Write-Host "FAT32 caps individual files at 4GB and can cause real problems here - this drive needs exFAT." -ForegroundColor Red
    Write-Host "Fix: right-click ${target}: in File Explorer -> Format -> File system: exFAT -> Start." -ForegroundColor Yellow
    Write-Host "This erases the drive - back up anything on it first. Then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Using ${target}: ($($vol.FileSystem)) - looks good." -ForegroundColor Green

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found - installing..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent
    Write-Host ""
    Write-Host "Git installed. Close this PowerShell window, open a NEW one, and run this script again." -ForegroundColor Yellow
    exit 0
}

$repositoryPath = Join-Path "${target}:\" "north-forge-hermes-edition"

if (Test-Path -LiteralPath $repositoryPath -PathType Container) {
    Write-Host "north-forge-hermes-edition already exists on ${target}: - pulling the latest instead of cloning."
    git -C $repositoryPath pull
    $gitExitCode = $LASTEXITCODE
    if ($gitExitCode -ne 0) {
        Write-Host "ERROR: Provisioning stopped because the existing North Forge copy could not be updated." -ForegroundColor Red
        Write-Host "Review Git's error above, then check network access and repository permissions before trying again." -ForegroundColor Red
        exit $gitExitCode
    }
} else {
    Write-Host "Cloning North Forge onto ${target}:..."
    git clone $cloneUrl $repositoryPath
    $gitExitCode = $LASTEXITCODE
    if ($gitExitCode -ne 0) {
        Write-Host "ERROR: Provisioning stopped because North Forge could not be cloned." -ForegroundColor Red
        Write-Host "Review Git's error above, then check network access and repository permissions before trying again." -ForegroundColor Red
        exit $gitExitCode
    }
}

$launcherPath = Join-Path $repositoryPath "launch-north-forge.bat"
if (-not (Test-Path -LiteralPath $repositoryPath -PathType Container)) {
    Write-Host "ERROR: Provisioning stopped because the expected repository folder was not found: $repositoryPath" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -LiteralPath $launcherPath -PathType Leaf)) {
    Write-Host "ERROR: Provisioning stopped because the North Forge launcher was not found: $launcherPath" -ForegroundColor Red
    Write-Host "The download may be incomplete. Check network access and repository permissions, then try again." -ForegroundColor Red
    exit 1
}

Set-Location -LiteralPath $repositoryPath

Write-Host ""
Write-Host "Starting North Forge..." -ForegroundColor Cyan

# The launcher deliberately sets HERMES_HOME to this repository-local folder.
# This check is informational only: provisioning never reads, changes, or
# deletes a shared-machine or caller-supplied Hermes profile.
$driveHermesHome = Join-Path $repositoryPath ".hermes-home"
if (Test-Path -LiteralPath (Join-Path $driveHermesHome "config.yaml") -PathType Leaf) {
    Write-Host "Using this drive's existing Hermes setup: $driveHermesHome" -ForegroundColor Green
} else {
    Write-Host "First launch on this drive will save its Hermes setup in: $driveHermesHome" -ForegroundColor Cyan
}

& $launcherPath
