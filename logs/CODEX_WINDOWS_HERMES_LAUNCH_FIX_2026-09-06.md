# Codex Audit - Windows Hermes Launch Fix - 2026-09-06

## Status

**FIX IMPLEMENTED; AUTOMATED CONTRACT TESTS PASS.** A real Windows/Hermes
installation remains the required final field verification because this Linux
environment has neither Windows PowerShell 5.1 nor `pwsh`.

## What was requested

Review the existing audits, explain why the apparent successful activity occurs
despite the launch failure, and suggest a fix for the launch issue. Because the
prior audit had already confirmed a specific Zone A defect and supplied a
minimal repair, this session implemented that repair and added regression
coverage.

## Files inspected

- `AGENTS.md` and `CLAUDE.md` - session requirements and Zone A authority.
- `logs/CLAUDE_CODE_LAST_AUDIT.md` - the Windows incident timeline, captured
  installer output, confirmed root cause, recovery state, and proposed fix.
- `launch-north-forge.bat` - ordering of skill assembly and engine installation.
- `scripts/assemble-skills.ps1` - source of the successful "sales build (8
  files)" message described by the prior audit.
- `scripts/ensure-hermes.ps1` - Windows drive-local installer wrapper and the
  confirmed failure point.
- `scripts/ensure-hermes.sh` and `tests/test-drive-hermes-install.sh` - POSIX
  behavior and existing installer scenarios; no equivalent stderr defect was
  found because a POSIX process does not fail merely for writing to stderr.
- `tests/test_drive_hermes_contract.py` - existing cross-platform static
  contracts for the Windows wrapper.
- `.gitignore` and `logs/CODEX_PUSH_LOG.md` - repository hygiene and required
  Codex session records.

## Findings

### HIGH - the apparent success is skill assembly, not an installed engine

The launcher assembles the selected sales-mode skills first. That independent
step can correctly report that it activated an eight-file sales build. Only
later does `launch-north-forge.bat` call `scripts/ensure-hermes.ps1` to install
or validate the drive-local Hermes engine. The successful skill message
therefore means the content bundle was prepared; it does not mean the engine
was installed or started.

### HIGH - Windows PowerShell treated normal installer diagnostics as fatal

The upstream Hermes installer intentionally writes informational path
diagnostics to stderr. (Stderr is a program's secondary output channel; it is
often used for diagnostics, not only failures.) The wrapper had global
`$ErrorActionPreference = 'Stop'`, so Windows PowerShell 5.1 converted the
first such line into a terminating `NativeCommandError`. The wrapper's catch
then reported installer exit 1 even though the message was informational. The
prior audit confirmed this sequence from the real install log and the
downloaded upstream installer source.

### MEDIUM - failed invocation also leaked temporary parent state

The old wrapper restored `$env:HERMES_HOME` only after the installer command.
When stderr caused a throw, that restoration line was skipped. Although the
launcher process soon exited, restoring temporary environment changes on every
path is safer and makes the wrapper predictable if it is reused.

## Change made

The installer invocation now temporarily sets `$ErrorActionPreference` to
`Continue`, captures the native process's real `$LASTEXITCODE`, and restores
both the prior error policy and `HERMES_HOME` in `finally`. The relaxation is
strictly scoped to the child installer: drive write checks, download failures,
and all other wrapper operations retain fail-fast `Stop` behavior.

`tests/test_drive_hermes_contract.py` now verifies that diagnostics are allowed
before the child call, the real exit code remains authoritative, restoration is
in `finally`, and the relaxation cannot accidentally move after the invocation.

## Tradeoff considered

- **Chosen: scoped `Continue` plus `finally`.** This preserves the complete
  combined install log, accepts expected diagnostic stderr, retains native
  exit-code validation, and guarantees restoration of parent state.
- **Rejected: remove global `Stop`.** That would weaken unrelated safety checks
  and could allow real staging or download failures to continue.
- **Rejected: discard or suppress stderr.** Operators need those diagnostics
  when an actual install problem occurs.
- **Rejected: treat all stderr as success.** The wrapper still uses the native
  exit code and validates both the executable and `pyproject.toml`; a real
  installer failure still fails closed.

## Verification actually performed

- `python -m pytest tests/test_drive_hermes_contract.py -q` - **PASS**, 3 tests.
- `python -m pytest tests -q` - **PASS**, 20 tests and 3 subtests.
- `python -m compileall -q tests` - **PASS**, no syntax errors.
- `git diff --check` - **PASS** for whitespace errors; Git emitted only the
  repository's expected LF-to-CRLF working-copy notice for the PowerShell file.
- `shellcheck scripts/*.sh tests/*.sh` - **NOT RUN**, `shellcheck` is not
  installed in this environment; no shell code changed.
- `Invoke-ScriptAnalyzer -Path scripts/ensure-hermes.ps1 -EnableExit` - **NOT
  RUN**, neither `pwsh` nor Windows PowerShell is installed in this environment.

## Operator recovery and final field check

After updating to this commit on the affected Windows drive:

1. Close any North Forge window.
2. At the drive root, rename `.hermes-install-staging` if its contents are
   needed for support; otherwise delete it.
3. Delete the zero-byte `.hermes-install-incomplete` marker.
4. Double-click `North Forge.lnk` again. Do not delete `install-logs`; it is the
   diagnostic record if the upstream installer encounters a different issue.
5. Confirm `.hermes-home` appears, `.hermes-install-incomplete` disappears, and
   the launcher proceeds beyond "North Forge running in sales mode."
6. If it still fails, keep the newest `install-logs\hermes-install-*.log`; the
   wrapper should now show the real installer exit code rather than failing on
   the first informational line.

Tip: press `Ctrl+C` if the installer needs to be cancelled; do not close the
window during file activation.

## Potential edge cases / regressions

- A child installer that exits zero but creates an incomplete tree still fails
  validation, as before.
- A child installer that writes genuine error text to stderr but exits zero is
  judged by its exit code plus installed-tree validation. This is intentional;
  stderr text alone was proven unreliable as a failure signal.
- This session could not execute the repair under Windows PowerShell 5.1. The
  first clean launch on the affected drive is therefore the final integration
  test and should not be skipped.

## Final status

**CODE FIX COMPLETE / FIELD VALIDATION PENDING.** The confirmed false failure
is fixed without weakening the rest of the installer guard. The affected drive
must have its stale staging directory and incomplete marker cleared once before
retrying.
