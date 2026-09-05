# Run with: powershell.exe -NoProfile -File .\tests\provision-new-drive.Tests.ps1
# Dependency-free integration coverage for failure handling and drive-local
# Hermes isolation. All homes and repositories are disposable TEMP fixtures.

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceScript = Join-Path $repositoryRoot "provision-new-drive.ps1"
$powerShell = (Get-Process -Id $PID).Path
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("north-forge-provision-test-" + [guid]::NewGuid())

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "TEST FAILED: $Message" }
}

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null
    $testScript = Join-Path $testRoot "provision-new-drive.ps1"
    (Get-Content -LiteralPath $sourceScript -Raw).Replace("YOUR_TOKEN_HERE", "TEST_TOKEN") |
        Set-Content -LiteralPath $testScript

    # Guard both production launchers: each must replace, rather than inherit,
    # HERMES_HOME with the repository-local runtime directory.
    $batchLauncher = Get-Content -LiteralPath (Join-Path $repositoryRoot "launch-north-forge.bat") -Raw
    $shellLauncher = Get-Content -LiteralPath (Join-Path $repositoryRoot "launch-north-forge.sh") -Raw
    Assert-True ($batchLauncher -match 'set "HERMES_HOME=%CD%\\\.hermes-home"') "Windows launcher must target its own .hermes-home"
    Assert-True ($shellLauncher -match 'export HERMES_HOME="\$\(pwd\)/\.hermes-home"') "Mac/Linux launcher must target its own .hermes-home"

    $runner = Join-Path $testRoot "run-scenario.ps1"
    @'
param([string]$ProvisionScript, [string]$DriveRoot, [string]$FakeBin, [string]$SharedHome)
$env:SystemDrive = "C:"
$env:PATH = "$FakeBin;$env:PATH"
$env:HERMES_HOME = $SharedHome
$env:LOCALAPPDATA = Split-Path -Parent $SharedHome
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $DriveRoot | Out-Null
function Get-Volume {
    param([string]$DriveLetter, [object]$ErrorAction)
    [pscustomobject]@{ DriveLetter = "Z"; FileSystem = "exFAT"; Size = 8GB; FileSystemLabel = "TEST" }
}
& $ProvisionScript
'@ | Set-Content -LiteralPath $runner

    # Existing failure checks remain: neither a failed pull nor failed clone may launch.
    $failureBin = New-Item -ItemType Directory -Path (Join-Path $testRoot "failure-bin")
    Set-Content -LiteralPath (Join-Path $failureBin.FullName "git.cmd") -Encoding Ascii -Value "@echo fake git failure 1>&2`r`n@exit /b 23`r`n"
    foreach ($scenario in @("pull", "clone")) {
        $driveRoot = New-Item -ItemType Directory -Path (Join-Path $testRoot $scenario)
        $marker = Join-Path $driveRoot.FullName "launcher-invoked.txt"
        if ($scenario -eq "pull") {
            $repo = New-Item -ItemType Directory -Path (Join-Path $driveRoot.FullName "north-forge-hermes-edition")
            Set-Content -LiteralPath (Join-Path $repo.FullName "launch-north-forge.bat") -Encoding Ascii -Value ('@echo launched>"{0}"' -f $marker)
        }
        & $powerShell -NoProfile -File $runner $testScript $driveRoot.FullName $failureBin.FullName (Join-Path $testRoot "unused-shared-home")
        $exitCode = $LASTEXITCODE
        Assert-True ($exitCode -ne 0) "$scenario failure should exit nonzero"
        Assert-True (-not (Test-Path -LiteralPath $marker)) "$scenario failure must not invoke the launcher"
        Write-Host "PASS: failed $scenario exited $exitCode and did not launch North Forge." -ForegroundColor Green
    }

    # Put byte-sensitive sentinels in a fake caller/shared home. Provision two
    # drives and prove neither run reads its target from or changes this home.
    $sharedHome = New-Item -ItemType Directory -Path (Join-Path $testRoot "shared-home")
    [byte[]]$configBytes = 0, 255, 13, 10, 99, 111, 110, 102, 105, 103
    [byte[]]$envBytes = 115, 101, 99, 114, 101, 116, 61, 0, 254, 10
    [IO.File]::WriteAllBytes((Join-Path $sharedHome.FullName "config.yaml"), $configBytes)
    [IO.File]::WriteAllBytes((Join-Path $sharedHome.FullName ".env"), $envBytes)
    $configHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sharedHome.FullName "config.yaml")).Hash
    $envHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sharedHome.FullName ".env")).Hash

    $successBin = New-Item -ItemType Directory -Path (Join-Path $testRoot "success-bin")
    $fixtureRepo = New-Item -ItemType Directory -Path (Join-Path $testRoot "fixture-repo")
    @'
@echo off
set "HERMES_HOME=%CD%\.hermes-home"
> "%CD%\launcher-hermes-home.txt" echo %HERMES_HOME%
exit /b 0
'@ | Set-Content -LiteralPath (Join-Path $fixtureRepo.FullName "launch-north-forge.bat") -Encoding Ascii
    @'
@echo off
if /i "%~1"=="clone" (
  xcopy /E /I /Q /Y "%FAKE_REPO%" "%~3" >nul
  exit /b %ERRORLEVEL%
)
exit /b 0
'@ | Set-Content -LiteralPath (Join-Path $successBin.FullName "git.cmd") -Encoding Ascii
    $env:FAKE_REPO = $fixtureRepo.FullName

    $observedHomes = @()
    foreach ($number in 1..2) {
        $driveRoot = New-Item -ItemType Directory -Path (Join-Path $testRoot "drive-$number")
        & $powerShell -NoProfile -File $runner $testScript $driveRoot.FullName $successBin.FullName $sharedHome.FullName
        Assert-True ($LASTEXITCODE -eq 0) "drive $number provisioning should succeed"
        $repo = Join-Path $driveRoot.FullName "north-forge-hermes-edition"
        $observed = (Get-Content -LiteralPath (Join-Path $repo "launcher-hermes-home.txt") -Raw).Trim()
        $expected = Join-Path $repo ".hermes-home"
        Assert-True ($observed -eq $expected) "drive $number launcher should target $expected, got $observed"
        $observedHomes += $observed
    }

    Assert-True ($observedHomes[0] -ne $observedHomes[1]) "two drives must use different Hermes homes"
    Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sharedHome.FullName "config.yaml")).Hash -eq $configHash) "shared config.yaml changed"
    Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $sharedHome.FullName ".env")).Hash -eq $envHash) "shared .env changed"
    Write-Host "PASS: two drives used separate .hermes-home folders; shared sentinels stayed byte-for-byte unchanged." -ForegroundColor Green
} finally {
    Remove-Item Env:FAKE_REPO -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}
