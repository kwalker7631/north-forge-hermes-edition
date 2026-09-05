$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\')
$home = Join-Path $repo '.hermes-home'

function Stop-DriveJob([string]$Reason) {
    $message = "North Forge unattended job stopped: $Reason"
    [Console]::Error.WriteLine($message)
    $logs = Join-Path $home 'logs'
    if (Test-Path -LiteralPath $logs -PathType Container) {
        Add-Content -LiteralPath (Join-Path $logs 'north-forge-gateway.log') `
            -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [ERROR] [gateway-wrapper]: $message"
    }
    exit 72
}

if (-not (Test-Path -LiteralPath (Join-Path $repo '.hermes.template.md') -PathType Leaf)) {
    Stop-DriveJob 'the removable repository is unavailable'
}
if (-not (Test-Path -LiteralPath $home -PathType Container)) {
    Stop-DriveJob 'the drive-local .hermes-home is unavailable'
}

$candidates = @(
    (Join-Path $home 'hermes-agent\venv\Scripts\hermes.exe'),
    (Join-Path $home 'hermes-agent\.venv\Scripts\hermes.exe'),
    (Join-Path $home 'venv\Scripts\hermes.exe'),
    (Join-Path $home 'Scripts\hermes.exe')
)
$hermes = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (-not $hermes) { Stop-DriveJob 'the drive-local Hermes executable is unavailable' }

$env:HERMES_HOME = $home
Set-Location -LiteralPath $repo
& $hermes @args
exit $LASTEXITCODE
