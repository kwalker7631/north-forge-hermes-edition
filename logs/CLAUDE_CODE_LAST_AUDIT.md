# Claude Code Session Audit

Timestamp: 2026-09-05 20:04 EDT (America/New_York), on the `E:` drive clone
(`E:\north-forge-hermes-edition`). Session start 2026-09-05 ~19:53 EDT.

Requested task: Kenneth's prompt, verbatim - "Hermes update". No content
pasted with it, no named Zone B target, no handoff file. Read as ambiguous
and clarified via a multiple-choice question. Kenneth answered "All three
1 2 3", i.e. all of:
1. A Zone B handoff is incoming (revised `.hermes.template.md` and/or a
   `skills-source/**` file) - place it byte-for-byte after the
   diff-before-placement check.
2. Status review - full read-only audit of the current Hermes surface
   (template, 16 skills, install/launch path, open flags).
3. Zone A plumbing fix - reproduce + fix + commit a specific bug in the
   Hermes install/launch path, given a symptom.

## Outcome

- Part 1 (Zone B handoff): NOTHING PLACED. No content was pasted this
  session. Standing ready; nothing to diff or commit. No Zone B file was
  edited.
- Part 2 (status review): DONE. Full read of the Hermes surface. Three
  Zone A observations (F1, F2, F3 below), none of which is a reproducible
  first-run break on its own; the rest of the surface verified sound.
- Part 3 (Zone A plumbing fix): NO FIX MADE. Kenneth supplied no symptom,
  and nothing found this session is a confirmed, reproducible first-run
  break that CLAUDE.md's Zone A bar ("actually reproduce it first", "don't
  invent work") authorises fixing unprompted. F2 is a genuine internal
  inconsistency but its impact is conditional on an upstream fact that
  cannot be checked in this environment. F1 and F3 do not break first run.
  All three are flagged below for primary GPT / Blacksmith direction.

No commits this session except this audit report itself (Zone A standing
authorisation).

---

## Session Start Protocol results

```text
SESSION START CHECK
Pulled: Already up to date (git pull -> "Already up to date."; HEAD = origin/main = c7cc3b03f210675770dfe80e7831f8f83088fe9b, short c7cc3b0, "Audit report: rewrite to cover both session tasks (CRLF fix b768e29 + README placement 4fd9fa6)", committed 2026-09-05 19:08:26 -0400). git branch -a: only main + origin/main + origin/HEAD. No open PRs checked this session (offline; gh not exercised), but git log origin/main == local main, so no pending merge.
Last audit read: Yes - prior session ran two tasks: Zone A add of .gitattributes (b768e29, fixes CRLF-broken macOS/Linux first run) and a Zone B placement of a "blinged" README.md (4fd9fa6, byte-for-byte per an explicit in-session "Place as-is + push"). Prior Status: "Needs primary GPT review". Still-open flags from that report, none touched this session: (1) ratify .gitattributes as a Zone A addition or revert; (2) confirm the renormalized launch-north-forge.sh actually runs on real macOS/Linux hardware (this box is Git-for-Windows bash, which tolerates CRLF, so the `bash script.sh` parse-failure path was asserted not reproduced there); (3) README.md now pulls 5 img.shields.io badges on render, breaking the repo's otherwise self-contained stance; (4) the "Why this exists" rationale paragraph was dropped from README with no replacement; (5) the b744b10 Advanced/ path gap in README.md's file tree + the BLOCKED USER_MANUAL.md Advanced/ run-instructions still need a byte-for-byte Zone B handoff and now sit on top of the decorative README commit.
Uncommitted at start: None. git status -> "nothing to commit, working tree clean". git diff and git diff --staged both empty.
.gitignore: OK. Confirmed present and correct: .env (L9), *.env (L10), .forge-mode (L17), /North Forge.lnk (L25), /.hermes/ (L32), /.hermes-home/ (L33), .hermes.md (L34), /.hermes-home/logs/ (L51). .hermes/ and .hermes-home/ (the launch-generated runtime dirs) both ignored; .hermes.md (the assembled context file) ignored.
hermes doctor: Not run - hermes not installed on this machine (command -v hermes -> "hermes: not found"), consistent with every prior session on this drive and with logs/HERMES_CRON_GATEWAY_HOME_AUDIT.md.
Project skills: hermes not installed - cannot list. Static inspection of skills-source/ done instead (see below).
```

