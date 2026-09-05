$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\')
# Named $homeDir, not $home: $home is a reserved PowerShell automatic
# variable (the user's profile directory) and is read-only in this scope -
# assigning to it throws "Cannot overwrite variable HOME because it is
# read-only or constant" (reproduced empirically 2026-09-05 on real Windows,
# via launch-north-forge.bat once its own missing HERMES_CMD assignment was
# restored - this script had never actually been reached before that fix).
$homeDir = Join-Path $repo '.hermes-home'

function Stop-DriveJob([string]$Reason) {
    $message = "North Forge unattended job stopped: $Reason"
    [Console]::Error.WriteLine($message)
    $logs = Join-Path $homeDir 'logs'
    if (Test-Path -LiteralPath $logs -PathType Container) {
        Add-Content -LiteralPath (Join-Path $logs 'north-forge-gateway.log') `
            -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [ERROR] [gateway-wrapper]: $message"
    }
    exit 72
}

if (-not (Test-Path -LiteralPath (Join-Path $repo '.hermes.template.md') -PathType Leaf)) {
    Stop-DriveJob 'the removable repository is unavailable'
}
if (-not (Test-Path -LiteralPath $homeDir -PathType Container)) {
    Stop-DriveJob 'the drive-local .hermes-home is unavailable'
}

$candidates = @(
    (Join-Path $homeDir 'hermes-agent\venv\Scripts\hermes.exe'),
    (Join-Path $homeDir 'hermes-agent\.venv\Scripts\hermes.exe'),
    (Join-Path $homeDir 'venv\Scripts\hermes.exe'),
    (Join-Path $homeDir 'Scripts\hermes.exe')
)
$hermes = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $hermes) { Stop-DriveJob 'the drive-local Hermes executable is unavailable' }

$env:HERMES_HOME = $homeDir
Set-Location -LiteralPath $repo
& $hermes @args
exit $LASTEXITCODE
