param([ValidateSet('sales', 'full')][string]$Mode = 'sales')

$ErrorActionPreference = 'Stop'
$parent = Join-Path (Get-Location) '.hermes'
$live = Join-Path $parent 'skills'
$token = '{0}-{1}' -f $PID, ([guid]::NewGuid().ToString('N'))
$stage = Join-Path $parent ".skills-staging-$token"
$backup = Join-Path $parent ".skills-backup-$token"
$shared = @('daily-brief', 'flush', 'kyocera-research', 'manual', 'menu', 'sales-assist', 'switch', 'web-navigator')
$tsc = @('assist-intake', 'draft-writer', 'escalation-packet', 'fault-logging', 'forge-audit', 'hotline-ticket', 'kb-builder', 'training-guide')
$swapped = $false

function Write-SkillLog([string]$Message) {
    Add-Content -LiteralPath 'forge-events.log' -Value ('[{0}] [skills]: {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
}

try {
    $sources = @('skills-source\shared')
    if ($Mode -eq 'full') { $sources += 'skills-source\tsc-only' }
    foreach ($source in $sources) {
        if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Required source folder is missing: $source" }
    }

    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    New-Item -ItemType Directory -Path $stage | Out-Null
    if ($env:NORTH_FORGE_TEST_FAIL_COPY -eq '1') { throw 'Simulated copy failure' }
    foreach ($source in $sources) {
        Get-ChildItem -Force -LiteralPath $source | Copy-Item -Destination $stage -Recurse -Force
    }

    $expected = @($shared)
    if ($Mode -eq 'full') { $expected += $tsc }
    foreach ($skill in $expected) {
        $directory = Join-Path $stage $skill
        if (-not (Test-Path -LiteralPath $directory -PathType Container) -or
            -not (Test-Path -LiteralPath (Join-Path $directory 'SKILL.md') -PathType Leaf)) {
            throw "Expected skill '$skill' is incomplete (folder or SKILL.md missing)"
        }
    }
    $sourceCount = @($sources | ForEach-Object { Get-ChildItem -LiteralPath $_ -File -Recurse }).Count
    $stageCount = @(Get-ChildItem -LiteralPath $stage -File -Recurse).Count
    if ($sourceCount -eq 0 -or $stageCount -ne $sourceCount) { throw "Zero-file or partial build ($stageCount of $sourceCount files)" }

    if (Test-Path -LiteralPath $live) { Rename-Item -LiteralPath $live -NewName (Split-Path $backup -Leaf) }
    if ($env:NORTH_FORGE_TEST_FAIL_SWAP -eq '1') { throw 'Simulated final swap failure' }
    Rename-Item -LiteralPath $stage -NewName 'skills'
    $swapped = $true
    if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
    Write-SkillLog "SUCCESS: activated validated $Mode build ($stageCount files)"
    exit 0
} catch {
    if (-not (Test-Path -LiteralPath $live) -and (Test-Path -LiteralPath $backup)) {
        try { Rename-Item -LiteralPath $backup -NewName 'skills' } catch { Write-SkillLog "FAILURE: backup restore also failed: $_" }
    }
    Write-Host "ERROR: $($_.Exception.Message). Existing skills were left untouched or restored."
    Write-SkillLog "FAILURE: $($_.Exception.Message); previous build preserved"
    exit 1
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }
    # Never delete a backup unless the new build is known to be live.
    if ($swapped -and (Test-Path -LiteralPath $backup)) { Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue }
}
