<#
.SYNOPSIS
  One look: is THIS stick's hermes the one that will run?
  Safe to run. Does not change PATH unless you pass -FixUserPath.
#>
[CmdletBinding()]
param(
    [string]$DriveRoot = '',
    [switch]$FixUserPath
)
$ErrorActionPreference = 'Stop'
function Say([string]$Msg, [string]$Color = 'White') { Write-Host $Msg -ForegroundColor $Color }

if (-not $DriveRoot) {
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $DriveRoot = (Get-Item $here).PSDrive.Root
}
$DriveRoot = $DriveRoot.TrimEnd('\')
$venvExe = Join-Path $DriveRoot 'north-forge-agent-venv\Scripts\hermes.exe'
$data    = Join-Path $DriveRoot 'north-forge-agent-data'
$cmd     = Join-Path $DriveRoot 'north-forge-agent\north-forge.cmd'

Say ''
Say ('Stick     : ' + $DriveRoot) 'Cyan'
Say ('Start file: ' + $(if (Test-Path $cmd) { 'found  ' + $cmd } else { 'MISSING  (deploy did not finish)' })) $(if (Test-Path $cmd) {'Green'} else {'Red'})
Say ('Stick exe : ' + $(if (Test-Path $venvExe) { 'found  ' + $venvExe } else { 'MISSING  (run Start North Forge once and wait for repair)' })) $(if (Test-Path $venvExe) {'Green'} else {'Red'})
Say ('Data home : ' + $(if (Test-Path $data) { 'found  ' + $data } else { 'MISSING' })) $(if (Test-Path $data) {'Green'} else {'Red'})

$bare = $null
try { $bare = (Get-Command hermes -ErrorAction SilentlyContinue).Source } catch { }
Say ('Typed hermes would run: ' + $(if ($bare) { $bare } else { '(nothing on PATH — that is OK if you use Start North Forge)' }))

$okStart = (Test-Path $venvExe) -and (Test-Path $data)
$same = $false
if ($bare -and (Test-Path $venvExe)) {
    $same = ([IO.Path]::GetFullPath($bare).ToLowerInvariant() -eq [IO.Path]::GetFullPath($venvExe).ToLowerInvariant())
}

Say ''
if ($okStart) {
    Say 'FOR THE PERSON USING THE STICK: double-click Start North Forge. You are fine.' 'Green'
} else {
    Say 'FOR THE PERSON USING THE STICK: Start North Forge is not ready. Hand this window to the admin.' 'Yellow'
}

if ($bare -and -not $same) {
    Say ''
    Say 'WARNING: if someone types the word hermes in a terminal, Windows will run a DIFFERENT program:' 'Yellow'
    Say ('  ' + $bare)
    Say 'not this stick. That does not break Start North Forge. It only bites people who type hermes.'
    Say 'Admin fix (optional): Windows Settings → Environment Variables → System Path →'
    Say ('  move  ' + (Join-Path $DriveRoot 'north-forge-agent-venv\Scripts') + '  to the top.')
    Say 'Or never type hermes. Prefer that.'
}

if ($FixUserPath -and (Test-Path $venvExe)) {
    $scripts = Join-Path $DriveRoot 'north-forge-agent-venv\Scripts'
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $parts = @($scripts) + @($user -split ';' | Where-Object { $_ -and $_.TrimEnd('\') -ne $scripts.TrimEnd('\') })
    [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
    $env:Path = $scripts + ';' + $env:Path
    Say 'User PATH updated for this Windows login. Open a NEW terminal. System PATH was not touched.' 'Green'
}

Say ''
Say 'Key check (does not print the secret):'
if (Test-Path $venvExe) {
    $env:HERMES_HOME = $data
    & $venvExe config show
} else {
    Say 'skipped — no stick hermes.exe yet'
}
