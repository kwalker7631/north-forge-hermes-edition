# exclude-profile-skills - removes named skill(s) from an already-provisioned
# profile directory (profiles\<pin>\skills\<name> and
# profiles\<pin>\skills-source\shared\<name>). Extracted out of
# Zero-Touch-Deploy.ps1 so this specific, safety-relevant behavior is testable
# in isolation rather than embedded inline in that much larger, heavily
# side-effecting script.
<#
  scripts\exclude-profile-skills.ps1  -ProfileDir <path>  -SkillNames <name[]>  [-Quiet]

  WHY THIS EXISTS
    The private-edition profile install currently ships every skill in the
    edition's source tree to every drive, with no stick-class-aware curation.
    A real Round Table build (called Excalibur at the time; see
    ROUND-TABLE.md) found `pinokio` installed and chat-reachable on a
    locked, teammate-facing drive - a direct violation of ROUND-TABLE.md's own
    "Do not put on this stick: Pinokio." This does not decide the underlying
    policy (should exclusion be automatic, a distribution split, etc. - still
    open, see logs\CLAUDE_CODE_LAST_AUDIT.md) - it just makes "exclude this
    specific skill from this specific build" a one-flag, tested operation
    instead of a manual rm -rf after the fact.

  WHAT IT DOES
    For each name in -SkillNames, removes (if present):
      <ProfileDir>\skills\<name>
      <ProfileDir>\skills-source\shared\<name>
    A name not found under either path is reported, not an error - the skill
    may simply not exist in this edition, or may already be absent.

  EXIT CODE  Always 0 - this is best-effort cleanup, not a build-breaking gate.
             Check the printed output (or -Quiet + inspect the returned summary
             when dot-sourced) for what was actually removed.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProfileDir,
    [Parameter(Mandatory = $true)]
    [string[]]$SkillNames,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Status([string]$msg) { if (-not $Quiet) { Write-Host $msg } }

function Remove-ProfileSkill {
    param([string]$ProfileDir, [string]$SkillName)
    $removedPaths = New-Object System.Collections.Generic.List[string]
    foreach ($candidate in @(
        (Join-Path $ProfileDir "skills\$SkillName"),
        (Join-Path $ProfileDir "skills-source\shared\$SkillName")
    )) {
        if (Test-Path -LiteralPath $candidate) {
            Remove-Item -LiteralPath $candidate -Recurse -Force
            $removedPaths.Add($candidate)
        }
    }
    return $removedPaths
}

$summary = @{}
foreach ($skill in $SkillNames) {
    $removed = Remove-ProfileSkill -ProfileDir $ProfileDir -SkillName $skill
    $summary[$skill] = @($removed)
    if ($removed.Count -gt 0) {
        foreach ($p in $removed) { Write-Status "[exclude-profile-skills] removed $p" }
    } else {
        Write-Status "[exclude-profile-skills] '$skill' not found under $ProfileDir - nothing to remove."
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    # Invoked as a script (not dot-sourced) - print a final one-line summary
    # for the caller/human, then exit cleanly.
    $removedCount = ($summary.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
    Write-Status "[exclude-profile-skills] done: $removedCount path(s) removed across $($SkillNames.Count) skill name(s)."
    exit 0
}
