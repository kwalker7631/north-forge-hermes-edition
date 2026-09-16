<#
.SYNOPSIS
  Drive-local Hermes venv + HERMES_HOME. Lives in the Kyocera pack so Zero-Touch
  still works when north-forge-agent (upstream Hermes) has no chassis scripts.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AgentDir
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $AgentDir 'pyproject.toml'))) {
    throw "Not a Hermes checkout: $AgentDir"
}
$leaf = Split-Path -Leaf $AgentDir
$parent = Split-Path -Parent $AgentDir
$dataDir = Join-Path $parent ($leaf + '-data')
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
$env:HERMES_HOME = $dataDir
$installer = Join-Path $AgentDir 'scripts\install.ps1'
Write-Host "==> HERMES_HOME=$dataDir"
Write-Host "==> InstallDir=$AgentDir"
if (-not (Test-Path -LiteralPath $installer)) {
    throw "Missing $installer"
}
# Official installer: uses existing git checkout at -InstallDir, venv under it.
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer `
    -HermesHome $dataDir `
    -InstallDir $AgentDir `
    -SkipComputerUse
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
    throw "scripts\install.ps1 failed (exit $LASTEXITCODE)"
}
$hermes = @(
    (Join-Path $AgentDir 'venv\Scripts\hermes.exe'),
    (Join-Path $dataDir 'hermes-agent\venv\Scripts\hermes.exe'),
    (Join-Path $dataDir 'bin\hermes.exe')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $hermes) {
    throw "Install finished but hermes.exe was not found under $AgentDir or $dataDir"
}
Write-Host "[+] hermes: $hermes"
exit 0
