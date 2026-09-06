# Claude Code Session Audit

Timestamp: 2026-09-06 00:52 EDT (America/New_York, UTC-04:00), on the `E:`
drive clone (`E:\north-forge-hermes-edition`). Continuation of the same
session as the preceding audit (commit `5fc9817`, clean session-start
check); this is the first real work order of the session.

Requested task (from the North Forge GPT, pasted by Kenneth): add a
dependency-check + guided-install step at the very top of BOTH launchers so
a fresh drive on a machine without Python 3 no longer dead-ends. Specifics
asked for: (1) check every dependency North Forge/Hermes actually needs at
launch - "at minimum Python 3 and Node.js", but investigate whether Node is
really a launch dependency; (2) on a missing dep, prompt
`Install it now? [Y/n] (recommended: Y)` with plain-Enter = Yes, don't just
fail; (3) on Yes, download + run the official installer unattended (Windows
Python: python.org `.exe` with `/quiet InstallAllUsers=0 PrependPath=1`;
investigate the right silent invocation per OS), show progress, then
**re-check** the dep is actually satisfied; (4) on No, print exactly what's
missing + a manual link and exit cleanly; (5) log every step to
`forge-events.log` in the existing format; (6) fast/no-delay when the dep is
already present. Also: investigate real call sites, correct unattended
flags per OS, and whether Windows needs elevation. Verify in an isolated
scratch env with the dep artificially absent (mocked install), not on the
real machine. Separately (flag back, do NOT implement): the "bundle a
portable Python on the drive" idea.

## Files inspected

Read in full:
- `launch-north-forge.sh` (428 lines pre-change) and `launch-north-forge.bat`
  (361 lines pre-change) - the two files being changed.
- `scripts/ensure-hermes.sh` (107 L), `scripts/ensure-hermes.ps1` (83 L),
  `scripts/hermes-drive.sh` (36 L), `scripts/hermes-drive.ps1` (46 L),
  `scripts/assemble-skills.ps1` (62 L), `scripts/name_validation.py`
  (145 L) - to trace what the launch path genuinely invokes.
- `scratchpad/install.sh` (3890 L) and `scratchpad/install.ps1` (5063 L) -
  the live upstream Hermes installers, re-downloaded this session
  (`curl -fsSL https://hermes-agent.nousresearch.com/install.{sh,ps1}` ->
  HTTP 200, 170273 / 245718 bytes) - to determine whether the ENGINE
  install needs system Python/Node/git.
- `tests/test-launcher-hermes-home.sh`, `tests/test-drive-hermes-install.sh`,
  `tests/test-free-provider.sh`, `tests/test-skill-assembly.sh`,
  `tests/two-drive-hermes-isolation.sh`, `tests/test_launcher_hermes_home.py`,
  `tests/test_drive_hermes_contract.py`, `tests/test_cron_registration.py`,
  `tests/test-free-provider.bat`, `tests/provision-new-drive.Tests.ps1` -
  to find every constraint a change to the launchers must not break.
- `CHANGELOG.md` (top section), `.gitattributes`, `.gitignore` (from the
  prior audit).

Changed:
- `launch-north-forge.sh` - Zone A. `+176 / -4`.
- `launch-north-forge.bat` - Zone A. `+107 / -3`.
- `CHANGELOG.md` - Zone C. `+6 / -0`.
- `tests/test-dependency-check.sh` - Zone A (new, 100 lines, `chmod +x`).
- `logs/CLAUDE_CODE_LAST_AUDIT.md` - Zone A (this file).

Created then deleted this session: `tests/test-dependency-check.bat` (a
batch test harness; its plumbing - `call`ing the launcher from a `:label`
subroutine with input redirection - proved flaky and I removed it rather
than commit a half-working test; see "Verification" for how the `.bat` path
was checked instead).

## Investigation findings (the "investigate before implementing" asks)

### 1. What the launch path actually invokes - real call sites