git config core.autocrlf on this machine: `true` (unchanged from prior
session; this is the setting the b768e29 `.gitattributes` fix exists to
neutralise for `*.sh`). `bash -n launch-north-forge.sh` this session ->
parse OK, so the CRLF renormalisation from b768e29 is still holding in this
working tree.

## Files inspected

Zone A (infrastructure - read + analysed, none modified):
- `launch-north-forge.sh` - full read, 424 lines / 21364 bytes. Traced the
  entire Hermes path: HERMES_HOME pin (L10), write probe (L23-29), skill
  assembly `assemble_skills()` (L110-190), template substitution Python
  heredoc (L197-225), `. scripts/ensure-hermes.sh` + `ensure_drive_hermes
  "$PWD"` (L235-236), `hermes()` wrapper function (L241), provider-choice
  block (L243-323), skin copy + `hermes skin use`/`skin list` (L360-368),
  `hermes skills trust .` (L374), cron self-heal (L376-411), final
  `hermes` launch + exit logging (L413-423).
- `launch-north-forge.bat` - full read, 368 lines / 21091 bytes. Same
  trace on the Windows side: HERMES_HOME pin (L10), write probe (L22-30),
  PYTHON_CMD detection (L42-49), `assemble-skills.ps1` call (L141-145),
  template substitution inline PowerShell (L155-169), `ensure-hermes.ps1`
  call (L175-180), PATH prepend (L181), `HERMES_CMD` definition (L194),
  provider-choice block + `:CONFIGURE_FREE_PROVIDER` / `:LOG_PROVIDER_DETAIL`
  subroutines (L196-361), skin + `skills trust` (L259-273), cron self-heal
  (L275-308), final `%HERMES_CMD%` launch (L310-318), and the trailing
  `:HERMES_READY` label (L363-367).
- `scripts/ensure-hermes.sh` - full read, 96 lines / 5382 bytes.
- `scripts/ensure-hermes.ps1` - full read, 73 lines / 5391 bytes.
- `scripts/hermes-drive.sh` - full read, 29 lines / 1215 bytes.
- `scripts/hermes-drive.ps1` - full read, 42 lines / 1904 bytes.
- `scripts/assemble-skills.ps1` - full read, 62 lines / 3507 bytes.
- `scripts/name_validation.py` - full read, 146 lines / 5399 bytes.
- `skins/north-forge.yaml` - full read, 78 lines / 6421 bytes.
- `AGENTS.md` - full read, 98 lines / 5556 bytes.
- `.gitignore` - grep of the key entries.
- `logs/CLAUDE_CODE_LAST_AUDIT.md` (prior report), `logs/FORGE_EVENT_LOG.md`,
  `logs/HERMES_CRON_GATEWAY_HOME_AUDIT.md` - full reads.
- `logs/CODEX_FULL_SANDBOX_REAUDIT_2026-09-05.md` - partial (lines 1-75 +
  grep) to check whether the F2 resolver divergence was already recorded
  (it was not - see F2).
- `tests/test_drive_hermes_contract.py` - full read, 36 lines.
- `tests/test-drive-local-hermes.sh` - full read, 82 lines.
- Directory listings: `mode-blocks/`, `skills-source/` (16 SKILL.md),
  `scripts/` (8), `tests/` (18), `skins/`, `Advanced/`, `research-log/`,
  `logs/`.

Zone B (authored content - read + reported only, NONE modified):
- `.hermes.template.md` - full read, ~360 lines / 17291 bytes. Checked the
  substitution markers, the skill inventory line (L35 area), the router
  rules, the Hermes-specific addendum.
