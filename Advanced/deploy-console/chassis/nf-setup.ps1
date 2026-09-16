<#
.SYNOPSIS
  Pin the Kyocera pack into HERMES_HOME\profiles\<pin> and lock an admin hash.
  Replacement for the missing north-forge-agent scripts\nf-setup.ps1.
#>
[CmdletBinding()]
param(
    [switch]$NonInteractive,
    [ValidateSet('full', 'basic')]
    [string]$Tier = 'full',
    [string]$Pin = 'kyocera',
    [string]$Installed = 'kyocera',
    [switch]$SetPasscode,
    [string]$Passcode = '',
    [string]$AgentDir = ''
)
$ErrorActionPreference = 'Stop'
if (-not $AgentDir) {
    if ($PSScriptRoot -match '\\scripts$') { $AgentDir = Split-Path $PSScriptRoot -Parent }
    else { throw '-AgentDir is required when this script is not in engine\scripts' }
}
if ([string]::IsNullOrWhiteSpace($Passcode)) { $Passcode = $env:NF_ADMIN_PASSCODE }
$leaf = Split-Path -Leaf $AgentDir
$parent = Split-Path -Parent $AgentDir
$dataDir = Join-Path $parent ($leaf + '-data')
$env:HERMES_HOME = $dataDir
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null

$pack = Join-Path $AgentDir "private-editions\$Pin"
if (-not (Test-Path -LiteralPath (Join-Path $pack 'distribution.yaml'))) {
    $pack = Join-Path $AgentDir 'private-editions\kyocera'
}
if (-not (Test-Path -LiteralPath (Join-Path $pack 'distribution.yaml'))) {
    throw "Kyocera pack missing (need private-editions\kyocera\distribution.yaml)"
}

$profileDir = Join-Path $dataDir "profiles\$Pin"
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
$copyNames = @(
    'SOUL.md', 'config.yaml', 'distribution.yaml', '.hermes.template.md',
    'skills', 'dashboard-themes', 'media', 'PHILOSOPHY.md', 'DESK_MODES.md',
    'ALIASES.md', 'LEARNING.md'
)
foreach ($name in $copyNames) {
    $src = Join-Path $pack $name
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $profileDir (Split-Path $name -Leaf)) -Recurse -Force
    }
}
# Hermes also reads SOUL at HERMES_HOME root.
if (Test-Path -LiteralPath (Join-Path $pack 'SOUL.md')) {
    Copy-Item (Join-Path $pack 'SOUL.md') (Join-Path $dataDir 'SOUL.md') -Force
}
Set-Content -LiteralPath (Join-Path $dataDir 'nf-tier.txt') -Value $Tier -Encoding ASCII
Set-Content -LiteralPath (Join-Path $dataDir 'nf-pin.txt') -Value $Pin -Encoding ASCII

if ($SetPasscode) {
    if ([string]::IsNullOrWhiteSpace($Passcode) -or $Passcode.Length -lt 6) {
        throw 'Admin passcode is required and must be at least 6 characters.'
    }
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Passcode))
        $hex = -join ($hash | ForEach-Object { $_.ToString('x2') })
    } finally { $sha.Dispose() }
    Set-Content -LiteralPath (Join-Path $dataDir 'admin.passcode.hash') -Value $hex -Encoding ASCII
}

foreach ($d in @('Docs', 'IMG', 'audio')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $parent $d) | Out-Null
}

$cmdSrc = Join-Path $AgentDir 'north-forge.cmd'
if (-not (Test-Path -LiteralPath $cmdSrc)) {
    $cmdSrc = Join-Path $pack 'Advanced\deploy-console\chassis\north-forge.cmd'
}
if (Test-Path -LiteralPath $cmdSrc) {
    Copy-Item $cmdSrc (Join-Path $AgentDir 'north-forge.cmd') -Force
    Copy-Item $cmdSrc (Join-Path $parent 'Start North Forge.cmd') -Force
}

Write-Host ("[+] Profile {0} at {1} (tier={2})" -f $Pin, $profileDir, $Tier)
exit 0
