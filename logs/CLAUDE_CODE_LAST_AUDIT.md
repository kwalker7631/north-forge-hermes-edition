# Claude Code Session Audit

Timestamp: 2026-09-05 (evening, America/New_York), on the `E:` drive clone
Requested task: "Investigate and improve the visual/organizational first
impression of a provisioned drive's root folder" - a 4-part request:
(1) investigate + categorize every root file/folder before changing anything;
(2) move admin/support-only tools into an `Advanced/` subfolder and fix every
internal path reference; (3) generate a real-icon `North Forge.lnk` at the
drive root at provisioning/first-run time; (4) give a recommendation (not an
implementation) on whether numbered `1-`/`2-`/`3-` file naming helps.
Explicit instruction: report Part 1 before changing anything; report before
implementing Part 3/4 (field-user-visible); Part 1/2 fine to implement
directly. Standing UX-change-needs-review practice invoked by the user.

## Outcome

Part 1 investigated and reported in chat before any change. A clarifying
question was put to Kenneth because Part 2 as framed had two problems he had
not weighed: (a) the move is a 6-script working-directory refactor, not a
flat `git mv` - every admin script `cd`s to its own dir then uses relative
paths for `.forge-mode`, the credential dotfiles, `.hermes/skills`,
`forge-events.log`, and `scripts/` helpers; (b) `README.md` + `USER_MANUAL.md`
are Zone B (read-only for Claude Code) so I cannot compose their reference
updates. Kenneth chose **"Zone A now + I hand you doc diffs."**

