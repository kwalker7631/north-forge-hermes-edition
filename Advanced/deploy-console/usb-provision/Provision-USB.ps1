<#
.SYNOPSIS
  List USB disks only. Demand the disk NUMBER plus FORMAT before anything runs.
  Does not enumerate internal / NVMe / SATA drives unless -AllowLocal.
#>
[CmdletBinding()]
param(
    [switch]$AllowLocal,
    [string]$WorkRoot = ''
)
$ErrorActionPreference = 'Stop'
function Say([string]$M, [string]$C = 'White') { Write-Host $M -ForegroundColor $C }

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run Provision-USB.cmd as administrator.'
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$console = Split-Path -Parent $here
if (-not (Test-Path (Join-Path $console 'Zero-Touch-Deploy.ps1'))) {
    $console = $here
}

Say ''
Say 'NORTH FORGE — USB provision (external disks only)' 'Cyan'
Say 'Public repo is not touched. This is the private pack helper.'
Say ''

$disks = @(Get-Disk | Where-Object {
    if ($AllowLocal) { $true }
    else {
        $_.BusType -in @('USB', 'SD', 'Multi-Media') -or
        $_.FriendlyName -match 'USB|Flash|Card Reader|SanDisk|Kingston|PNY|Samsung Bar|Foxconn'
    }
})
$sys = $null
try { $sys = (Get-Partition | Where-Object { $_.IsSystem -or $_.DriveLetter -eq 'C' } | Select-Object -First 1).DiskNumber } catch { }

if (-not $disks) {
    Say 'No USB disks visible. Plug the stick in. If it is RAW it still has a Disk Number.' 'Yellow'
    Say 'Internal drives are hidden on purpose.'
    exit 1
}

Say ('{0,-6} {1,-10} {2,-12} {3}' -f 'Disk', 'Size', 'Letters', 'Model') 'DarkGray'
foreach ($d in $disks) {
    $letters = (
        Get-Partition -DiskNumber $d.Number -ErrorAction SilentlyContinue |
        Where-Object { $_.DriveLetter } |
        ForEach-Object { "$($_.DriveLetter):" }
    ) -join ','
    if (-not $letters) { $letters = '(none/RAW)' }
    $gb = [math]::Round($d.Size / 1GB, 1)
    $mark = ''
    if ($sys -ne $null -and $d.Number -eq $sys) { $mark = '  << SYSTEM DISK — DO NOT PICK' }
    Say ('{0,-6} {1,-10} {2,-12} {3}{4}' -f $d.Number, "$gb GB", $letters, $d.FriendlyName, $mark)
}

Say ''
Say 'Preferred: the USB you intend to wipe. Running this against a PC disk is possible and a bad idea.' 'Yellow'
$numText = Read-Host 'Type the Disk NUMBER to wipe (example 2)'
$num = 0
if (-not [int]::TryParse($numText, [ref]$num)) { throw 'That was not a number.' }
$chosen = $disks | Where-Object { $_.Number -eq $num }
if (-not $chosen) { throw "Disk $num is not in the USB list. Stopped. Nothing formatted." }
if ($sys -ne $null -and $num -eq $sys) {
    throw "Disk $num looks like the system disk. Stopped. Nothing formatted."
}

$confirm = Read-Host "Type FORMAT to erase Disk $num ($($chosen.FriendlyName), $([math]::Round($chosen.Size/1GB,1)) GB)"
if ($confirm -ne 'FORMAT') { throw 'FORMAT not typed. Stopped. Nothing formatted.' }

$label = Read-Host 'Volume label (BLACK-NORTH / GREGW-NOREX / FIRSTL-NORTH / BASIC-NORTH)'
if (-not $label) { $label = 'BLACK-NORTH' }
$tier = Read-Host 'Tier: full (admin/Excalibur) or basic [full]'
if (-not $tier) { $tier = 'full' }
$pass = Read-Host 'Admin passcode (6+ characters)'
if ([string]::IsNullOrWhiteSpace($pass) -or $pass.Length -lt 6) {
    throw 'Passcode must be at least 6 characters. Stopped. Nothing formatted.'
}

Say ''
Say 'Hand-off to Zero-Touch / Deploy Console for clone + venv + pack.' 'Cyan'
$zt = Join-Path $console 'Zero-Touch-Deploy.ps1'
$launch = Join-Path $console 'Launch-Deploy-Console.cmd'

$part = Get-Partition -DiskNumber $num -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter } | Select-Object -First 1
if (-not $part) {
    Say "Disk $num has no letter. Opening the existing Deploy Console so it can Initialize + assign." 'Yellow'
    if (Test-Path $launch) {
        Start-Process -FilePath $launch -Verb RunAs
        Say 'Pick the same Disk number in the console. Do not pick C:.'
        exit 0
    }
    throw 'No Launch-Deploy-Console.cmd beside this helper. Copy usb-provision next to the console and run again.'
}

$letter = $part.DriveLetter
Say "Using letter ${letter}: on Disk $num"

if (Test-Path $zt) {
    & $zt -DriveLetter $letter -ConfirmFormat FORMAT -Tier $tier -Label $label -Passcode $pass
} elseif (Test-Path $launch) {
    Start-Process -FilePath $launch -Verb RunAs
} else {
    throw 'Unpack this zip next to Zero-Touch-Deploy.ps1 / Launch-Deploy-Console.cmd'
}