- `skills-source/tsc-only/forge-audit/SKILL.md` - full read, 48 lines.
- `skills-source/shared/manual/SKILL.md` - full read, 20 lines.
- `skills-source/shared/daily-brief/SKILL.md` - full read, 43 lines.
- `mode-blocks/full-banner.md` (4 lines), `mode-blocks/full-menu.md`
  (20 lines), `mode-blocks/sales-banner.md` (6 lines),
  `mode-blocks/sales-menu.md` (10 lines) - full reads.
- All 16 `skills-source/**/SKILL.md` - first 6 lines each (frontmatter).
- `CLAUDE.md` - full read, 386 lines / 19425 bytes (via file, not just the
  system-context copy).

Zone C:
- `NEXT_STEPS.md` - header + lines ~1-60 + targeted greps (skill-count
  currency, forge-audit CLAUDE.md-token history).
- `CHANGELOG.md` - head (first ~40 lines / the `[Unreleased] - 2026-09-05`
  block).

## Zone A changes made

None.

Rationale for making no change despite Part 3 of the request: CLAUDE.md's
Zone A permission is "read, run, test, and directly patch these files once
it has confirmed a real bug (not 'this looks off' - actually reproduce it
first)", and the Session Start Protocol closes with "If none was given, a
clean session-start check IS the whole task - write the audit report and
stop rather than inventing work to do." Kenneth supplied no symptom for
Part 3. Of the three things found:
- F1 (`launch-north-forge.sh` L226-229 dead error branch) is reproducible
  but does not break first run - the Python block prints its own FATAL
  line and `set -e` still aborts before `.hermes.md` is written. Fixing it
  means restructuring an `errexit` + heredoc control flow in the launcher,
  which is exactly the kind of change the primary-GPT-ratifies pattern in
  this repo's history exists for.
- F2 (executable-resolver divergence) is a real internal inconsistency but
  whether it breaks first run depends on the upstream Hermes installer's
  on-disk layout, which cannot be observed here (no binary, no network).
  A blind "union the two candidate lists" fix could mask a genuinely bad
  install; choosing a single canonical path without knowing the real one
  is guessing. Neither is a confirmed-bug fix.
- F3 (`launch-north-forge.bat` `:HERMES_READY` dead label) changes no
  behaviour at all - not a "bug" under the Zone A bar.

## Zone B findings (not fixed - reported only)

None new. The `.hermes.template.md`, `mode-blocks/*`, and all 16
`skills-source/**/SKILL.md` files were read and are internally consistent
and consistent with the launchers (details under "Verified sound" below).

Carried-over Zone B items from the prior report, still open, not touched
this session: README.md `img.shields.io` dependency; the dropped "Why this
exists" README paragraph; the b744b10 `Advanced/` path gap in README.md's
file tree; the BLOCKED `USER_MANUAL.md` `Advanced/` run-instruction
update. None of these is in the Hermes surface this session was asked to
review; listing them only so the thread is not lost.

## Findings this session (Zone A code; flagged, not fixed)

### F1 - `launch-north-forge.sh` L226-229: the friendly size-guard abort message is unreachable

Lines 197-229:

```sh
python3 - "$MODE" << 'PYEOF'
...
if size >= 20000:
    print(f"FATAL: assembled .hermes.md is {size} chars ...")
    ...
    sys.exit(1)
...
with open(".hermes.md", "w", encoding="utf-8") as f:
    f.write(tmpl)
PYEOF
if [ $? -ne 0 ]; then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi
```

`set -e` is in force (L8, never unset). `python3 - << 'PYEOF' ... PYEOF`
is a simple command with a heredoc redirect - it is not the condition of
an `if`/`while`/`until`, not part of a `&&`/`||` list, and not negated
with `!`. So on a non-zero exit, `errexit` terminates the script at that
command and the `if [ $? -ne 0 ]` on L226 never runs. Lines 227-228 (the
"Launch aborted: .hermes.md was not written." message) are dead on the
failure path.

Reproduced this session (scratchpad, `bash` = Git-for-Windows 5.2.37):