Implemented and pushed as commit **`b744b10`** (Zone A + Zone C): the
`Advanced/` move with all 6 scripts re-anchored, Part 3's root `North
Forge.lnk` in both `provision-new-drive.ps1` and `launch-north-forge.bat`,
`.gitignore` exclusion, two test-file updates, CHANGELOG.md + NEXT_STEPS.md
entries. Part 4: recommended against numbered naming (rationale below and in
CHANGELOG.md). `README.md` + `USER_MANUAL.md` NOT touched - exact drop-in
replacement text handed to Kenneth in chat for a Zone B handoff.

## Session start / concurrency note

This session did NOT run the Session Start Protocol as its own first step -
the immediately-preceding task in this same conversation ("pull /logs from
git codex audit") had already done `git pull` (to `8b06653`), read the prior
audit, and confirmed `.gitignore`. At the time this task's work was
committed, `git push` was rejected repeatedly: a second Claude Code session
(on the `F:` drive clone, user `kwalker138`) was concurrently pushing a
chain of audit-report commits - `d80d409`, `0b80d9c`, `dcbedef`, `0a68f22` -
**every one of which touches only `logs/CLAUDE_CODE_LAST_AUDIT.md`**
(verified via `git show --stat` on each); none touches any file this task
changed. Resolved by `git pull --rebase` each time. My code change replayed
cleanly onto `0b80d9c` and pushed as **`b744b10`**. This report's commit hit
a content conflict in `logs/CLAUDE_CODE_LAST_AUDIT.md` against the F:
session's evolving report; resolved by taking this session's full report
(`git checkout --theirs`) - it is the authoritative record of the
substantive repo change, and the F: session's own report content survives in
git history at `d80d409..0a68f22`. Facts carried forward from that session
so nothing is lost: (a) it hit `fatal: detected dubious ownership` on `F:`
and fixed it with a machine-local `git config --global --add safe.directory`
(git client setting, not a repo change); (b) a drive-local `stash@{0}` on
the F: clone (never shared via git; `git stash list` is empty on this E:
clone) held a stale `README.md` `<img>` title-icon change + an obsolete
`WELCOME.html` draft - **Kenneth dropped it this session** (`dcbedef`;
dropped stash commit `de954fc`, still a loose object, recoverable ~2 weeks);
(c) that session's standing recommendation is NOT to add the README `<img>`
title icon. That README `<img>` item and this task's drive-root `North
Forge.lnk` are two different "icon" threads - not conflated.

## Part 1 - root inventory + categorization (reported in chat, reproduced here)

How a provisioned drive's root is populated: `provision-new-drive.ps1` does
`git clone` then runs `launch-north-forge.bat`. So the root = the exact
tracked tree + runtime files the launcher generates. There is no
provision-only file.

Categories: (a) field user should see/might click; (b) Kenneth/support only;
(c) must exist, never needs to be seen.

### Tracked files at root (pre-move)
| File | Cat | Note |
|---|---|---|
| `launch-north-forge.bat` / `.sh` | a | the launcher(s) |
| `WELCOME.html` | a | auto-opens once, fine to open manually |
| `FIRST_TIME_README.txt` | a | plain-language quickstart, "for whoever gets handed one" |
| `toggle-mode.bat` / `.sh` | b | mode switch + RESET, admin-gated |
| `machine-reset.bat` | b | host-PC Hermes purge / key rotation, admin-gated |
| `full-drive-reset.bat` / `.sh` | b | unrecoverable drive-engine purge, path-confirm gated |
| `provision-new-drive.ps1` | b | drive creation; ships on every drive; contains an embedded token line |
| `README.md` | b/dev | dev/admin doc; Zone B |
| `USER_MANUAL.md` | a-ish | user reference, Zone B, not something to click |
| `ATTRIBUTION.md` | c | MIT-license obligation |
| `CLAUDE.md`, `AGENTS.md` | c | agent working rules |
| `CHANGELOG.md`, `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md` | c | dev status logs |
| `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` | c | locked KB template consumed by `/kb` |
| `.env.example`, `.gitignore` | c | config templates |

### Tracked directories at root
`assets/` (c - holds `north-forge.ico`), `skills-source/` `mode-blocks/`
`skins/` (c - authored source), `scripts/` (c - helpers the launcher/admin
tools call), `tests/` (c), `fallback/` (c), `research-log/` (c - cron-
appended, committed on purpose), `kb-images/` (c - `/kb` image intake,
shared), `logs/` (c - audit reports), `archive/` (c -
`setup-thumbdrive.ps1`, superseded; CLAUDE.md marks `archive/` never-touch).

### Generated/runtime items at a provisioned root (all gitignored, all cat c)
`.hermes-home/`, `.hermes/`, `.hermes.md`, `.forge-mode`, `.agent-name`,
`.provider-choice`, `.readme-shown`, `.drive-record.txt`, `.env` (once
created), `forge-events.log`, `install-logs/`, and transients
(`.hermes-install-staging/`, `.hermes-install-incomplete`,
`.north-forge-write-probe-*.tmp`). Desktop shortcut (`North Forge.lnk` on
Windows / `North Forge.command` on Mac) lands on the **Desktop**, not the
drive root.

### Part 1 finding that reshaped the task
The task's stated Part 2 goal - "root should end up close to just: the one
launcher, WELCOME.html, FIRST_TIME_README.txt, and the new admin subfolder"
- is **not reachable by moving admin scripts alone**. The root is a git
working tree: ~13 `.md`/config files and ~11 source subdirectories remain.
The realistic and real win: removing the 6 admin `.bat`/`.ps1` (the files a
nervous non-technical user is most likely to click) and adding one blessed
icon (Part 3). A non-technical user disregards `.md` files and folders like
`skills-source/`.

## Zone A changes made (commit `b744b10`)

### 1. `git mv` - 6 admin scripts -> `Advanced/` (history preserved)
`git diff --cached -M --summary` scored: `toggle-mode.bat` 93%,
`toggle-mode.sh` 92%, `machine-reset.bat` 92%, `full-drive-reset.bat` 89%,
`full-drive-reset.sh` 88%, `provision-new-drive.ps1` 82% (similarity below
100% because each carries the re-anchor edit below; all still detected as
renames, `git log --follow` will cross the move). `git mv` initially failed
on this Windows/git-bash combo when the target dir did not exist
(`fatal: renaming ... failed: No such file or directory`); worked after an
explicit `mkdir -p Advanced` then per-file `git mv`.

### 2. Working-directory re-anchor (the non-cosmetic part)
Every moved script previously anchored to its own directory (`cd /d "%~dp0"`
/ `cd "$(dirname "$0")"`) then used **relative** paths. Left unfixed, from
`Advanced/`: `toggle-mode` RESET would `del`/`rm` in `Advanced/` (nothing
there), find no targets, and **report success** - silently breaking the
"genuine first run" / credential-scrub guarantee; `machine-reset.bat` would
fail at its first line (`%~dp0scripts\machine-reset-safety.ps1` ->
`Advanced\scripts\...` does not exist); `full-drive-reset.*` would compute
`REPO`/`CANDIDATE` under `Advanced/`. Fixes applied:

| File | Before | After |
|---|---|---|
| `Advanced/toggle-mode.bat` L?(setlocal block) | `cd /d "%~dp0"` | `cd /d "%~dp0.."` + 4-line explanatory comment |
| `Advanced/toggle-mode.sh` | `cd "$(dirname "$0")"` | `cd "$(dirname "$0")/.." \|\| exit 1` + comment (added `\|\| exit 1` - RESET deletes files, must fail closed) |
| `Advanced/machine-reset.bat` | `cd /d "%~dp0"` | `cd /d "%~dp0.."` + comment |
| `Advanced/machine-reset.bat` x3 (Validate/RemoveEnv/Purge) | `-File "%~dp0scripts\machine-reset-safety.ps1"` | `-File "%~dp0..\scripts\machine-reset-safety.ps1"` (replace_all, exactly 3 occurrences) |
| `Advanced/full-drive-reset.bat` L3 | `cd /d "%~dp0"` | `cd /d "%~dp0.."` + comment |
| `Advanced/full-drive-reset.sh` L4 | `cd "$(dirname "$0")" \|\| exit 1` | `cd "$(dirname "$0")/.." \|\| exit 1` + comment |
| `Advanced/provision-new-drive.ps1` | (no cd to own dir; builds all paths from the chosen drive letter) | **body unchanged** |

After the re-anchor, every downstream relative path (`scripts\...`,
`forge-events.log`, `.forge-mode`, the RESET dotfile list, `.hermes\skills`)
resolves against the drive root exactly as before the move. Echo/guidance
text inside the scripts that names sibling tools by bare filename
("run `launch-north-forge.bat`", "run `full-drive-reset.bat` instead") was
left unchanged - it is human guidance, not a code-resolved path, and still
points the user to a findable file one level up. Recorded as a deliberate
minimal-diff choice.

### 3. Version-header bumps (repo convention for Zone A functional changes)
`Advanced/toggle-mode.bat` 1.1.0 -> 1.2.0; `Advanced/toggle-mode.sh`
1.1.0 -> 1.2.0; `Advanced/machine-reset.bat` 1.1.0 -> 1.2.0;
`Advanced/provision-new-drive.ps1` 1.0.1 -> 1.1.0 (Part 3 step added);
`launch-north-forge.bat` 1.2.1 -> 1.3.0 (Part 3 step added).
`full-drive-reset.bat`/`.sh` carry no version header - none added.
`launch-north-forge.sh` untouched (Part 3 scope was the Windows `.lnk` only).

### 4. Part 3 - drive-root `North Forge.lnk`
Added to **two** places (idempotent "create if missing", mirroring how the
existing Desktop-shortcut code already works):
- `Advanced/provision-new-drive.ps1`, new block after the launcher-exists
  check + `Set-Location`, before `& $launcherPath` (lines ~126-147): builds
  `$rootShortcut = Join-Path $repositoryPath "North Forge.lnk"`, and if
  absent creates it via `WScript.Shell` COM with `TargetPath = $launcherPath`,
  `WorkingDirectory = $repositoryPath`, `IconLocation = ...assets\north-forge.ico`,
  `Description = "North Forge - double-click to start"`. Wrapped in
  try/catch so `$ErrorActionPreference = "Stop"` cannot abort provisioning
  if the COM call fails; on failure it prints a note that the launcher will
  retry.
- `launch-north-forge.bat`, new block right after the Desktop-shortcut block
  (lines ~97-113): same `powershell -NoProfile -Command` one-liner form the
  Desktop block already uses, target `%~f0`, workdir `%~dp0`, icon
  `%~dp0assets\north-forge.ico`, destination `%~dp0North Forge.lnk`; logs
  `[INFO]`/`[WARNING] [shortcut]: drive-root North Forge.lnk ...` to
  `forge-events.log`.
Rationale: a `.bat` can never display a custom icon in Explorer; only a
`.lnk` can. The target path is drive-letter-specific, so it is generated,
never committed. `provision-new-drive.ps1` makes it present the instant
provisioning finishes (before the field user's first Explorer open); the
launcher block self-heals direct-clone drives and deletions.

### 5. `.gitignore` (+4 lines)
Added under the per-drive-markers block:
```
# Drive-root launcher shortcut - generated per drive by launch-north-forge.bat
# and provision-new-drive.ps1; its target path is drive-letter-specific, so it
# must never be committed (same reason as the per-drive markers above).
/North Forge.lnk
```
Anchored (`/North Forge.lnk`) - root only. `git check-ignore -v "North
Forge.lnk"` -> `.gitignore:25:/North Forge.lnk` after the change.

