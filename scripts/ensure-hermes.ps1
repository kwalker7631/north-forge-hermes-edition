param([Parameter(Mandatory=$true)][string]$RepoRoot)
$ErrorActionPreference = 'Stop'
$homeDir = Join-Path $RepoRoot '.hermes-home'
$stage = Join-Path $RepoRoot '.hermes-install-staging'
$marker = Join-Path $RepoRoot '.hermes-install-incomplete'
$logs = Join-Path $RepoRoot 'install-logs'

function Get-HermesExe([string]$Root) {
    @((Join-Path $Root 'Scripts\hermes.exe'), (Join-Path $Root 'bin\hermes.exe'), (Join-Path $Root 'hermes.exe')) |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}
function Test-HermesHome([string]$Root) {
    return [bool](Get-HermesExe $Root) -and (Test-Path (Join-Path $Root 'hermes-agent\pyproject.toml') -PathType Leaf)
}

if (Test-HermesHome $homeDir) { exit 0 }
if ((Test-Path $homeDir) -or (Test-Path $stage) -or (Test-Path $marker)) {
    Write-Host 'ERROR: This drive has a partial or damaged .hermes-home; North Forge will not use or overwrite it.'
    Write-Host 'Shared Hermes setup on this computer was not touched.'
    Write-Host 'Recovery: rename .hermes-home and .hermes-install-staging for inspection (or remove them), remove .hermes-install-incomplete, then launch again.'
    $existingLogs = @(Get-ChildItem -LiteralPath $logs -Filter 'hermes-install-*.log' -File -ErrorAction SilentlyContinue)
    if ($existingLogs.Count -eq 0) {
        Write-Host 'Diagnostic finding: no Hermes install log exists. The setup stopped before logging began, or the logs were removed.'
    } else { Write-Host "Diagnostic logs: $logs" }
    exit 20
}
Write-Host 'This drive will receive its own independent Hermes engine and dependencies.'
Write-Host 'Installation may take several minutes. Required space varies with browser components.'
try {
    $drive = [IO.DriveInfo]::new([IO.Path]::GetPathRoot((Resolve-Path $RepoRoot).Path))
    Write-Host ('Space check: about {0:N0} MB is currently free. No hard minimum is assumed; confirm the drive has room before continuing.' -f ($drive.AvailableFreeSpace / 1MB))
} catch { Write-Warning "Free space could not be checked reliably. Review the drive's available space before continuing." }
Write-Host 'Help: press Ctrl+C now to cancel safely; launch again when the drive is ready.'

try {
    if ($env:NORTH_FORGE_TEST_UNWRITABLE -eq '1') { throw 'simulated unwritable media' }
    New-Item $logs -ItemType Directory -Force | Out-Null
    $probe = Join-Path $RepoRoot '.hermes-write-test'; Set-Content $probe 'test'; Remove-Item $probe
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $log = Join-Path $logs "hermes-install-$stamp.log"
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [START] Drive-local Hermes setup started."
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [PASS] Drive write check passed."
    New-Item $marker -ItemType File | Out-Null
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [STAGE] Incomplete-install marker created."
    New-Item $stage -ItemType Directory | Out-Null
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [STAGE] Installation staging folder created."
} catch { Write-Host "ERROR: The drive is not writable. Nothing was installed; unlock it or choose writable media and retry."; exit 21 }

$installer = Join-Path $logs "hermes-installer-$stamp.ps1"
$exitCode = 0
try {
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [STAGE] Installer download/copy started."
    if ($env:NORTH_FORGE_INSTALLER_PS1) { Copy-Item -LiteralPath $env:NORTH_FORGE_INSTALLER_PS1 -Destination $installer }
    else { Invoke-WebRequest 'https://hermes-agent.nousresearch.com/install.ps1' -OutFile $installer -UseBasicParsing }
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [PASS] Installer acquired; installer invocation started."
    $oldHome = $env:HERMES_HOME; $env:HERMES_HOME = $stage
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $installer *>> $log
    $exitCode = $LASTEXITCODE
    $env:HERMES_HOME = $oldHome
} catch { $_ | Out-File $log -Append; $exitCode = 1 }
if ($exitCode -ne 0 -or -not (Test-HermesHome $stage)) {
    Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [FAIL] Installer/validation failed (installer exit $exitCode; executable and pyproject check did not both pass)."
    Write-Host "ERROR: Hermes installation failed or did not pass validation (installer exit $exitCode)."
    Write-Host "Shared Hermes setup on this computer was not touched. Diagnostic log: $log"
    Write-Host 'Recovery: remove .hermes-install-staging and .hermes-install-incomplete, then launch again. Keep the log when asking for help.'
    exit 22
}
Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [PASS] Validation passed (drive-local executable and pyproject found)."
try { Move-Item -LiteralPath $stage -Destination $homeDir } catch { Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [ABORT] Validated installation could not be activated."; Write-Host "ERROR: Hermes was validated but could not be activated. See $log; shared host setup was not touched."; exit 23 }
Remove-Item $marker -Force
Add-Content $log "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [COMPLETE] Hermes installation activated and incomplete marker removed."
Write-Host 'Hermes was installed and validated on this drive.'
exit 0