`grep` of `launch-north-forge.sh`, `launch-north-forge.bat`, and every
`scripts/*.{sh,ps1,py}` for `node|npm|npx|nodejs`, plus a read of each
external-command call site:

| dependency | needed at launch? | where |
|---|---|---|
| **Python 3** | **YES - hard** | `.sh`: `scripts/name_validation.py` (L63, L195 post-change numbering shifts) + the `.hermes.md` assembly heredoc `python3 - "$MODE" <<PYEOF` (~L202). `.bat`: `%PYTHON_CMD% scripts\name_validation.py drive`/`agent` (L68/L151) + `& %PYTHON_CMD% ...name_validation.py get` inside the `.hermes.md` PowerShell block (L160). All run BEFORE `scripts/ensure-hermes.*` (the engine installer) is reached. |
| Node.js / npm / npx | **NO** | Zero occurrences anywhere on the launch path. Only refs in the whole repo: `CHANGELOG.md` L67 and `logs/HANDOFF_2026-09-04...` - both the manual `npx agent-browser install --with-deps` browser-fallback step for research passes, run by hand, long after launch. |
| git | no (optional) | `.sh` L67-71 / `.bat` L116-126 log a WARNING if `git` is absent and continue. Not gated. |
| curl (POSIX) | only for the ENGINE download | `scripts/ensure-hermes.sh` L82 `curl -fsSL https://hermes-agent.nousresearch.com/install.sh`. Near-universal on macOS/Linux; `NORTH_FORGE_INSTALLER_SH` bypasses it. Windows uses `Invoke-WebRequest` (built in). Left unchecked - out of the task's Python/Node scope and low-risk. |
| PowerShell (Windows) | YES but always present | Windows 7+ ships it; not a realistic "missing" case. |

### 2. Does the Hermes ENGINE installer need system Python/Node/git? No.

From `scratchpad/install.sh`:
- L691 `check_python`: "Python not found - use uv to install it (no sudo
  needed!)". The installer installs its own Python via `uv` when absent.
- L705 `ensure_git` / L775+: bootstraps git ("downloads PortableGit on
  Windows"; `brew`/`apt-get`/`dnf`/`pkg` on POSIX).
- `NODE_VERSION="26"`, L933 "replaced with the Hermes-managed Node
  $NODE_VERSION" - the installer installs its own Node; L832-919 also
  checks for a C++ compiler for `node-pty`.
- L331 stage manifest confirms `prerequisites`, `venv`, `python-deps`,
  `node-deps` are all installer-internal stages.

So the engine is self-sufficient. The field failure is purely the
**launcher's own earlier Python need** (`name_validation.py` + `.hermes.md`
assembly), which is exactly what `launch-north-forge.sh` L32-36 /
`launch-north-forge.bat` L45-49 hard-failed on before this change.

**Conclusion on the dependency list:** implement the guided install for
**Python 3 only**. Do **not** prompt for Node.js - installing system Node
would add unused state (the engine ignores it) and confuse the operator.
This is a deliberate, documented deviation from the task's "at minimum
Python 3 and Node.js" wording, justified by the investigation the task
itself asked for.

### 3. Correct unattended-install invocation per OS, and elevation

Verified against python.org this session (`curl -fsSI`):
- Python **3.12.x has no binary installers** after 3.12.10 (source-only
  now). Latest line with Windows `.exe` + macOS `.pkg` is **3.13**; latest
  is `3.13.15` (`.../3.13.15/python-3.13.15-amd64.exe` -> 200, 28775744 B;
  `.../python-3.13.15-macos11.pkg` -> 200, 70286381 B). 3.13 is inside
  Hermes's `requires-python >=3.11,<3.14`. **Pinned `3.13.15`** in both
  launchers (one editable line each). python.org keeps every historical
  release forever, so a pinned URL is stable indefinitely.
