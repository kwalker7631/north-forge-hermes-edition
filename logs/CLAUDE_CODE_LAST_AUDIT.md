# Claude Code Session Audit

Timestamp: 2026-09-05 20:23 EDT (America/New_York), on the `E:` drive clone
(`E:\north-forge-hermes-edition`). Same calendar session as the preceding
report (f97e52f); this is the follow-up work order.

Requested task (verbatim intent from the North Forge GPT / Kenneth, via the
`/auto-mode-setup` prompt): resolve F2 from the previous audit (the
executable-resolver divergence between `scripts/ensure-hermes.sh`/`.ps1` and
`scripts/hermes-drive.sh`/`.ps1`) **by investigation, not by guessing and
not by asking for a live-install report first**:
1. Locate and read the actual Hermes installer that `ensure-hermes.*`
   downloads; determine definitively what directory layout it produces
   (venv at `hermes-agent/venv/bin/hermes`? `.venv`? flat `venv/`?
   something else). If network is genuinely blocked, say so rather than
   guess.
2. Once the real layout is known, reconcile both resolver files to a single
   correct candidate list - fix whichever file(s) are wrong, do NOT union
   both guesses together.
3. If the layout genuinely cannot be determined even from installer source,
   say so and then ask for a real install's on-disk path as a fallback -
   but only after confirming the static source doesn't already answer it.

Also apply, as low-risk pre-approved changes:
- F1: restructure the `launch-north-forge.sh` `.hermes.md` heredoc so it is
  the `if` condition directly (per the fix drafted in the f97e52f report).
- F3: delete the dead `:HERMES_READY` label in `launch-north-forge.bat`.

QUICK CHECK required: F2 verified against whatever ground truth was found;
F1 re-run through the seti.sh-style reproduction; F3 confirmed harmless;
`.env` not staged; commit and push.

## Outcome

- **F2: RESOLVED by investigation.** Network is available this session
  (unlike every prior session on this drive - `curl` to
  `hermes-agent.nousresearch.com` returned HTTP 200 this time, not 403).
  Downloaded and read the real `install.sh` (3890 lines) and `install.ps1`
  (5063 lines), plus `NousResearch/hermes-agent` `pyproject.toml`
  `[project.scripts]` and the file mode of the checked-in `./hermes`
  launcher. Ground truth established; all four resolver lists rewritten to
  one identical, installer-grounded order per platform. Speculative entries
  removed, not unioned. `bash -n` + PowerShell AST parse clean; five POSIX
  shell integration tests + `test_drive_hermes_contract.py` pass.
- **F1: FIXED.** `launch-north-forge.sh` heredoc is now the `if` condition
  (`if ! python3 - "$MODE" << 'PYEOF' ... PYEOF` / `then ... fi`). Verified
  against the real extracted block, both cases.
- **F3: FIXED.** Six dead lines removed from `launch-north-forge.bat`.
- **NEW finding F4 raised (not fixed):** on a POSIX-off-exFAT first run the
  `[ -x ]` guards in both resolvers can reject a *correct* install, because
  exFAT cannot store the executable bit that the venv console script and
  the checked-in `./hermes` (upstream mode 100755) both rely on. This needs
  a change to the `exec` line (route through the venv interpreter when the
  target is not `-x`) plus a real POSIX+exFAT test rig, so it is flagged
  for direction rather than shipped half-done. Detail below.

Zone: all six edited files are Zone A (`launch-north-forge.sh`,
`launch-north-forge.bat`, `scripts/*.sh`, `scripts/*.ps1`) plus one Zone C
file (`CHANGELOG.md`). No Zone B file touched. `.env` is not present on
this drive and was never staged.

---

## Session Start Protocol results

```text
SESSION START CHECK
Pulled: git pull -> "Already up to date." HEAD = origin/main = f97e52f "Audit report: Hermes-surface review (\"Hermes update\" session)". No new remote commits since the prior turn's push.
Last audit read: Yes - f97e52f. It made no code changes and flagged F1 (sh heredoc dead branch under set -e), F2 (executable-resolver divergence, impact conditional on an unobservable upstream fact), F3 (dead :HERMES_READY label), plus five carried-over non-Hermes items. This session's task is "resolve F2 by investigation" + apply F1 + F3.
Uncommitted at start: None (git status clean).
.gitignore: OK (unchanged since f97e52f - .env, *.env, .forge-mode, /North Forge.lnk, /.hermes/, /.hermes-home/, .hermes.md all present).
hermes doctor: Not run - hermes not installed on this machine (command -v hermes -> not found). Unchanged.
Project skills: hermes not installed - cannot list. Not re-inspected this session (f97e52f covered the skill surface and found it sound).
Network: AVAILABLE this session. curl https://hermes-agent.nousresearch.com/install.sh -> HTTP 200 with the real script body. Prior sessions recorded 403 (see logs/HERMES_CRON_GATEWAY_HOME_AUDIT.md). This is what made F2 resolvable without a live install.
```

