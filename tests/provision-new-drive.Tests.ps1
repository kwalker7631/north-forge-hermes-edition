# Run with: powershell.exe -NoProfile -File .\tests\provision-new-drive.Tests.ps1
# This dependency-free integration test gives provisioning a fake git command
# and verifies that neither a failed pull nor a failed clone starts the launcher.

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
    $fakeBin = New-Item -ItemType Directory -Path (Join-Path $testRoot "fake-bin")
    Set-Content -LiteralPath (Join-Path $fakeBin.FullName "git.cmd") -Encoding Ascii -Value "@echo fake git failure 1>&2`r`n@exit /b 23`r`n"

    $testScript = Join-Path $testRoot "provision-new-drive.ps1"
    (Get-Content -LiteralPath $sourceScript -Raw).Replace("YOUR_TOKEN_HERE", "TEST_TOKEN") |
        Set-Content -LiteralPath $testScript

    $runner = Join-Path $testRoot "run-scenario.ps1"
    @'
param([string]$ProvisionScript, [string]$DriveRoot, [string]$FakeBin)
$env:SystemDrive = "C:"
$env:PATH = "$FakeBin;$env:PATH"
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $DriveRoot | Out-Null
function Get-Volume {
    param([string]$DriveLetter, [object]$ErrorAction)
    [pscustomobject]@{ DriveLetter = "Z"; FileSystem = "exFAT"; Size = 8GB; FileSystemLabel = "TEST" }
}
& $ProvisionScript
'@ | Set-Content -LiteralPath $runner

    foreach ($scenario in @("pull", "clone")) {
        $driveRoot = New-Item -ItemType Directory -Path (Join-Path $testRoot $scenario)
        $marker = Join-Path $driveRoot.FullName "launcher-invoked.txt"

        if ($scenario -eq "pull") {
            $repo = New-Item -ItemType Directory -Path (Join-Path $driveRoot.FullName "north-forge-hermes-edition")
            Set-Content -LiteralPath (Join-Path $repo.FullName "launch-north-forge.bat") -Encoding Ascii -Value ('@echo launched>"{0}"' -f $marker)
        }

        & $powerShell -NoProfile -File $runner $testScript $driveRoot.FullName $fakeBin.FullName
        $exitCode = $LASTEXITCODE

        Assert-True ($exitCode -ne 0) "$scenario failure should exit nonzero"
        Assert-True (-not (Test-Path -LiteralPath $marker)) "$scenario failure must not invoke launch-north-forge.bat"
        Write-Host "PASS: failed $scenario exited $exitCode and did not launch North Forge." -ForegroundColor Green
    }
} finally {
    Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}
