$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot '..\scripts\machine-reset-safety.ps1'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ("north-forge-reset-test-" + [guid]::NewGuid())

function New-Fixture([string]$Path, [switch]$Weak) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Path 'sentinel.txt') -Value 'must survive rejection'
    if (-not $Weak) {
        Set-Content -LiteralPath (Join-Path $Path 'config.yaml') -Value 'test: true'
        New-Item -ItemType Directory -Path (Join-Path $Path 'hermes-agent') | Out-Null
    }
}

function Assert-RejectedAndPresent([string]$Name, [string]$Candidate, [string]$Sentinel) {
    & $helper -Action Purge -Candidate $Candidate -ExpectedCanonical $Candidate 2>$null
    if ($LASTEXITCODE -eq 0) { throw "$Name was unexpectedly accepted." }
    if (-not (Test-Path -LiteralPath $Sentinel)) { throw "$Name deleted its sentinel." }
    Write-Host "PASS: $Name rejected; fixture was not deleted."
}

try {
    New-Item -ItemType Directory -Path $scratch | Out-Null
    $originalLocation = Get-Location
    Set-Location $scratch
    $relative = Join-Path $scratch 'relative-hermes'; New-Fixture $relative
    Assert-RejectedAndPresent 'relative path' '.\relative-hermes' (Join-Path $relative 'sentinel.txt')
    Assert-RejectedAndPresent 'drive-relative path' 'C:relative-hermes' (Join-Path $relative 'sentinel.txt')

    $weak = Join-Path $scratch 'weak'; New-Fixture $weak -Weak
    Assert-RejectedAndPresent 'traversal path' (Join-Path $scratch 'weak\..\weak') (Join-Path $weak 'sentinel.txt')
    Assert-RejectedAndPresent 'UNC path' '\\localhost\never-use-a-real-share' (Join-Path $weak 'sentinel.txt')
    $unusedDriveRoot = 'Z:\'
    foreach ($letter in [char[]](90..68)) {
        $possibleRoot = "$letter`:\"
        if (-not (Test-Path -LiteralPath $possibleRoot)) { $unusedDriveRoot = $possibleRoot; break }
    }
    Assert-RejectedAndPresent 'unused drive root' $unusedDriveRoot (Join-Path $weak 'sentinel.txt')
    Assert-RejectedAndPresent 'weak markers' $weak (Join-Path $weak 'sentinel.txt')

    $junctionTarget = Join-Path $scratch 'junction-target'; New-Fixture $junctionTarget
    $junction = Join-Path $scratch 'junction'
    cmd /c "mklink /J `"$junction`" `"$junctionTarget`"" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the scratch junction needed by this test.' }
    Assert-RejectedAndPresent 'junction target' $junction (Join-Path $junctionTarget 'sentinel.txt')

    $valid = Join-Path $scratch 'valid-hermes'; New-Fixture $valid
    $canonical = & $helper -Action Validate -Candidate $valid
    if ($LASTEXITCODE -ne 0) { throw 'Valid fixture did not validate.' }
    & $helper -Action Purge -Candidate $valid -ExpectedCanonical $canonical
    if ($LASTEXITCODE -ne 0 -or (Test-Path -LiteralPath $valid)) { throw 'Valid fixture was not removed.' }
    Write-Host 'PASS: valid isolated Hermes fixture was removed.'
} finally {
    if ($originalLocation) { Set-Location $originalLocation }
    Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
}