## F2 - ground truth from the upstream installers

### What was fetched (all HTTP 200 this session)

| Source | Saved to scratch | Size |
|---|---|---|
| `https://hermes-agent.nousresearch.com/install.sh` | `scratchpad/install.sh` | 3890 lines |
| `https://hermes-agent.nousresearch.com/install.ps1` | `scratchpad/install.ps1` | 5063 lines |
| `https://raw.githubusercontent.com/NousResearch/hermes-agent/main/pyproject.toml` | (grepped) | - |
| `https://api.github.com/repos/NousResearch/hermes-agent/git/trees/main` | (grepped for `hermes` blob mode) | - |
| `https://raw.githubusercontent.com/NousResearch/hermes-agent/main/hermes` | (head) | - |

### POSIX (`install.sh`), default `USE_VENV=true`, non-root, `HERMES_HOME` set

North Forge always sets `HERMES_HOME` (`ensure-hermes.sh` L20:
`export HERMES_HOME="$home"`, and runs the installer with
`HERMES_HOME="$stage"` at L75).

- L48: `HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"`.
- `resolve_install_layout()` (L399-453). Non-root, any OS (L403-404, L453):
  `INSTALL_DIR="$HERMES_HOME/hermes-agent"`. The `hermes` command link goes
  in `$HOME/.local/bin` - **outside `$HERMES_HOME`**.
- `setup_venv()` (L1712-): CWD is `$INSTALL_DIR` (L1661 `cd "$INSTALL_DIR"`).
  Termux uses `"$PYTHON_PATH" -m venv venv` (L1726); desktop/server uses
  `uv` (L1738 "uv creates the venv..."). Either way the directory is
  literally `venv` (never `.venv`), i.e. **`$HERMES_HOME/hermes-agent/venv`**.
- `setup_path()` (L2044-): with `USE_VENV=true`,
  `HERMES_BIN="$INSTALL_DIR/venv/bin/python"` and
  `HERMES_ENTRYPOINT="$INSTALL_DIR/hermes"` (L2050-2051). The user-facing
  `hermes` shim is written to `$command_link_dir/hermes` =
  `$HOME/.local/bin/hermes` (L456-463, L2072-2104) as a bash script that
  does `exec "$HERMES_BIN" "$HERMES_ENTRYPOINT" "$@"`.
- `pyproject.toml` L391-392: `[project.scripts]` / `hermes = "hermes_cli.main:main"`.
  A uv/pip install of that package therefore also produces the console
  script **`$HERMES_HOME/hermes-agent/venv/bin/hermes`** (this is exactly
  the script the installer's own comment at L2086-2089 says it deliberately
  bypasses for the public shim - so it exists).
- `git ls-tree` of `NousResearch/hermes-agent@main`: `"path": "hermes",
  "mode": "100755"` - the checked-in `./hermes` launcher **is executable**
  in the repo, shebang `#!/usr/bin/env python3`, body
  `from hermes_cli.main import main; main()`. So after a clone,
  **`$HERMES_HOME/hermes-agent/hermes`** exists and is `-x` on a normal
  filesystem (see F4 for exFAT).
- `$HERMES_HOME/bin/` on POSIX holds the **managed `uv`** (L566:
  `_managed_uv="$HERMES_HOME/bin/uv"`, L575-576), **not** `hermes`.

POSIX executables that exist inside `$HERMES_HOME` after a real install:
`hermes-agent/venv/bin/hermes` (console script), `hermes-agent/venv/bin/python`,
`hermes-agent/hermes` (checked-in launcher, `-x` unless on exFAT).
Nothing at `$HERMES_HOME/bin/hermes` or `$HERMES_HOME/hermes`.

### Windows (`install.ps1`), default venv, `HERMES_HOME` set

`ensure-hermes.ps1` runs it with `$env:HERMES_HOME = $stage` (L56) and no
`-InstallDir`.