```sh
$ cat seti.sh
#!/usr/bin/env bash
set -e
python3 - <<'PY'
import sys
print("FATAL: simulated size-guard failure")
sys.exit(1)
PY
if [ $? -ne 0 ]; then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi
echo "REACHED NORMAL CONTINUATION (should not print on failure)"

$ bash seti.sh
FATAL: simulated size-guard failure
--- script exit code: 1 ---
```

Neither "Launch aborted..." nor the normal-continuation line printed; the
script exited 1 with only Python's own message.

Practical impact: LOW. On a real size-guard trip the operator still sees
the Python block's `FATAL: assembled .hermes.md is N chars ...` line
(printed before `sys.exit(1)`), and `.hermes.md` is genuinely not written
because the write (L223-224) is after the guard. Only the extra
confirmation line is lost, and only in a scenario that needs the assembled
template to reach 20,000 chars. Current assembled size per NEXT_STEPS.md
is ~19,101 (FULL) / ~19,096 (SALES), so the guard is not currently firing.

The `.bat` equivalent (L155-169) handles this correctly - cmd.exe has no
`errexit`, so its `if errorlevel 1 ( echo Launch aborted... & pause &
exit /b 1 )` runs as intended. So this is a `.sh`-only asymmetry.

Suggested fix if primary GPT wants it (NOT applied): make the heredoc the
condition of the `if`, e.g.

```sh
if ! python3 - "$MODE" << 'PYEOF'
...
PYEOF
then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi
```

which both suppresses `errexit` for that command and reaches the message.

### F2 - the install guard and the runtime wrapper disagree on where the Hermes executable lives

Two different files resolve the drive-local Hermes executable, with only
partially overlapping candidate lists.

POSIX:

```
scripts/ensure-hermes.sh:6   for candidate in "$root/bin/hermes" "$root/hermes" "$root/hermes-agent/hermes"; do
scripts/hermes-drive.sh:22   for candidate in "$HERMES_HOME/hermes-agent/venv/bin/hermes" "$HERMES_HOME/hermes-agent/.venv/bin/hermes" "$HERMES_HOME/venv/bin/hermes" "$HERMES_HOME/bin/hermes"; do
```

Common to both: `bin/hermes` only.

Windows:

```
scripts/ensure-hermes.ps1:9   @((Join-Path $Root 'Scripts\hermes.exe'), (Join-Path $Root 'bin\hermes.exe'), (Join-Path $Root 'hermes.exe'))
scripts/hermes-drive.ps1:30   (Join-Path $homeDir 'hermes-agent\venv\Scripts\hermes.exe'),
                       :31   (Join-Path $homeDir 'hermes-agent\.venv\Scripts\hermes.exe'),
                       :32   (Join-Path $homeDir 'venv\Scripts\hermes.exe'),
                       :33   (Join-Path $homeDir 'Scripts\hermes.exe')
```

Common to both: `Scripts\hermes.exe` only.

`scripts/ensure-hermes.sh` `hermes_home_valid()` (L12-14) requires
`$1/hermes-agent` + `$1/hermes-agent/pyproject.toml` + `hermes_executable
"$1"` returning success. `scripts/ensure-hermes.ps1` `Test-HermesHome`
(L12-14) requires `Get-HermesExe` + `$Root\hermes-agent\pyproject.toml`.
After that guard passes, `launch-north-forge.sh` defines
`hermes() { scripts/hermes-drive.sh "$@"; }` (L241) and every subsequent
Hermes call - `hermes skin use north-forge` (L366), `hermes skin list`
(L368), `hermes skills trust .` (L374), the cron probes (L392, L400), and
the interactive launch (L417) - goes through `hermes-drive.sh`. The `.bat`
does the same via `set "HERMES_CMD=powershell ... -File scripts\hermes-drive.ps1"`
(L194) used at L265, L267, L273, L279, L293, L311.