### 6. Tests (Zone A)
- `tests/reset-integration.sh`: `make_fixture` now `mkdir -p
  "$fixture/Advanced"` and `cp "$REPO_ROOT/Advanced/toggle-mode.sh"
  "$fixture/Advanced/"`; the 3 invocations now
  `bash "$X/Advanced/toggle-mode.sh"`. State files still created at
  `$fixture/` (the drive-root the re-anchored script `cd`s up into). 3-line
  header comment added. **Passes** (see verification).
- `tests/provision-new-drive.Tests.ps1` L7: `$sourceScript = Join-Path
  $repositoryRoot "provision-new-drive.ps1"` -> `"Advanced\provision-new-drive.ps1"`.
  L18's flat temp-copy path left as-is (the script has no dir-relative deps -
  the test itself proves this by copying it to a flat temp dir and running it).
- No other test references these scripts. `tests/machine-reset-safety.Tests.ps1`
  points at `..\scripts\machine-reset-safety.ps1` (unmoved) - unaffected.
  `tests/test-free-provider.sh` / `tests/test-skill-assembly.sh` do full-repo
  or `skills-source`-only copies and never invoke the admin scripts -
  unaffected.

## Zone C changes made (commit `b744b10`)

- `CHANGELOG.md`: new `### Reorganized (later session, Claude Code - drive-root
  first impression)` subsection at the top of `## [Unreleased] - 2026-09-05`,
  4 bullets (the move + re-anchor, the `.lnk`, the Zone B not-done note, the
  Part 4 recommendation). File-voice-matched to the existing long-form entries.