- L33: `$HermesHome = $env:HERMES_HOME` (else `$env:LOCALAPPDATA\hermes`).
- L34 / L351-354: `$InstallDir = "$env:HERMES_HOME\hermes-agent"` when
  `HERMES_HOME` is set. So **`$InstallDir = <.hermes-home>\hermes-agent`**.
- `Install-Venv` (L2553-): `Push-Location $InstallDir`; L2646
  `$venvPrefix = ...Join-Path $InstallDir "venv"`; L2620/2624 comments
  ("...from `venv\Scripts\`", "the launcher CLI (hermes.exe)"). venv at
  **`$InstallDir\venv`**, console script **`$InstallDir\venv\Scripts\hermes.exe`**
  (L3156 `$requiredSource = Join-Path (Join-Path $Root "venv\Scripts") "hermes.exe"`).
- `Set-PathVariable` (L3197-) / `Install-HermesCommandLaunchers` (L3144-):
  `$hermesBin = "$HermesHome\bin"`; the function copies
  `venv\Scripts\hermes.exe` -> **`$HermesHome\bin\hermes.exe`** for a normal
  venv, or writes **`$HermesHome\bin\hermes.cmd`** (a `@echo off` delegator
  to the in-venv exe) when `pyvenv.cfg` has `relocatable = true` (L3169-3183).
  The comment at L3211-3213 confirms older layouts used `venv\Scripts` and
  `hermes-agent\bin` on PATH; the **current** layout is `$HermesHome\bin`.
- L4539: the installer's own gateway config uses
  `"$InstallDir\venv\Scripts\hermes.exe"` directly.
- `$HermesHome\bin\uv.exe` is the managed uv (L750), not hermes.

Windows launchers that exist inside `$HERMES_HOME` after a real install:
`hermes-agent\venv\Scripts\hermes.exe` (console script), and
`bin\hermes.exe` **or** `bin\hermes.cmd` (staged by Set-PathVariable).

### The divergence, measured against ground truth

Before this session:

| file | POSIX candidates | Windows candidates |
|---|---|---|
| `ensure-hermes.sh` (validator) | `bin/hermes`, `hermes`, `hermes-agent/hermes` | - |
| `hermes-drive.sh` (runtime) | `hermes-agent/venv/bin/hermes`, `hermes-agent/.venv/bin/hermes`, `venv/bin/hermes`, `bin/hermes` | - |
| `ensure-hermes.ps1` (validator) | - | `Scripts\hermes.exe`, `bin\hermes.exe`, `hermes.exe` |
| `hermes-drive.ps1` (runtime) | - | `hermes-agent\venv\Scripts\hermes.exe`, `hermes-agent\.venv\Scripts\hermes.exe`, `venv\Scripts\hermes.exe`, `Scripts\hermes.exe` |

- POSIX validator: **omitted the real primary** (`hermes-agent/venv/bin/hermes`).
  It could only pass via `hermes-agent/hermes` (the checked-in launcher).
  `$root/bin/hermes` and `$root/hermes` are never produced by `install.sh`
  on POSIX.
- POSIX runtime: had the real primary first, but `.venv/` and flat `venv/`
  are pure guesses the installer never creates.
- Windows validator: `bin\hermes.exe` **does** match (Set-PathVariable), so
  Windows validation was working for the common case - but it omitted the
  original venv console script and the `bin\hermes.cmd` relocatable form.