- **Windows** (`.exe`): `/quiet InstallAllUsers=0 PrependPath=1
  Include_launcher=1 Include_test=0`. `InstallAllUsers=0` = per-user =
  **NO administrator rights required** (this is the key finding for the
  task's elevation question - the prompt says so plainly and does not ask
  for admin). Run via `start "" /wait` because the installer is a
  GUI-subsystem exe (cmd would not block on a bare invocation). Return
  codes: 0 = ok, 3010 = ok-but-reboot (treated as success), else failure.
  Download via `Invoke-WebRequest -UseBasicParsing` (TLS 1.2 forced).
- **macOS** (`.pkg`): `sudo installer -pkg <file> -target /`. The
  python.org pkg has **no per-user mode - it requires admin**. The prompt
  states "macOS will ask for your administrator password" before running.
- **Linux**: no official python.org installer. Detect
  `apt-get`/`dnf`/`pacman`/`zypper`/`apk` and run the matching
  `sudo ... install ... python3`. Requires sudo; the prompt says
  "will ask for your password (sudo)" first. No known manager -> straight
  to the manual message.

## Zone A changes made

### `launch-north-forge.sh` (`+176 / -4`)

Replaced the 5-line bare-fail block (old L32-36:
`if ! command -v python3 ...; then echo "python3 is required..."; exit 1;
fi`) with a self-contained dependency gate, placed at the same spot -
after the drive-writable probe (L23-29), before the welcome-page /
name-entry steps, and (critically for `tests/test_launcher_hermes_home.py`)
**after** the `export HERMES_HOME=...` line and containing no line that
matches that test's `^\s*(?:hermes\b|curl\b.*hermes-agent\.nousresearch\.com)`
regex. Structure:

- `NF_PY_VERSION="3.13.15"` - the one pinned-version line.
- `nf_dep_log LEVEL msg` - appends `[<ts>] [LEVEL] [deps]: msg` to
  `forge-events.log` (same format as the file's other pre-`log_event()`
  writes at L25/L53/L70).