- `NEXT_STEPS.md`: one bullet appended under `## Done` after the
  `toggle-mode.bat/.sh RESET option` bullet, summarizing the pass and
  pointing at CHANGELOG.md + this report for detail.

## Part 4 - numbered `1-`/`2-`/`3-` naming: RECOMMENDATION = do not

Reported in chat and recorded in CHANGELOG.md. Reasoning:
- After the move, the root has exactly **one** thing a field user runs (the
  launcher / its `.lnk`). There is no ordered sequence to encode; a number
  prefix implies a multi-step process that does not exist.
- `1-launch-north-forge.bat` would churn every reference - `WELCOME.html`,
  `FIRST_TIME_README.txt`, `README.md`, `USER_MANUAL.md`,
  `provision-new-drive.ps1`'s `$launcherPath`, multiple tests - and desync
  the name from every doc and from muscle memory, for cosmetic gain.
- Inside `Advanced/` the tools are **situational, not sequential** (you run
  `toggle-mode` OR `full-drive-reset` OR `machine-reset` by need) - a `1/2/3`
  prefix would impose a false order.
- If extra in-folder signal is wanted: a static
  `Advanced/WHEN-TO-USE-THESE.txt` is more informative and touches zero
  existing references. (Not created this session - flagged as a small
  optional follow-up; it would be a new file, roughly Zone A category but
  arguably worth a Kenneth nod since it is user-visible text.)

## Verification performed

All on the real `E:` Windows drive.

- `bash tests/reset-integration.sh` -> `PASS: RESET removes exactly eight
  state targets, retains the accountability log, rejects refusal, and reports
  incomplete deletion.` (exit 0) - confirms `toggle-mode.sh` re-anchor.
- `bash tests/repository-hygiene.sh` -> pass (`.provider-choice` + `.env`
  ignored, `.env` unstaged).
- `bash -n Advanced/toggle-mode.sh Advanced/full-drive-reset.sh` -> clean.
- **`full-drive-reset.sh` from `Advanced/`** (scratch copy, fed a
  non-matching path): printed the TARGET as
  `<scratchroot>/.hermes-home` (drive root, NOT `<scratchroot>/Advanced/.hermes-home`),
  reached the safety validator with no "python: can't open file" error, then
  `Cancelled - the path did not match; nothing was changed.` exit 1. Works
  invoked from the repo root AND from inside `Advanced/`.
- **`toggle-mode.bat` RESET from `Advanced/`** (scratch copy, piped
  `RESET`/`RumpleStiltskin`/`YES` via `cmd /c "bat < input.txt"`): all 8
  state targets removed from the **parent** dir, `forge-events.log` retained
  in the parent, `Advanced\.forge-mode` NOT created (no leak), log line
  `RESET executed by Tester` (proves it read the parent's
  `.drive-record.txt`). `exit /b 0` path, no `pause` hang.
