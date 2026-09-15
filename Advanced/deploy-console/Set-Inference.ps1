<#
.SYNOPSIS
  Set the model key using THIS stick's venv hermes.exe — never a bare 'hermes'.
.EXAMPLE
  .\Set-Inference.ps1 -Provider anthropic -Key 'sk-ant-...'
#>
[CmdletBinding()]
param(
    [ValidateSet('anthropic','openai','xai','google')]
    [string]$Provider = 'anthropic',
    [Parameter(Mandatory = $true)][string]$Key,
    [string]$Model = '',
    [string]$DriveRoot = ''
)
$ErrorActionPreference = 'Stop'
if (-not $DriveRoot) {
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $DriveRoot = Split-Path -Qualifier $here
    if (-not $DriveRoot) { $DriveRoot = (Get-Item $here).PSDrive.Root }
}
$DriveRoot = $DriveRoot.TrimEnd('\')
$venvHermes = Join-Path $DriveRoot 'north-forge-agent-venv\Scripts\hermes.exe'
$data = Join-Path $DriveRoot 'north-forge-agent-data'
if (-not (Test-Path -LiteralPath $venvHermes)) {
    throw "Missing $venvHermes — run Start North Forge once so bootstrap can repair the venv, then retry."
}
if (-not (Test-Path -LiteralPath $data)) {
    throw "Missing $data — this stick is not provisioned."
}
$env:HERMES_HOME = $data
$keyName = switch ($Provider) {
    'anthropic' { 'ANTHROPIC_API_KEY' }
    'openai'    { 'OPENAI_API_KEY' }
    'xai'       { 'XAI_API_KEY' }
    'google'    { 'GEMINI_API_KEY' }
}
if (-not $Model) {
    $Model = switch ($Provider) {
        'anthropic' { 'anthropic/claude-sonnet-4' }
        'openai'    { 'openai/gpt-4o' }
        'xai'       { 'xai/grok-4' }
        'google'    { 'google/gemini-2.5-pro' }
    }
}
Write-Host "HERMES_HOME=$data"
Write-Host "hermes=$venvHermes"
& $venvHermes config set $keyName $Key
if ($LASTEXITCODE -ne 0) { throw "config set key failed ($LASTEXITCODE)" }
& $venvHermes config set model $Model
if ($LASTEXITCODE -ne 0) { throw "config set model failed ($LASTEXITCODE)" }
Write-Host "OK. Smoke: & '$venvHermes' -z 'say ready'"