Consequence: if the real upstream Hermes installer places the executable
at any accepted-by-`ensure-hermes` path that is NOT the single common one
(`bin/hermes` / `Scripts\hermes.exe`) - e.g. `$HERMES_HOME/hermes` or
`$HERMES_HOME/hermes-agent/hermes` on POSIX, or `$HERMES_HOME\bin\hermes.exe`
or `$HERMES_HOME\hermes.exe` on Windows, all of which `ensure-hermes`
explicitly accepts - then `ensure_drive_hermes` reports the install valid,
and the very next line, `hermes skin use north-forge`, fails: `hermes-drive.sh`
/ `hermes-drive.ps1` exit 72 with "the drive-local Hermes executable is
unavailable". That is a hard first-run stop, and it is conditional purely
on the installer's layout.

Why it cannot be resolved here: no `hermes` binary in this image
(`command -v hermes` -> not found) and no network to
`hermes-agent.nousresearch.com` (`curl`/`Invoke-WebRequest` for
`install.sh`/`install.ps1`), the same limitation already recorded in
`logs/HERMES_CRON_GATEWAY_HOME_AUDIT.md` ("The build container does not
contain a Hermes executable ... no installed upstream module paths in this
image to quote"). The real install layout is unknown.

Why the test suite does not catch it: `tests/test-drive-local-hermes.sh`
L33-40 has its fake installer create the executable at
`"$HERMES_HOME/bin/hermes"` - the one path common to both resolver lists -
so the divergence is never exercised. `tests/test_drive_hermes_contract.py`
only asserts string presence in the guard files, not cross-file agreement
of the candidate lists.

Not previously flagged: `logs/CODEX_FULL_SANDBOX_REAUDIT_2026-09-05.md`
L26-31 documents `ensure-hermes`'s three-state gate and its accepted
executable locations, but does not note that `hermes-drive.*` - the file
that actually runs Hermes for every skin/skill/cron/interactive call -
uses a different, only-1-deep-overlapping list. `hermes-drive.*` probing
venv-style paths (`hermes-agent/venv/bin/hermes`) that `ensure-hermes.*`
never validates suggests the two files were written against different
mental models of the installer's output.

Suggested direction (NOT applied): on a machine with a real drive-local
`.hermes-home`, run `find .hermes-home -name 'hermes*' -type f`
(POSIX) / `Get-ChildItem -Recurse -Filter 'hermes*.exe' .hermes-home`
(Windows), then make both resolvers share one authoritative, ordered
candidate list (a single sourced helper, ideally). Until the real layout
is known, any code change here is a guess.

### F3 - `launch-north-forge.bat` L363-367: `:HERMES_READY` is unreachable dead code

```bat
:HERMES_READY
if not exist "%HERMES_HOME%\hermes-agent\" exit /b 1
if not exist "%HERMES_HOME%\venv\" exit /b 1
if not exist "%HERMES_EXE%" exit /b 1
exit /b 0
```

`grep -nE "call :HERMES_READY|goto :?HERMES_READY" launch-north-forge.bat`
-> no match. The label is never invoked. It also references `%HERMES_EXE%`,
which `grep -nE 'set +"?HERMES_EXE' launch-north-forge.bat` shows is never
set anywhere in the file, so `if not exist "%HERMES_EXE%"` would expand to
`if not exist ""` (always true) and the subroutine, if it ever ran, would
`exit /b 1` on L366 regardless of Hermes state. Almost certainly a
leftover from before install validation was factored out into
`scripts\ensure-hermes.ps1` (L175). Zero runtime effect today. The `.sh`
has no equivalent block. Recommend deleting L363-367 for tidiness on the
next `.bat` touch; flagging rather than editing because dead code is not a
reproducible bug.

## Minor notes (not findings, no action requested)

- `launch-north-forge.sh` L241 defines `hermes() { scripts/hermes-drive.sh
  "$@"; }` but the cron block (L392-405) calls `scripts/hermes-drive.sh`
  directly rather than through the function. Same target and behaviour;
  purely stylistic.
- `launch-north-forge.bat` L181 prepends
  `%HERMES_HOME%\Scripts;%HERMES_HOME%\bin;%HERMES_HOME%` to `PATH`, but
  every Hermes call after it uses `%HERMES_CMD%` (the wrapper), per the
  L183-193 comment explaining that PATH-shadowing was the thing being
  designed out. The PATH line is now near-vestigial but harmless (it can
  still help if the engine itself shells out to a bare `hermes`). The
  `.sh` side does the analogous prepend inside `ensure-hermes.sh` L23/L93
  (`export PATH="$home/bin:$home:$PATH"`).

## Verified sound (checked this session, no problem found)

- **Skill frontmatter**: all 16 `skills-source/**/SKILL.md` open with a
  `---` YAML block carrying `name:` and `description:`. The 16 `name:`
  values are `menu, manual, assist, kb, draft, audit, flush, switch,
  train, hl, esc, log, sales, web, kyocera-research, daily-brief` - all
  distinct. (Folder names differ from several `name:` values by design -
  e.g. `assist-intake` registers `/assist`, `forge-audit` registers
  `/audit`, `sales-assist` registers `/sales`, `hotline-ticket` registers
  `/hl`.)
- **skills-guard `agent_config_mod` scanner**:
  `grep -rnE "CLAUDE\.md|AGENTS\.md|\.cursorrules|\.clinerules"
  skills-source/` returns nothing. The `forge-audit/SKILL.md` literal
  `CLAUDE.md` that `NEXT_STEPS.md` flagged in its 2026-08-29 correction
  (which said that one token -> verdict `dangerous` -> withheld from
  `hermes skills list`) is gone: current L7 reads "unless a
  code-maintenance or agent-configuration file is specifically requested".
  No skill file currently trips that rule. (Not runnable here - hermes not
  installed - but the static trigger is confirmed absent.)
- **`.hermes.template.md` substitution markers**: `{{MODE_BANNER_BLOCK}}`
  (L10), `{{COMMAND_MENU_BLOCK}}` (L58), `{{AGENT_NAME}}` (L13). Both
  launchers substitute all three: `.sh` via the Python heredoc L209
  (`.replace("{{MODE_BANNER_BLOCK}}", banner).replace("{{COMMAND_MENU_BLOCK}}",
  menu).replace("{{AGENT_NAME}}", agent_name)`), `.bat` via inline
  PowerShell L161 (`.Replace('{{MODE_BANNER_BLOCK}}',$b).Replace(
  '{{COMMAND_MENU_BLOCK}}',$c).Replace('{{AGENT_NAME}}',$name)`). No
  unreplaced marker type on either path.
- **Template skill inventory currency**: `.hermes.template.md`
  `how_this_package_is_organized` lists tsc-only = kb-builder,
  draft-writer, hotline-ticket, assist-intake, escalation-packet,
  forge-audit, fault-logging, training-guide (8) and shared =
  sales-assist, web-navigator, menu, manual, flush, switch,
  kyocera-research, daily-brief (8). That is exactly the 16 SKILL.md files
  on disk. Template is current.
- **mode-blocks vs skills**: `full-menu.md` lists `/menu /manual /assist
  /kb /draft /audit /flush /switch /train /hl /esc /log /sales /web` -
  every FULL skill. `sales-menu.md` lists only `/menu /manual /sales /web
  /flush /switch` and an explicit "does not have that capability" reject
  list for `/kb /hl /esc /audit /log /train /assist /draft`. Banners
  (`full-banner.md`, `sales-banner.md`) consistent with each menu's scope.
- **`scripts/name_validation.py`**: exposes both entry points the
  launchers rely on - the `read_validated(path, default)` API used by the
  `.sh` heredoc (L206, `from scripts.name_validation import
  read_validated`; resolves as a namespace package because the heredoc's
  `sys.path[0]` is the repo root it `cd`'d to on L9) and the `get --file
  --default` argparse subcommand used by the `.bat` (L160), plus the
  `drive` and `agent` actions both launchers call. `from __future__ import
  annotations` (L9) guards the PEP-604 `str | None` hints. Injection
  handling (control-byte strip, newline reject, 64-char cap, punctuation
  allowlist) intact.
- **`scripts/assemble-skills.ps1`** and the `.sh` `assemble_skills()`
  function: matching shared list (8) and tsc list (8); staged build ->
  validate every expected skill dir + SKILL.md -> file-count equality
  check (`$stageCount -ne $sourceCount` / `stage_count -ne source_count`)
  -> back up live -> atomic rename swap -> restore-on-failure. `.ps1` uses
  a PID+GUID staging token; `.sh` uses `$$-$RANDOM` plus an EXIT trap that
  restores the backup if the live dir is missing. Both preserve the prior
  build on any failure.
- **`scripts/hermes-drive.sh` / `.ps1`** gateway wrappers: both force
  `HERMES_HOME` to `<repo>/.hermes-home`, `cd` to the repo, refuse to run
  (exit 72) if `.hermes.template.md` or `.hermes-home` is absent or no
  executable is found, and never fall back to a host Hermes. `.ps1` uses
  `$homeDir` deliberately (not `$home`, a read-only automatic var - noted
  in its own L3-8 comment). This is the isolation contract
  `tests/test_cron_registration.py` and `tests/test_drive_hermes_contract.py`
  check. (Caveat: the exe-resolution half of that contract is F2.)
- **`git pull`** clean, working tree clean at start and now (except this
  report), `bash -n launch-north-forge.sh` parses OK (b768e29 CRLF fix
  holding under this box's `core.autocrlf=true`).

## Commits made this session

1. **(this commit, pending)** `logs/CLAUDE_CODE_LAST_AUDIT.md` - this
   report. Zone A standing authorisation (Claude Code's own operational
   record). No other file staged. `.env` not present on this drive, never
   staged.

## Uncertain / flagged for primary GPT review

1. **Part 1 of the request has no content yet.** Kenneth said "all three"
   including "a Zone B handoff is incoming," but nothing was pasted. If a
   revised `.hermes.template.md` or `skills-source/**` file is meant to
   come, it still needs to be handed over as byte-for-byte content; this
   session placed nothing. If "Hermes update" did NOT mean a handoff,
   disregard - Parts 2 and 3 are covered above.
2. **F2 is the one worth a decision.** It is a genuine cross-file
   inconsistency in Zone A code that could produce a first-run stop
   (`hermes skin use` exit 72 right after a "successful" install), but
   only if the upstream installer's executable layout differs from the
   single path the two resolvers share. Someone with a real Hermes
   install needs to report the actual on-disk path(s) so both resolvers
   can be reconciled to one list. Until then Claude Code should not guess.
   Question for primary GPT / Blacksmith: is the venv-style layout that
   `hermes-drive.*` assumes (`hermes-agent/venv/bin/hermes`) the real one,
   in which case `ensure-hermes.*`'s validator is the file that is wrong,
   or vice versa?
3. **F1** - should the `.sh` size-guard be restructured to match the
   `.bat`'s behaviour (show "Launch aborted: .hermes.md was not written."
   and exit cleanly)? It is a one-block change (`if ! python3 ... then ...
   fi`) but it is in the launcher's `errexit` control flow, so flagging
   rather than doing it unprompted.
4. **F3** - OK to delete the dead `:HERMES_READY` label
   (`launch-north-forge.bat` L363-367) on the next `.bat` edit? Harmless
   either way; just untidy.
5. **Carried over, unchanged**: the five open flags from the c7cc3b0
   report (`.gitattributes` ratification; real-hardware confirmation of
   the renormalised `.sh`; README `img.shields.io` dependency; dropped
   "Why this exists" paragraph; the `Advanced/` path gap in README.md +
   USER_MANUAL.md needing a byte-for-byte Zone B handoff). None are in the
   Hermes surface and none were touched this session.

## Status

Needs primary GPT review.
- No code changed. No Zone B file touched. Only this audit report
  committed.
- Decision needed on F2 (executable-resolver divergence) - the only
  finding that could be a real first-run break, blocked on an upstream
  fact not observable in this environment.
- If "Hermes update" was meant to carry a Zone B handoff, that content
  still needs to be pasted.