- **`machine-reset.bat` from `Advanced/`** (scratch copy): the
  `%~dp0..\scripts\machine-reset-safety.ps1 -Action Validate` call **ran the
  helper** - output was the helper's own domain message ("Safety check
  failed: the target directory does not exist" -> `%LOCALAPPDATA%\hermes`
  genuinely absent on this machine), NOT a PowerShell "cannot find path"
  error. Path re-anchor confirmed. (The NativeCommandError wrapper in the
  transcript is PowerShell `2>&1` noise around exit code 2 = the designed
  safe-stop.)
- **`full-drive-reset.bat` from `Advanced/`** (scratch copy, wrong path):
  TARGET printed as `<scratchroot>\.hermes-home`, `scripts\drive-reset-safety.py`
  resolved (no file-not-found), `Cancelled - the path did not match`.
- **Part 3 `.lnk`** generated on the real `E:` root via the exact
  `provision-new-drive.ps1` COM sequence: `TargetPath =
  E:\north-forge-hermes-edition\launch-north-forge.bat`, `WorkingDirectory =
  E:\north-forge-hermes-edition`, `IconLocation =
  ...\assets\north-forge.ico,0`; target + icon both `Test-Path` True;
  `git status --porcelain -- "North Forge.lnk"` empty; `git check-ignore -v`
  -> `.gitignore:25:/North Forge.lnk`. Then removed (tree left pristine).
- `toggle-mode.bat` run once against the real `E:` root (blank input = quit):
  menu showed `Current mode file: full` - i.e. from `Advanced/` it read the
  real drive-root `.forge-mode`. Read-only, no modification.
- PowerShell `Parser::ParseFile` on `Advanced/provision-new-drive.ps1`,
  `scripts/machine-reset-safety.ps1`, `tests/provision-new-drive.Tests.ps1`
  -> all OK.
- `python -m unittest tests.test_launcher_hermes_home` (4 tests) OK;
  `tests/test_drive_hermes_contract.py` module functions OK.
- `git diff --check` -> clean.
- Post-push: `HEAD == origin/main` true; `git ls-tree HEAD Advanced/` lists
  all 6; repo-wide grep for a root-path reference to the moved scripts in
  `tests/`, `scripts/`, `launch-north-forge.*` returns only the (correct)
  `Advanced\provision-new-drive.ps1` line and the intentional flat temp-copy
  path in the same test.

### NOT verified (environment limits)
- `tests/provision-new-drive.Tests.ps1` end-to-end - needs Pester/pwsh and a
  writable fake-drive harness; only parse-checked + the single path line
  reviewed. It reads `$sourceScript` once at the top; the rest uses a flat
  temp copy, so the L7 change is the whole surface.
- Native double-click behaviour of the generated `.lnk` in Explorer (icon
  render, launch) - the COM properties are all correct and resolve, but an
  actual Explorer double-click was not performed.
- `machine-reset.bat` / `full-drive-reset.bat` past their `hermes`-on-PATH
  gate - `hermes` is not installed on this machine; both stop safely at that
  gate as designed. The path re-anchor (the only thing this change affects)
  was verified before that gate.

## Zone B findings (NOT fixed - reported only; drop-in text handed to Kenneth)

`README.md` and `USER_MANUAL.md` are Zone B. Both still show the pre-move
root paths and need a Blacksmith / Claude Project chat handoff. Exact
replacement text was given to Kenneth in this session's chat. Locations:

1. **`README.md` file-tree diagram (lines ~62-64, 69)** - `toggle-mode.bat /
   .sh`, `full-drive-reset.bat / .sh`, `machine-reset.bat`, and
   `provision-new-drive.ps1` are listed as flat root entries; they need to be
   re-nested under a new `Advanced/` node.