- `nf_detect_python` - **detection only, never executes the interpreter**
  (comment says why: `tests/test-launcher-hermes-home.sh` stubs `python3`
  with a sentinel that `exit 42`s when RUN; executing it in the gate would
  break that test and misread a working stub as broken). Checks `command -v
  python3`/`python`, then the absolute paths `/usr/local/bin/python3`,
  `/usr/bin/python3`,
  `/Library/Frameworks/Python.framework/Versions/Current/bin/python3`, and
  a test-only extra dir `${NORTH_FORGE_DEP_PY_EXTRA_DIR}`. No PATH
  prepend of a scratch dir (CLAUDE.md's 2026-09-05 PATH-shadow rule).
- `nf_python_ok` - wraps `nf_detect_python` with the test flag:
  `NORTH_FORGE_DEP_FORCE_PY_MISSING=1` makes only the initial gate see
  "missing" (post-install re-check still finds real Python -> exercises the
  success path); `=always` makes both see missing (exercises "installer
  succeeded but Python still absent").
- `nf_python_manual_help` - per-OS manual instructions + download URL.
- `nf_run_python_installer` - the mockable seam. If
  `NORTH_FORGE_DEP_INSTALLER` is set, runs that and returns its code.
  Otherwise per-OS: Darwin downloads `python-3.13.15-macos11.pkg` and
  `sudo installer`; Linux dispatches to the detected package manager;
  unknown OS returns 94. Distinct non-zero return codes (90-94) for each
  failure mode.
- Gate logic: `if NF_PYCMD="$(nf_python_ok)"; then` log INFO "present" and
  fall through (fast path). `else` -> log WARNING; if `! [ -t 0 ]` **and**
  no `NORTH_FORGE_DEP_INSTALLER` -> log FAILURE "no interactive terminal",
  print manual help, `exit 1` (don't auto-download unattended on an
  unwatched machine); else `printf "Install it now? [Y/n] (recommended:
  Y): "`, `read NF_ANS || NF_ANS=""`, lower/strip, `n|no` -> log +manual
  +`exit 1`; anything else (incl. empty = plain Enter) -> log "approved",
  run installer, on non-zero code -> log FAILURE +manual +`exit 1`, on
  zero -> **re-detect with `nf_detect_python`** (ignores the force flag's
  `1` value); if found, prepend its dir to PATH when it's absolute, log
  "installed and verified", continue; if still not found -> log FAILURE
  +manual +`exit 1`.
- `set -e` safety: every failable command is inside an `if`/`case`
  condition or an explicit `|| NF_ANS=""` / `; rc=$?` capture, matching the
  idioms already in this file (e.g. the `configure_free_provider` block's
  `if VAR=$(...); then`).

`bash -n launch-north-forge.sh` -> clean.

### `launch-north-forge.bat` (`+107 / -3`)

Three hunks:
1. After the existing `where py`/`where python` detection (L42-44), added
   one test-seam line: `if defined NORTH_FORGE_DEP_FORCE_PY_MISSING set
   "PYTHON_CMD="` (comment: test-only, never set in normal use).
2. Replaced the 5-line bare-fail block (old L45-49:
   `if not defined PYTHON_CMD ( echo Python 3 is required... & pause &
   exit /b 1 )`) with `if not defined PYTHON_CMD ( ...comment...
   call :ENSURE_PYTHON_DEP & if errorlevel 1 exit /b 1 ) else ( >>
   forge-events.log echo [ts] [INFO] [deps]: Python 3 present as
   "%PYTHON_CMD%" ... )`. (The `else` value is quoted, not wrapped in
   literal parens - an empty `(%PYTHON_CMD%)` at parse time broke the
   enclosing `if()else()` block with `- was unexpected at this time`; found
   and fixed during verification.)
3. Appended four subroutines after `:LOG_PROVIDER_DETAIL` (all reached only
   via `call`; the main script's normal end at `exit /b %HERMES_EXIT%`
   never falls into them):
   - `:ENSURE_PYTHON_DEP` - `setlocal EnableDelayedExpansion`; log WARNING;
     `set /p "NF_ANS=Install it now? [Y/n] (recommended: Y): "`; `n`/`no`
     -> `:ENSURE_PYTHON_DEP_DECLINE`. Else log "approved"; if
     `NORTH_FORGE_DEP_INSTALLER` defined, `call` it (test seam); else
     `Invoke-WebRequest` the pinned `python-3.13.15-amd64.exe` to `%TEMP%`
     (download fail -> `:..._MANUAL`), then `start "" /wait "<exe>" /quiet
     InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_test=0`,
     capture `%ERRORLEVEL%`, `del` the exe. Non-zero and not 3010 -> log
     FAILURE +`:..._MANUAL`. Re-detect: `where py`/`where python`, then
     `dir /b /s "%LOCALAPPDATA%\Programs\Python\python.exe"` (PATH in the
     running window is stale), then test-only `%NORTH_FORGE_DEP_PY_EXTRA%`;
     `NORTH_FORGE_DEP_FORCE_PY_MISSING=always` also blanks the result
     (test seam for the "still missing" path). Not found -> log FAILURE
     +`:..._MANUAL`. Found -> log INFO "installed and verified", then
     `endlocal & set "PYTHON_CMD=%NF_PY_FOUND%" & exit /b 0` (canonical
     value-past-endlocal idiom).
   - `:ENSURE_PYTHON_DEP_DECLINE` - log INFO "declined", call manual help,
     `endlocal & exit /b 1`.
   - `:ENSURE_PYTHON_DEP_MANUAL` - call manual help, `endlocal & exit /b 1`.
   - `:PYTHON_DEP_MANUAL_HELP` - 3-step manual instructions +
     `https://www.python.org/downloads/windows/` + `pause`.

Static checks that constrain the `.bat`, all still pass (see Verification):
no new `set "HERMES_HOME=`; no literal `%LOCALAPPDATA%\hermes` (used
`%LOCALAPPDATA%\Programs\Python`); no `where hermes`; no `powershell` line
referencing `hermes-agent.nousresearch.com` (the new one hits `python.org`);
`"scripts\hermes-drive.ps1" cron add` count unchanged at 2; both
cron-warning `Add-Content ... [WARNING] [cron]` lines intact.

### `tests/test-dependency-check.sh` (new, Zone A, 100 lines)

6 scratch scenarios, all via `mktemp -d` + a copied launcher, `set -eu`,
`trap` cleanup, final `PASS: N ...` line - matching the style of
`tests/test-drive-hermes-install.sh` etc. Uses only the env-var seams
(`NORTH_FORGE_DEP_FORCE_PY_MISSING`, `NORTH_FORGE_DEP_INSTALLER`) and
`NORTH_FORGE_ASSEMBLE_ONLY=1` - **never removes or shadows the machine's
real Python**. Cases: (1) fast path - real Python, no prompt, `[INFO]
[deps]: Python 3 present` logged, runs past the gate; (2) `n` -> rc 1,
manual help, "operator declined" logged, installer never called; (3) Enter
(default Yes) + mock installer exit 0 + re-check finds real Python -> runs
past the gate, "approved" + "installed and verified" logged; (4) Yes +
mock installer exit 7 -> rc 1, "Python 3 installer exited 7" logged,
"(exit 7)" on screen; (5) Yes + mock installer exit 0 but `=always` keeps
re-check empty -> rc 1, "reported success but Python 3 is still not
detectable" logged; (6) non-interactive stdin + no seam -> rc 1, "no
interactive terminal" logged, no download attempted.

## Zone B findings (not fixed - reported only)

None newly found. My changes touch only Zone A / Zone C files.

Carried forward, still open, still needs a Blacksmith / Claude Project
handoff (unchanged this session):
- `README.md` + `USER_MANUAL.md` `Advanced/` path drift, and the README's
  fragile ASCII-art header / raw HTML / Mermaid diagram (both prior Claude
  Code and Codex audits flagged these; both are Zone B).
- **`CLAUDE.md` Zone A file list is stale w.r.t. the `Advanced/` move.**
  It lists `toggle-mode.bat`/`.sh`, `machine-reset.bat`,
  `provision-new-drive.ps1`, `full-drive-reset.*` at repo root, but
  CHANGELOG records they were `git mv`d into `Advanced/`. Cosmetic - the
  zone *intent* is unambiguous (they're infrastructure) and this task
  didn't touch them - but the path list should be refreshed by whoever
  maintains CLAUDE.md. Flagged, not touched (CLAUDE.md is Zone B / edited
  only via handoff).

## Verification performed

Environment: this Windows box. `python3` -> `Python 3.13.14` (real, via the
WindowsApps entry); `py` -> `C:\WINDOWS\py`; `python` ->
`C:\Program Files\Python311\python`. bash 5.2.37 (msys). No `pytest`, no
Pester.

| check | result |
|---|---|
| `bash -n launch-north-forge.sh` | clean |
| `bash -n tests/test-dependency-check.sh` | clean |
| line endings | `.sh` all-LF (600/600, 0 CR bytes), `.bat` all-CRLF (465/465), new test all-LF - match `.gitattributes` |
| `git diff --check` | no whitespace/CRLF errors |
| **`tests/test-dependency-check.sh`** | **PASS - 6/6 scenarios** |
| `tests/test-skill-assembly.sh` | PASS (6 scenarios) - runs the full `.sh` gate on the fast path |
| `tests/test-free-provider.sh` | PASS (4 cases) - full `.sh` run incl. gate; needs `</dev/null` (pre-existing: `name_validation.py`'s re-register `input()` blocks on a live non-EOF stdin - not introduced here) |
| `tests/test-launcher-hermes-home.sh` | PASS - the `python3`-sentinel test; confirms the gate's detect-only `command -v` does NOT trip the `exit 42` stub early |
| `tests/test-drive-hermes-install.sh` | PASS (6 scenarios) |
| `tests/test-drive-local-hermes.sh` | PASS |
| `tests/two-drive-hermes-isolation.sh` | PASS - full `.sh` launch x2 |
| `tests/repository-hygiene.sh` | PASS |
| `tests/reset-integration.sh` | PASS |
| `python -m unittest tests.test_launcher_hermes_home` | 4/4 OK (both regex ordering tests, POSIX + Windows) |
| `tests.test_cron_registration.CronRegistrationWarningsTest` | 2/2 OK (incl. the `.bat` static failure-handling test) |
| `tests.test_drive_hermes_contract` (both funcs) | OK |
| `.bat` gate - 5 scenarios run directly via `cmd //c` in scratch dirs | ALL CORRECT (see below) |

`.bat` scenarios exercised directly (scratch dirs,
`NORTH_FORGE_DEP_FORCE_PY_MISSING` + a mock `NORTH_FORGE_DEP_INSTALLER`
`.bat`, stdin piped):
- fast path: `forge-events.log` gets
  `[INFO] [deps]: Python 3 present as "py -3" - launch dependency check
  passed`; no prompt on screen.
- decline (`n`): screen shows the prompt + the 3-step manual help + `pause`;
  `rc 1`; log has `[WARNING] [deps]: Python 3 not found` and
  `[INFO] [deps]: operator declined the Python 3 install - exiting cleanly`.
- approve + mock installer exit 0 (`FORCE=1`, real `py` re-found): log has
  `operator approved...`, `[INFO] [deps]: Python 3 installed and verified
  (py -3)`; `PYTHON_CMD` published back past `endlocal`.
- approve + mock installer exit 7: log has
  `[FAILURE] [deps]: Python installer exited 7`; screen shows
  `The Python installer did not finish successfully (exit 7).`; `rc 1`.
- approve + mock installer exit 0 but `FORCE=always`: log has
  `[FAILURE] [deps]: installer reported success but Python 3 is still not
  detectable`; `rc 1`.

No real Python installer was ever downloaded or run. No change to this
machine's Python, PATH, or Hermes config. `.env` not present, not staged.

## What was NOT done / limitations

1. **No committed `.bat` test.** `tests/test-dependency-check.bat` was
   written then removed - `call`ing the launcher from inside a `:label`
   subroutine with `< inputfile` redirection produced
   `'launch-north-forge.bat' is not recognized` intermittently and I chose
   not to commit a flaky harness. The five `.bat` scenarios above were run
   by hand and are reproducible; a robust `.bat` harness is a reasonable
   follow-up but the launcher logic is verified.
2. **`.bat` has no non-interactive guard**, unlike the `.sh` (`[ -t 0 ]`).
   Batch cannot portably tell "user pressed Enter" from "stdin is EOF" -
   `set /p` leaves the var unchanged in both cases. So a non-interactive
   `.bat` invocation with Python missing and no `NORTH_FORGE_DEP_INSTALLER`
   would attempt the real download (and, on failure, exit 1 cleanly with
   the manual message). Mitigations: a double-clicked launcher is always
   interactive; the test seam covers CI; a failed unattended download
   still exits cleanly. Flagged for a second opinion.
3. **macOS/Linux auto-install needs sudo** (official `.pkg` / package
   managers have no per-user mode). The prompt says so before running.
   Only Windows is fully elevation-free. If that's not acceptable for the
   field, the "portable Python on the drive" option (below) is the way to
   remove sudo entirely on POSIX too.
4. **Real end-to-end install not run** on any OS (task said not to, and
   this box already has Python). Verified at syntax + scratch-scenario +
   mock-install level. The python.org URLs and silent flags are confirmed
   against python.org / documented behaviour, not against an actual
   install on a Python-less machine.
5. **macOS `python3` stub caveat (pre-existing, not touched):** on macOS
   12.3+ `command -v python3` finds `/usr/bin/python3` even with no real
   Python (it's a Command Line Tools shim). The gate would treat that as
   "present" - same as the old `command -v python3` check did. Detecting
   the stub would mean executing it, which conflicts with the
   detect-only rule the `test-launcher-hermes-home.sh` sentinel needs.
   Left as-is.
6. **Windows Microsoft Store `python.exe` alias (pre-existing, not
   touched):** if `where python` resolves only the 0-byte
   `WindowsApps\python.exe` alias, `PYTHON_CMD=python` is set and the gate
   is skipped; `name_validation.py` would then pop the Store. The
   detection block (`where py` first, then `where python`) is unchanged
   from before - out of scope for this task.

## Flagged for the North Forge GPT - the "bundle portable Python" question (NOT implemented)

Per the task, flagging back rather than starting: bundling a portable /
embeddable Python (Windows embeddable zip; a relocatable framework or a
`uv`-managed Python on macOS/Linux) directly on the 128 GB drive would
remove the system-install step entirely, on any machine, regardless of
what's already there - and would also remove the macOS/Linux **sudo**
requirement that the current guided-install path cannot avoid. It is a
larger architecture change (the launchers, `name_validation.py`'s
invocation, the `.hermes.md` assembly step, and `.gitignore` would all
need to learn about a drive-local interpreter; exFAT has no symlinks and no
exec bit, which the embeddable zip sidesteps but a framework build does
not). Recommend an explicit go-ahead before it's begun. The
check-and-prompt flow shipped here is the smaller fix and stands on its
own; the two are compatible (the prompt becomes a rare fallback if the
bundled interpreter is ever missing).

## Commits made this session

To be created and pushed as one commit:
- `launch-north-forge.sh`, `launch-north-forge.bat` (Zone A - the
  dependency gate), `tests/test-dependency-check.sh` (Zone A - new test),
  `CHANGELOG.md` (Zone C - `### Added` entry), and this report
  (`logs/CLAUDE_CODE_LAST_AUDIT.md`, Zone A).

## Uncertain / flagged for primary GPT review

1. **Deliberate deviation: Node.js is not prompted for.** The task said
   "at minimum Python 3 and Node.js"; the investigation it asked for shows
   Node is never a launch-time dependency (engine bundles its own).
   Confirm this call is right, or say if a Node prompt is wanted anyway.
2. **`.bat` non-interactive guard gap** (limitation #2 above) - is the
   asymmetry with `.sh` acceptable, or should the `.bat` refuse to
   auto-install when it can't confirm interactivity (e.g. gate on
   `%CMDCMDLINE%` containing `/c`, which is imperfect)?
3. **Pinned Python `3.13.15`.** Newest 3.13 with binary installers, inside
   Hermes's `<3.14`. If Hermes later widens to 3.14 or you'd rather track
   "latest 3.x" dynamically, that's a one-line change per launcher - say
   which you want.
4. **No committed `.bat` test** (limitation #1). If a committed `.bat`
   harness matters, I can take another pass - the plumbing issue is
   `call`ing the launcher from a subroutine with input redirection.
5. **macOS/Linux sudo** in the guided path (limitation #3). Unavoidable
   with official installers; the "portable Python" option removes it.
6. **Carried over, untouched:** README/USER_MANUAL `Advanced/` drift and
   README header fragility (Zone B, need a handoff); `CLAUDE.md` Zone A
   path list stale after the `Advanced/` move; the exFAT `[-x]` /
   POSIX-off-exFAT question (F4 from the `ecd54e3` audit) still open.

## Status

Needs primary GPT review.
- Guided Python 3 install added to both launchers; investigation confirmed
  Python is the only real launch dependency and Node is not; Windows path
  needs no admin, macOS/Linux state the sudo requirement up front; fast
  path unchanged in cost; every step logged; clean exit on decline/failure.
- `tests/test-dependency-check.sh` (6/6) added; full existing suite (9
  shell + launcher `.py` static) green; `.bat` gate verified via 5 direct
  scratch runs.
- Open decisions for the GPT: the Node omission, the `.bat` non-interactive
  gap, the pinned version, and whether to green-light the drive-bundled
  portable Python as the follow-on.
