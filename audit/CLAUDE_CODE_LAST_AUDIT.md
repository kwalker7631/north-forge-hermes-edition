# Claude Code Session Audit

Timestamp: 2026-09-06 (continuation of the prior HERMES_HOME-isolation
verification session, same conversation, new user request)
Requested task: two parts. Part 1 - fix three specifically-flagged
test/cleanup issues left over from the prior session (launch-north-forge.bat
duplicate HERMES_HOME assignment, a stale string in
tests/test_cron_registration.py, and a broken curl stub in
tests/test-drive-local-hermes.sh plus missing installer-fixture support in
tests/two-drive-hermes-isolation.sh), then run the full test suite and
confirm everything passes. Part 2 - structurally fix the "Codex sessions
sometimes don't leave an audit report" problem by creating AGENTS.md with a
mandatory-report rule, and add a pointer to it from CLAUDE.md's own
governance section.

## Files inspected

- `launch-north-forge.bat` (full read, then edited twice)
- `scripts/ensure-hermes.ps1`, `scripts/hermes-drive.ps1` (full read; the
  latter edited)
- `tests/test_launcher_hermes_home.py`, `tests/test_cron_registration.py`
  (full read of relevant sections; the latter edited)
- `tests/test-drive-local-hermes.sh`, `tests/two-drive-hermes-isolation.sh`,
  `tests/test-drive-hermes-install.sh`, `tests/test-launcher-hermes-home.sh`
  (full read where not already read last session; two of these rewritten)