2. **`README.md` line 131** - the fenced example ```` .\provision-new-drive.ps1 ````
   becomes ```` .\Advanced\provision-new-drive.ps1 ````. Also line 128, 136,
   175, 211 name `provision-new-drive.ps1` / `toggle-mode.bat` in prose -
   prose is arguably fine as bare names, but line 131 is a literal command
   and line 211 ("paste it into the line that sets `$cloneUrl` near the top
   of `provision-new-drive.ps1`") now needs the `Advanced\` qualifier for
   someone to find the file.
3. **`USER_MANUAL.md` line 166** - "run `toggle-mode.bat` (or `.sh`)" ->
   "run `Advanced\toggle-mode.bat` (or `Advanced/toggle-mode.sh`)".
4. **`USER_MANUAL.md` lines 181-182** - "run `full-drive-reset.bat` on
   Windows or `bash full-drive-reset.sh`" -> `Advanced\` / `Advanced/`
   prefixes.
5. **`USER_MANUAL.md` line 185** - "`machine-reset.bat` is different:" ->
   "`Advanced\machine-reset.bat` is different:".

`WELCOME.html` (Zone B) and `FIRST_TIME_README.txt` (Zone B) reference ONLY
`launch-north-forge.bat`/`.sh`, which did not move - no change needed there.
`.hermes.template.md`, `mode-blocks/`, `skills-source/` - grep confirms zero
references to any of the 6 moved scripts. `archive/setup-thumbdrive.ps1`
left untouched (CLAUDE.md: `archive/` is never-touch).

## Commits made this session

- **`b744b10`** - "Move admin tooling into Advanced/; generate a real-icon
  North Forge.lnk at drive root". 12 files: 6 renames into `Advanced/` (with
  re-anchor edits + version bumps), `M launch-north-forge.bat` (root `.lnk`
  block + version bump), `M .gitignore` (+4), `M CHANGELOG.md` (+5 lines /
  Zone C), `M NEXT_STEPS.md` (+1 line / Zone C), `M tests/reset-integration.sh`,
  `M tests/provision-new-drive.Tests.ps1`. `12 files changed, 92 insertions(+),
  19 deletions(-)`. Rebased onto `0b80d9c` (clean) before push; final SHA
  `b744b10`, pushed `0b80d9c..b744b10`.
- **This report** - `logs/CLAUDE_CODE_LAST_AUDIT.md` overwritten (separate
  commit, Zone A standing authorization).

`.env` never staged (not present on this drive; `tests/repository-hygiene.sh`
re-confirms it is ignored + unstaged). `.hermes-install-incomplete` and
`install-logs/` remain untracked and untouched (a `git add -A` mid-session
briefly staged them; caught immediately and `git restore --staged`d before
any commit - they are in NO commit this session).

## Uncertain / flagged for primary GPT review

1. **The `Advanced/` folder name is provisional.** Kenneth was offered a
   rename option and did not take it, so "Advanced" stands, but the task text
   says "Kenneth can rename if he prefers something else (IT-Tools,
   Support-Only, ...)". If he renames later it is another `git mv` + the same
   set of reference updates (README/USER_MANUAL Zone B, the two tests, the
   CHANGELOG/NEXT_STEPS prose). Cheap now, cheaper before the Zone B docs are
   updated to say `Advanced/`.
2. **Echo/guidance text inside the moved scripts still says bare
   "run `launch-north-forge.bat`" / "run `full-drive-reset.bat`".** Left
   unchanged deliberately (human guidance, not a resolved path; the file is
   findable one level up). If the Blacksmith would rather these read
   "`..\launch-north-forge.bat`" or "the launcher in the drive's main
   folder", that is a small Zone A follow-up - flagged rather than assumed.
3. **`launch-north-forge.sh` got no Part 3 equivalent.** The task scoped Part
   3 to the Windows `.lnk` explicitly ("Windows can't assign a custom
   icon..."). A Mac `North Forge.command` at the drive root is possible but
   exFAT can't carry its exec bit (the existing Mac flow puts it on the
   Desktop for that reason). Not done; noting the asymmetry.
4. **`tests/provision-new-drive.Tests.ps1` not run** (no Pester/pwsh harness
   here). The change is one path line; the rest of the test uses a flat temp
   copy. Low risk but unverified end-to-end.
5. **Part 4 optional follow-up not done:** a static
   `Advanced/WHEN-TO-USE-THESE.txt`. It would be user-visible text, so I did
   not compose it unprompted. Recommend Kenneth decide if he wants it.
6. **Concurrent F: session's `stash@{0}`** (README `<img>` title-icon + stale
   WELCOME.html draft) is still un-dropped on that clone - not this task's
   scope, not on this E: clone, but it and this task are the two live "icon"
   threads and should not be conflated. That session already recommended
   dropping the stash and NOT adding the README `<img>`.

## Status

Needs primary GPT review + a Zone B handoff. Parts 1, 2 (Zone A half), 3, and
4 are complete and pushed (`b744b10`). The drive root no longer shows the 6
admin `.bat`/`.ps1`; a generated real-icon `North Forge.lnk` gives one
obvious thing to open. All re-anchored scripts verified on real Windows to
still operate on the drive root. **Outstanding: `README.md` +
`USER_MANUAL.md` still show pre-move paths** and need the drop-in text
(handed to Kenneth) placed via handoff - until then those two docs point one
folder too high. Part 4 recommendation (no numbered naming) is advisory,
awaiting Kenneth's acceptance.