- Windows runtime: matched `hermes-agent\venv\Scripts\hermes.exe` (real),
  but omitted `bin\hermes.exe` / `bin\hermes.cmd` (what actually goes on
  PATH), and carried three guesses (`.venv\`, flat `venv\`, bare `Scripts\`).

Net: the validator and the runtime wrapper were checking for **different
files**. On any install where only one of the two sets is present they
would disagree - `ensure_drive_hermes` reports the install valid, then the
next call (`hermes skin use north-forge`, `.sh` L366 via the `hermes()`
function -> `hermes-drive.sh`; `.bat` L265 via `%HERMES_CMD%` ->
`hermes-drive.ps1`) fails.

### The fix - one reconciled list per platform, in both files

POSIX (`ensure-hermes.sh` `hermes_executable()` and `hermes-drive.sh` loop),
identical order:
```
$root/hermes-agent/venv/bin/hermes    # uv/pip console script - the real primary
$root/bin/hermes                       # --no-venv fallback; also the North Forge test-fixture stub path
$root/hermes-agent/hermes             # checked-in launcher (upstream mode 100755)
```
Removed: `$root/hermes` (never produced), `hermes-agent/.venv/bin/hermes`
and flat `venv/bin/hermes` (guesses).

Windows (`ensure-hermes.ps1` `Get-HermesExe` and `hermes-drive.ps1`
`$candidates`), identical order:
```
$Root\hermes-agent\venv\Scripts\hermes.exe   # venv console script - primary/original
$Root\bin\hermes.exe                          # staged launcher on PATH (normal venv)
$Root\bin\hermes.cmd                          # staged launcher on PATH (relocatable venv)
```
Removed: bare `Scripts\hermes.exe`, bare root `hermes.exe`,
`hermes-agent\.venv\Scripts\hermes.exe`, flat `venv\Scripts\hermes.exe`
(guesses).

`$root/bin/hermes` is kept on POSIX deliberately, not as a guess: every
North Forge POSIX test fixture stubs the fake Hermes there
(`tests/test-drive-local-hermes.sh` L35, `test-drive-hermes-install.sh`
L13, `test-free-provider.sh` L21, `test_cron_registration.py` L103,
`two-drive-hermes-isolation.sh` L83), and it is a harmless real fallback
for a `--no-venv` install. Dropping it would break those tests for no gain.

This is a tightening to installer ground truth, not a "blind union" - the
lists got *shorter*, and every remaining entry is a path some documented
installer branch actually creates (or, for `bin/hermes` on POSIX, the
project's own fixtures).

## F1 - `launch-north-forge.sh` heredoc under `set -e`

Before (L197, L226-229):
```sh
python3 - "$MODE" << 'PYEOF'
...
PYEOF
if [ $? -ne 0 ]; then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi
```
Under `set -e` a bare `python3 - <<EOF` that exits non-zero terminates the
script at that command; `if [ $? -ne 0 ]` on the next line never runs.
Reproduced last session; re-confirmed this session against the **real
extracted block** (`awk`-sliced straight out of `launch-north-forge.sh`):

```
CASE B: force >=20000 chars
  .hermes.template.md -> 20291 bytes; assembled 21761 chars
  output:
    FATAL: assembled .hermes.md is 21761 chars - at or over the 20,000-char context-file ceiling.
    Hermes would silently drop the middle of the file. Trim the template/banner/menu before launching.
    Launch aborted: .hermes.md was not written.     <-- NOW PRINTS (was unreachable)
  exit=1                                            <-- PASS
  .hermes.md not written                            <-- PASS
  did not fall through to continuation              <-- PASS

CASE A: normal size
  .hermes.md written (18923 bytes), "CONTINUATION REACHED", exit=0   <-- PASS
```

After:
```sh
if ! python3 - "$MODE" << 'PYEOF'
...
PYEOF
then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi
```
`if ! <cmd>` suppresses `errexit` for `<cmd>` and the `then` branch is
reached exactly when `<cmd>` fails. Six-line explanatory comment added
above the `if`. `bash -n launch-north-forge.sh` -> OK.

## F3 - dead `:HERMES_READY` label removed

`launch-north-forge.bat` L362-367 (a blank line + a 5-line subroutine) were
deleted. Confirmed dead before removal:
`grep -nE "call :HERMES_READY|goto :?HERMES_READY" launch-north-forge.bat`
-> no match; `grep -nE 'set +"?HERMES_EXE' launch-north-forge.bat` -> no
match (the `%HERMES_EXE%` it referenced was never assigned). After removal:
`grep -nE "HERMES_READY|HERMES_EXE" launch-north-forge.bat` -> nothing.
File now ends cleanly at the `:LOG_PROVIDER_DETAIL` subroutine.
`tests/test_drive_hermes_contract.py` (which parses the `.bat`) still passes.

## F4 (NEW) - exFAT strips the exec bit, so the `[ -x ]` guards can reject a valid POSIX install

Not fixed - flagged for direction.

The drive is exFAT on purpose (`launch-north-forge.sh` L73-77:
"exFAT ... can't store the executable permission bit"). Both resolvers gate
on `[ -x "$candidate" ]` (`ensure-hermes.sh` L7, `hermes-drive.sh` post-fix
L23). But on the exFAT drive:
- the checked-in `hermes-agent/hermes` arrives from the clone as mode
  100755 upstream but **loses `+x`** on exFAT;
- the venv console script `hermes-agent/venv/bin/hermes` is created *on the
  exFAT drive* by uv/pip and also **cannot carry `+x`**.

So on a macOS/Linux first run straight off the stick, `hermes_executable()`
finds no `-x` candidate -> `hermes_home_valid` false -> `ensure_drive_hermes`
returns 22 "installation failed or did not pass validation", **even though
the install succeeded**. And `hermes-drive.sh` would `fail` with exit 72 at
`hermes skin use`.

The safe fix is not a one-liner: `hermes-drive.sh` L28 `exec "$HERMES_EXE"
"$@"` on a non-`+x` python console script fails with "Permission denied", so
the guard would have to fall back to `[ -f ]` **and** the exec would have to
route through `$HERMES_HOME/hermes-agent/venv/bin/python` (or the checked-in
`./hermes` via `python3`). That is a behavioural change to the runtime
wrapper that wants its own POSIX+exFAT test rig, which this Windows box
cannot provide. Related open question: whether a `uv`/stdlib venv even
builds correctly *on* exFAT (no symlinks) - `archive/setup-thumbdrive.ps1`
L10-11 already notes "exFAT ... can't hold the symlinks a venv needs", which
suggests the POSIX-off-exFAT install story has a deeper problem than the
resolver lists. Recommend the North Forge GPT / Blacksmith decide whether
POSIX-off-exFAT is a supported first-run path at all before more code is
written against it.

Windows is unaffected by F4 - `.exe`/`.cmd` are executable by extension and
`Test-Path -PathType Leaf` doesn't check a bit.

## Files inspected / changed

Changed (Zone A):
- `launch-north-forge.sh` - F1. `+9 / -2`. `bash -n` OK.
- `launch-north-forge.bat` - F3. `+0 / -6`. CRLF preserved (git shows a
  normal line diff).
- `scripts/ensure-hermes.sh` - F2 POSIX validator list. `+14 / -1`. `bash -n` OK.
- `scripts/hermes-drive.sh` - F2 POSIX runtime list. `+10 / -1`. `bash -n` OK.
- `scripts/ensure-hermes.ps1` - F2 Windows validator list. `+14 / -2`.
  PowerShell AST parse OK.
- `scripts/hermes-drive.ps1` - F2 Windows runtime list. `+11 / -3`. AST parse OK.

Changed (Zone C):
- `CHANGELOG.md` - one new `### Fixed` block under `## [Unreleased] -
  2026-09-05` describing F2/F1/F3 in plain language. `+5 / -0`.

Read this session (not changed):
- `scratchpad/install.sh` (3890 lines) and `scratchpad/install.ps1` (5063
  lines) - the real upstream installers, downloaded fresh.
- `NousResearch/hermes-agent` `pyproject.toml` `[project.scripts]`, git tree
  (mode of `hermes`), raw `hermes` head.
- `scripts/assemble-skills.ps1`, `tests/test-free-provider.sh`,
  `tests/test-drive-local-hermes.sh`, `tests/test_cron_registration.py`,
  `tests/test_drive_hermes_contract.py`, `tests/test_launcher_hermes_home.py`,
  `tests/two-drive-hermes-isolation.sh` (to confirm no test hard-codes a
  candidate path that the reconciliation would break).
- `ATTRIBUTION.md`, `archive/setup-thumbdrive.ps1`,
  `logs/HANDOFF_2026-09-05_SESSION_CHANGES.md` (the "`./venv/Scripts/python.exe`"
  line at L142-144 - an earlier session that had a live Windows install and
  invoked the venv interpreter directly, an independent corroboration of the
  `$InstallDir\venv\Scripts` layout).

## Verification performed (QUICK CHECK)

| Check | Result |
|---|---|
| `bash -n launch-north-forge.sh` | OK |
| `bash -n scripts/ensure-hermes.sh` | OK |
| `bash -n scripts/hermes-drive.sh` | OK |
| PowerShell `Parser::ParseFile` on `scripts/ensure-hermes.ps1` | OK, no errors |
| PowerShell `Parser::ParseFile` on `scripts/hermes-drive.ps1` | OK, no errors |
| POSIX validator list == POSIX runtime list (order + entries) | identical (3 entries) |
| Windows validator list == Windows runtime list (order + entries) | identical (3 entries) |
| F1 reproduction, forced >=20000 chars, real extracted block | "Launch aborted..." prints, exit 1, no `.hermes.md`, no fall-through - PASS |
| F1 reproduction, normal size, real extracted block | `.hermes.md` written, continuation reached, exit 0 - PASS |
| F3: `HERMES_READY` / `HERMES_EXE` still in `.bat`? | no - gone |
| `bash tests/test-drive-local-hermes.sh` | rc=0 - both sub-cases PASS |
| `bash tests/test-drive-hermes-install.sh` | rc=0 - "6 drive-local Hermes scratch scenarios" PASS |
| `bash tests/two-drive-hermes-isolation.sh` | rc=0 PASS |
| `bash tests/test-free-provider.sh` | rc=0 - "all four isolated fake-Hermes provider cases" PASS |
| `bash tests/test-skill-assembly.sh` | rc=0 - "6 scratch skill-assembly scenarios" PASS |
| `tests/test_drive_hermes_contract.py` (both funcs, run directly) | both ok |
| `tests/test_launcher_hermes_home.py` (4 tests, unittest) | 4 ok |
| `tests/test_cron_registration.py` | 2 ok; 2 ERROR = `OSError [WinError 193]` spawning `scripts/hermes-drive.sh` as a subprocess on Windows (no shebang support). Pre-existing environmental limit, fails at process-spawn before `hermes-drive.sh` runs a single line - NOT caused by this change. |
| `tests/test_name_validation.py` | 3 ok; 2 not-run = need pytest fixtures (`tmp_path`, `monkeypatch`) my ad-hoc runner can't supply. Unrelated file, untouched. |
| `.env` staged? | No - `.env` not present on this drive; `git status` shows only the 7 intended files. |

pytest is not installed on this machine (`No module named pytest`); the
`.py` tests were run via `unittest` where class-based and by direct function
invocation where pytest-style.

## Commits made this session

To be created and pushed as one commit:
- `launch-north-forge.sh`, `launch-north-forge.bat`, `scripts/ensure-hermes.sh`,
  `scripts/ensure-hermes.ps1`, `scripts/hermes-drive.sh`,
  `scripts/hermes-drive.ps1` (Zone A - F2 resolver reconciliation + F1 + F3),
  `CHANGELOG.md` (Zone C entry), and this report
  (`logs/CLAUDE_CODE_LAST_AUDIT.md`, Zone A).

## Uncertain / flagged for primary GPT review

1. **F4 (new).** The resolver lists are now installer-correct, but on a
   macOS/Linux first run *off the exFAT stick* the `[ -x ]` gate in both
   files can still reject a valid install because exFAT drops the exec bit.
   Fixing it right means a fallback to `[ -f ]` plus routing `exec` through
   the venv Python, and there is an upstream question of whether a venv
   builds on exFAT at all (no symlinks). Decision needed: is
   POSIX-off-exFAT a supported first-run path? If yes, F4 needs its own
   change + a real test rig. If the drive is Windows-first in practice and
   POSIX use means "copy the repo onto a real filesystem", F4 is a
   documentation note, not a code change.
2. **Windows relocatable-venv form.** `bin\hermes.cmd` is now in both
   Windows lists. `hermes-drive.ps1` L40 `& $hermes @args` runs a `.cmd`
   fine and `exit $LASTEXITCODE` after it is correct. I could not exercise
   this against a real relocatable venv (none on this box) - it is grounded
   in `install.ps1` L3169-3183 only.
3. **`hermes-agent/hermes` as POSIX candidate #3.** It is a `python3`
   shebang script, mode 100755 upstream. `hermes-drive.sh` would
   `exec "$HERMES_EXE" "$@"` on it directly; that works only if the clone
   preserved `+x` (true on ext4/APFS, false on exFAT - see F4). It is the
   last-resort entry and `ensure-hermes.sh` already trusted it, so the two
   files are now consistent about it, but it is the weakest of the three.
4. **Carried over from f97e52f, untouched:** `.gitattributes` ratification;
   real-hardware confirmation of the renormalised `.sh`; README
   `img.shields.io` dependency; dropped "Why this exists" paragraph; the
   `Advanced/` path gap in README.md + USER_MANUAL.md needing a
   byte-for-byte Zone B handoff. None are in the Hermes surface.
5. **No `--configure-free-provider` / end-to-end launch run.** `hermes` is
   not installed here and there is no model key on this drive. The F2
   change is verified at parse + candidate-list + fixture-test level, not
   by a real `hermes skin use` against a real install.

## Status

Needs primary GPT review.
- F2 resolved by investigation against the live upstream installers; both
  validator/wrapper pairs now use one identical installer-grounded list per
  platform; speculative paths removed, not unioned. Tests green.
- F1 and F3 fixed and verified.
- F4 raised: the `[ -x ]` gate vs exFAT is the remaining real risk on a
  POSIX-off-exFAT first run. Needs a scope decision before code.