- `audit/CODEX_SECOND_AUDIT_2026-09-05.md`,
  `audit/HERMES_CRON_GATEWAY_HOME_AUDIT.md` (re-read as structure reference
  for the new AGENTS.md's report-format guidance)
- `CLAUDE.md` (re-read; not edited - see "Declined Zone B edit" below)

## Zone A changes made

### 1. `launch-north-forge.bat` - collapsed triple HERMES_HOME assignment AND fixed a live, currently-shipping install-failure bug found while doing it

**As specifically flagged:** `set "HERMES_HOME=%CD%\.hermes-home"` appeared
3 times (`tests/test_launcher_hermes_home.py`'s
`test_windows_home_precedes_every_hermes_operation` expects exactly 1).
Collapsed to one occurrence, immediately after `cd /d "%~dp0"` (mirroring
the `.sh` file's `cd`-then-export ordering, which a *different*,
already-passing part of the same test also enforces for the POSIX file).

**Found while doing it, not previously flagged - empirically confirmed on
real Windows, not just read:** the original write-probe block
(`if not exist "%HERMES_HOME%" mkdir "%HERMES_HOME%" ...` followed by a
write-probe *inside* `%HERMES_HOME%`) created `.hermes-home` as a side
effect before `scripts\ensure-hermes.ps1` ever ran. `ensure-hermes.ps1`'s
own gate (`if ((Test-Path $homeDir) -or ...) { "partial or damaged
.hermes-home"; exit 20 }`) then treated that empty, pre-created directory as
a corrupt existing install and refused to touch it - **this is the exact
same bug class already fixed in `launch-north-forge.sh` last session, but
it was never applied to the Windows launcher.**

I did not take this on faith from reading the code - I built a real
scratch-drive harness and ran the actual `.bat` file via a redirected-I/O
`System.Diagnostics.Process` (PowerShell tool; a fragile `cmd.exe /c "..."`
string through the Bash/Git-Bash tool mis-quoted and left a stray idle
`cmd.exe` process I did not kill, since I could not be certain which of
several running `cmd.exe` PIDs was mine to safely terminate - flagging this
tool-usage note in case it recurs). Confirmed exit code 20 with "ERROR: This
drive has a partial or damaged .hermes-home" on a completely fresh scratch
drive, before touching anything.

Fixed the same way as the `.sh` file: the probe now writes directly into
`%CD%` (renamed `HERMES_HOME_PROBE` to `WRITE_PROBE` to match, since it's no
longer HERMES_HOME-specific), never creating `.hermes-home` itself. Also
removed the "could not create its drive-local Hermes home" error branch
entirely (dead code now - `ensure-hermes.ps1` owns creation/validation and
has its own equivalent error handling), matching the `.sh` file's fix
exactly. Removed the second (mid-file) and third (pre-`ensure-hermes.ps1`)
duplicate assignments.

**Re-verified empirically after the fix**, same real-Windows harness, with
a `NORTH_FORGE_INSTALLER_PS1` fixture (the `.ps1`-side equivalent of
`NORTH_FORGE_INSTALLER_SH`, already supported by `ensure-hermes.ps1`):
`.hermes-home` no longer exists before the installer runs; the fixture
install completes and "Hermes was installed and validated on this drive."
prints; `.hermes-home` afterward contains exactly the fixture's real
installed content, not a stale empty leftover.

### 2. `scripts/hermes-drive.ps1` - fixed a second, previously-unreachable bug the above fix uncovered

While re-verifying end-to-end (not just the write-probe fix in isolation),
fixing item 1 above required also restoring a `set "HERMES_CMD=..."`
assignment that turned out to be **missing from the current file entirely**
(confirmed via `grep -in HERMES_CMD launch-north-forge.bat`: referenced 6
times, assigned nowhere). Git history
(`git log -p -S "HERMES_CMD=" -- launch-north-forge.bat`) shows this line
was correctly added in commit `c2c7303` ("Keep Hermes cron state on its
originating drive") but silently lost in a later merge that restructured
the install-guard block around it - the same *class* of loss the file's own
existing comment already documents happening once before to `%PYTHON_CMD%`
("Restored during merge: ... without it, %PYTHON_CMD% below is empty and
name_validation.py never runs"). `%HERMES_CMD%` being undefined meant every
skin/skills/cron/hermes call in the Windows launcher was silently expanding
to an empty command.

Restored `set "HERMES_CMD=powershell -NoProfile -ExecutionPolicy Bypass
-File scripts\hermes-drive.ps1"` in the equivalent position to the `.sh`
file's `hermes() { scripts/hermes-drive.sh "$@"; }` (after the
`ensure-hermes.ps1` validation succeeds, not before).

Restoring it exposed a **second, real, previously-never-exercised bug**:
`scripts/hermes-drive.ps1` line 3 was `$home = Join-Path $repo
'.hermes-home'` - `$home` is a **reserved PowerShell automatic variable**
(the user's profile directory) and is read-only in this scope. This
crashed with "Cannot overwrite variable HOME because it is read-only or
constant" on the very first real invocation - confirmed empirically (real
Windows, redirected-I/O process, fixture installer placing a dummy
`Scripts\hermes.exe`). Because `%HERMES_CMD%` had been silently blank, this
script was **never actually reached before today**, so this bug had zero
chance to surface until the missing-assignment fix above put it back in the
execution path. Fixed by renaming `$home` to `$homeDir` throughout the file
(matching `ensure-hermes.ps1`'s own already-correct naming for the same
concept). Re-verified: the fixture run now reaches the real `& $hermes
@args` execution line and fails only because the test fixture's
`hermes.exe` is a placeholder file, not a real binary ("not a valid
application for this OS platform") - a test-fixture limitation, not a
product bug; both real product bugs are confirmed fixed.

### 3. `tests/test_cron_registration.py` - updated a stale Windows string, per instruction

`test_windows_launcher_has_equivalent_failure_handling` expected the
literal string `set "HERMES_HOME=%~dp0.hermes-home"`; the `.bat` file
correctly uses `cd /d "%~dp0"` then `set "HERMES_HOME=%CD%\.hermes-home"`
(functionally identical, textually different - stale drift from an earlier
path-resolution style). Updated the test's expected string to
`'set "HERMES_HOME=%CD%\\.hermes-home"'` per the explicit instruction not to
change the `.bat` file to match the stale test. Verified: passes.

### 4. `tests/test-drive-local-hermes.sh` - fixed the curl stub to honor `-o`, and rewrote the "broken install" scenario to match current code

The old fake `curl` ignored the real `-o <file>` argument
`ensure_drive_hermes` passes and just `cat`'d its heredoc to stdout, so the
test never actually exercised the curl hand-off path - it silently degraded
into an unrelated failure ("installer exit 127," command not found; I
reproduced this exact symptom against unmodified HEAD last session before
today's fix). New stub parses `$@` for `-o <path>` and writes the fake
installer script there, matching real `curl` usage.

While fixing this I found the *second* scenario in the same file
("broken install: successful exit without runtime markers") referenced
`NORTH_FORGE_HERMES_READY_ONLY` and log strings ("verified drive-local
checkout", "installer reported success", "installer exited 0 but required
markers were absent") that **do not exist anywhere in current production
code** - confirmed via repo-wide grep, zero matches outside the test file
itself. This scenario predates the current `ensure_drive_hermes`
architecture entirely and was never updated. Rewrote it to exercise the
same intent (a curl that reports success but produces no valid install)
against the actual current code path: a curl stub that exits 0 but writes
an *empty* file to `-o`'s target, so `bash "$installer"` trivially succeeds
but `hermes_home_valid` still fails - hitting `ensure_drive_hermes`'s real
"installation failed or did not pass validation" message and its real
`.hermes-install-incomplete` marker behavior. Verified: both scenarios pass.

### 5. `tests/two-drive-hermes-isolation.sh` - added installer-fixture support; also removed a python3 dependency the fix exposed

Added a `NORTH_FORGE_INSTALLER_SH` fixture (same mechanism
`tests/test-drive-hermes-install.sh` already uses) that installs a copy of
the test's existing fake `hermes` script as the drive-local executable, so
onboarding's `scripts/hermes-drive.sh`-mediated calls produce cron-store
entries in the exact format the test's existing assertions already expect
(no other assertions needed to change). This replaces the prior behavior of
attempting a real, unauthenticated network install
(`https://hermes-agent.nousresearch.com/install.sh`) with no fixture at
all, which failed silently under `set -e` inside a subshell whose output
went to a log file deleted by the script's own cleanup trap before the
exit code was ever visible - I could reproduce the silent failure but not
usefully diagnose it further without this fix.

While verifying, hit a *different*, pre-existing portability bug the fix
exposed: the fake `hermes` script's `home="$(python3 -c
'...os.path.realpath...')"` line failed with `python3: command not found`
during the test's later "simulated scheduler" sections, which deliberately
run with a narrowed `PATH="$BIN:/usr/bin:/bin"` (to prove a real scheduler
with no inherited launcher state still resolves correctly). On Linux,
`/usr/bin/python3` commonly exists, so this narrow PATH still finds it; on
this Windows/Git-Bash machine it does not (`python3` resolves only under
`AppData\Local\Microsoft\WindowsApps`). Since every caller in this test
already passes an already-absolute, already-canonical `HERMES_HOME` (no
symlinks involved anywhere in the fixture), the realpath step is
unnecessary here - replaced it with a plain `"${HERMES_HOME:-$HOME/.hermes}"`
and removed the python3 dependency entirely. Verified: passes.

## Full test suite run after all of Part 1's fixes

Not just the four specifically-touched files - ran everything runnable in
this environment:

- `bash -n launch-north-forge.sh` - syntax OK
- `tests/test-launcher-hermes-home.sh` - PASS
- `tests/test-drive-hermes-install.sh` - PASS (5 scratch scenarios,
  unaffected by today's changes - re-run as a regression check)
- `tests/test-drive-local-hermes.sh` - PASS (both scenarios, rewritten)
- `tests/two-drive-hermes-isolation.sh` - PASS (rewritten)
- `python3 -m unittest tests.test_launcher_hermes_home` - all 3 tests OK
- `python3 -m unittest tests.test_cron_registration.CronRegistrationWarningsTest`
  - both tests OK (the class's two static/subprocess-on-bash tests; these
    run fine under Windows Python since they invoke `bash` explicitly)

**Not run, same environment limitation noted last session:**
`tests.test_cron_registration.DriveLocalCronIsolationTest` and
`tests.test_drive_hermes_contract` use `subprocess.run()` on a `.sh` path
directly or lack `unittest.TestCase` classes (pytest-style bare functions,
and no `pytest` is installed here) - native Windows Python cannot execute a
shebang script directly (`WinError 193`), and `python3 -m unittest` finds
zero tests in a pytest-style module. I did not silently skip verifying
`test_drive_hermes_contract`'s assertions, though: manually grepped every
string it requires (`ensure_drive_hermes "$PWD"`, the single
`HERMES_HOME=%CD%...` assignment, `scripts\ensure-hermes.ps1`, absence of
`where hermes`) against the files as they stand after all of today's edits -
all still hold. This is a real, standing gap in what I can verify in this
environment, not a claim that those tests pass - flagging again since it
was flagged last session too and nothing has changed about the environment.

## Zone A / new-file work for Part 2

### `AGENTS.md` (new file, repo root) - created

Not on CLAUDE.md's enumerated file list for any zone (it didn't exist
before this session). Judged this to be reasonable to author directly,
unlike a Zone B edit: its content is process/governance for how Codex
conducts a session in this repo (report format, when a report is required,
commit sequencing) - not authored field-support or customer-facing
technical content, and not an edit to any existing Blacksmith-reviewed
file. Content follows the four hard requirements given verbatim in this
session's request (mandatory report per session including no-change
sessions, committed alongside any code changes, structure matching existing
`audit/` reports, and explicit-not-implicit tradeoff writeups), plus a
"Relationship to CLAUDE.md" section that points at `CLAUDE.md` as the single
source of truth for zone definitions rather than duplicating them, so the
two files don't drift out of sync with each other over time.

### CLAUDE.md governance pointer - DECLINED, drafted for review instead

The request asked me to "add a short pointer in CLAUDE.md's own governance
section noting that AGENTS.md exists." I did not do this directly.
`CLAUDE.md` explicitly lists itself as Zone B ("`CLAUDE.md` (this file,
itself)") and is explicit that Claude Code composing or editing any part of
it - including "not even when explicitly asked to 'fix any issues' in the
repo broadly" - is not permitted regardless of how specific or reasonable
the request is, *unless* the content is a named handoff Kenneth identifies
as originating from the Claude Project chat (the CONFIRMED 2026-08-26
trigger). This request is a specific, well-reasoned, directly-stated
instruction from Kenneth in-session, but it asks me to *compose* new text
for CLAUDE.md, not to *place* pre-authored text handed to me as originating
from the Claude Project chat - it does not satisfy the confirmed trigger's
own terms. There is direct precedent for this exact call in this repo's own
history: commit `713b2c3`, "Decline direct CLAUDE.md edit request (Zone B,
no Claude-Project-chat handoff), draft proposed testing-safety rule for
review." I followed that same pattern rather than treating a direct,
specific ask as sufficient on its own - CLAUDE.md's whole reasoning for
locking even itself is precisely to prevent exactly this kind of "it's just
a small, obviously-reasonable addition" edit from becoming the quiet
precedent that erodes the boundary.

**Drafted text, for Kenneth or the Claude Project chat to place** (proposed
insertion point: right after the "Note on Hermes's own context-file
discovery" paragraph near the top of `CLAUDE.md`, before "## Zone A"):

> Note on AGENTS.md: this repo also has an `AGENTS.md` at its root, which
> plays the equivalent role for Codex sessions that this file plays for
> Claude Code sessions. It is not a separate, hidden rule set - it points
> back to this file's zone definitions as the single source of truth rather
> than duplicating them, and adds one Codex-specific hard requirement (every
> Codex session must write and commit an audit report, added 2026-09-06
> after a session that skipped this left no record of a real fix it made).
> If AGENTS.md's own audit-report requirement needs to change, that's a
> Codex-process change and doesn't need to route through this file; if the
> zone definitions themselves change, update them here only - AGENTS.md
> refers to this file rather than keeping its own copy.

If Kenneth confirms this text (or the Claude Project chat's own revision of
it) as originating from the Claude Project chat with an instruction to
place it, I can commit it in a follow-up with no further discussion needed,
per the already-confirmed trigger.

## This session's own report, as the first real test of the rule this session created

Per CLAUDE.md's own unconditional audit-report requirement (which already
existed before today, and which today's `AGENTS.md` extends the same
underlying discipline to Codex), this file itself is that report for this
session - written and about to be committed alongside every code change
described above, not after the fact. There's a small irony worth naming
directly: this session was asked to fix "Codex doesn't always leave a
report" by creating a rule for Codex, while operating under a rule that
already required exactly this of Claude Code. The new `AGENTS.md` doesn't
invent a new discipline - it extends one that was already being enforced on
one agent to also cover the other.

## Commits made this session

- Pending - all Zone A fixes and the new `AGENTS.md` file are committed
  together in this session's commit(s) immediately following this report,
  per standing Zone A/audit-report authorization. `.gitignore`-covered
  per-drive state (`.env`, `.agent-name`, `.provider-choice`,
  `.drive-record.txt`, `.forge-mode`, `.readme-shown`, `forge-events.log`)
  confirmed absent from `git status --porcelain` before staging - none of
  it was ever a candidate for this commit.

## Uncertain / flagged for primary GPT review

1. **The declined CLAUDE.md edit** (above) - confirm the drafted text (or a
   revision of it) is acceptable, and relay it back as a named
   Claude-Project-chat-originated handoff if so, per the file's own
   established mechanism.
2. **Two real, previously-unnoticed Windows bugs were fixed beyond what was
   specifically flagged** (the `.bat` write-probe's premature `.hermes-home`
   creation, and `hermes-drive.ps1`'s `$home` reserved-variable crash). Both
   were confirmed via real execution on this machine's actual Windows
   environment, not just static reading. Flagging for a second opinion
   specifically because this went beyond the literal ask (which only named
   the duplicate-assignment count issue) - I judged this to be squarely
   within "fix everything currently flagged" plus the standing "fix a real
   bug your own testing surfaces" authorization from last session, applied
   here for the first time to a file (`launch-north-forge.bat`) rather than
   a test, and to `scripts/hermes-drive.ps1` which isn't on CLAUDE.md's
   enumerated Zone A list either (same standing zone-boundary gap flagged
   last session, not yet resolved).
3. **Tool-usage note**: a `cmd.exe /c "..."` invocation through the
   Bash/Git-Bash tool mis-quoted and left an idle interactive `cmd.exe`
   process running (harmless - sitting at an idle prompt, never executed
   anything, in a scratch directory). I did not `taskkill` it since I could
   not distinguish it from other legitimate `cmd.exe` processes already
   running on this machine, and switched to the PowerShell tool's own
   `System.Diagnostics.Process` for reliable redirected I/O instead.
   Flagging so Kenneth can close that stray window manually if he notices
   it, and so a future session knows to prefer the PowerShell tool for this
   kind of redirected-I/O `.bat` testing rather than nested `cmd.exe`
   quoting through Bash.
4. **The zone-boundary gap flagged last session** (`scripts/`, `tests/` not
   on CLAUDE.md's enumerated Zone A list) is now touched by an even wider
   set of real fixes this session and still hasn't been formally resolved.
   Recommend closing this explicitly rather than letting each session
   re-flag it.

## Status
Needs primary GPT review - primarily item 1 (the declined CLAUDE.md edit,
now drafted and waiting on a proper handoff) and the standing zone-boundary
gap (item 4, and last session's Finding 1/2 about the missing Codex report,
which `AGENTS.md` now structurally addresses going forward). All of Part
1's fixes are verified: the three specifically-flagged issues are fixed and
passing, plus two additional real, empirically-confirmed bugs found and
fixed along the way (documented above, not silently folded in). Part 2's
`AGENTS.md` is created and about to be committed; its companion CLAUDE.md
pointer is deliberately not placed by me and is drafted above for Kenneth's
or the Claude Project chat's actual placement.
