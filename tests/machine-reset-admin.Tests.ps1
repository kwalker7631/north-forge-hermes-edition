$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot '..\scripts\machine-reset-admin.ps1'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ("north-forge-admin-test-" + [guid]::NewGuid())
$store = Join-Path $scratch '.machine-reset-admin.json'

function Assert-ExitCode([string]$Name, [int]$Expected, [scriptblock]$Action) {
    & $Action | Out-Null
    if ($LASTEXITCODE -ne $Expected) { throw "$Name`: expected exit $Expected, got $LASTEXITCODE" }
    Write-Host "PASS: $Name"
}

try {
    New-Item -ItemType Directory -Path $scratch | Out-Null

    # Nothing configured yet -> fail CLOSED, never open.
    Assert-ExitCode 'unset store refuses any input' 1 {
        & $helper -Action Test -Passcode 'RumpleStiltskin' -StorePath $store
    }
    Assert-ExitCode 'unset store refuses even a plausible-looking guess' 1 {
        & $helper -Action Test -Passcode 'anything-at-all' -StorePath $store
    }

    # Set a scratch-only passcode (never the real one) and confirm round-trip.
    & $helper -Action Set -Passcode 'scratch-test-passcode-1' -StorePath $store | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Set failed.' }
    if (-not (Test-Path -LiteralPath $store)) { throw 'Set did not create the store file.' }
    $raw = Get-Content -LiteralPath $store -Raw
    if ($raw -match 'scratch-test-passcode-1') { throw 'SECURITY: the plaintext passcode was written to disk.' }

    Assert-ExitCode 'correct passcode passes' 0 {
        & $helper -Action Test -Passcode 'scratch-test-passcode-1' -StorePath $store
    }
    Assert-ExitCode 'wrong passcode fails' 1 {
        & $helper -Action Test -Passcode 'wrong' -StorePath $store
    }
    Assert-ExitCode 'the retired real-world passcode fails' 1 {
        & $helper -Action Test -Passcode 'RumpleStiltskin' -StorePath $store
    }

    # Set again without -Rotate must refuse (an existing credential is not silently overwritten).
    Assert-ExitCode 'Set refuses to overwrite an existing passcode' 1 {
        & $helper -Action Set -Passcode 'some-other-value' -StorePath $store
    }
    Assert-ExitCode 'original passcode still works after the refused Set' 0 {
        & $helper -Action Test -Passcode 'scratch-test-passcode-1' -StorePath $store
    }

    # Rotate changes it for real.
    & $helper -Action Rotate -Passcode 'scratch-test-passcode-2' -StorePath $store | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Rotate failed.' }
    Assert-ExitCode 'old passcode fails after rotation' 1 {
        & $helper -Action Test -Passcode 'scratch-test-passcode-1' -StorePath $store
    }
    Assert-ExitCode 'new passcode passes after rotation' 0 {
        & $helper -Action Test -Passcode 'scratch-test-passcode-2' -StorePath $store
    }

    Write-Host ''
    Write-Host 'ALL PASS: machine-reset-admin.ps1'
} finally {
    if (Test-Path -LiteralPath $scratch) { Remove-Item -LiteralPath $scratch -Recurse -Force }
}
