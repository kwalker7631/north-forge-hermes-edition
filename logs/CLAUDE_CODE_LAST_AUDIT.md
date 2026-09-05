# Claude Code Session Audit

Timestamp: 2026-09-05 18:36 EDT (America/New_York), on the `E:` drive clone
(`E:\north-forge-hermes-edition`)

Requested tasks (two, in one session):
1. Kenneth's prompt, verbatim - "Check this pull fix any erros wil execute
   first run. May have an isue with cheap usb flash". Read as: check the
   pulled repo, fix anything that would break the **first run** off this
   drive, drive/USB-flash related. No handoff file, no named Zone B target.
2. Follow-up in the same session: Kenneth pasted a complete revised
   `README.md` ("bling navigation Wingding and Github elements ... Just for
   me ... when I'm working and someone is watching they see bling") and,
   after being shown a diff-flag summary, answered the place/revise question
   with **"Place as-is + push"**. Treated as an in-session Blacksmith Zone B
   placement handoff.

## Outcome
- Task 1: FIXED (Zone A). Every shell script on this drive was CRLF and the
  macOS/Linux first run was broken. Added `.gitattributes`, renormalized the
  working tree. Commit `b768e29`.
- Task 2: PLACED (Zone B placement). Wrote the pasted `README.md`
  byte-for-byte, committed `4fd9fa6`, pushed. See "Task 2" section near the
  end of this report.

---

## Session Start Protocol results

```text
SESSION START CHECK
Pulled: Already up to date (git pull -> "Already up to date."; HEAD = origin/main = b85d649 "Audit report: README/USER_MANUAL Advanced/ handoff BLOCKED - Zone B needs byte-for-byte content"). git fetch --all --prune brought nothing new. No open PRs (gh pr list / gh pr status both empty), no incoming branch - "this pull" = the working copy already on the drive, not a pending merge.
Last audit read: Yes - prior session (b85d649) was BLOCKED: a prose-described README.md/USER_MANUAL.md Advanced/ path update could not be placed because Zone B needs byte-for-byte content. Still open, untouched this session - different area.
Uncommitted at start: None (git status clean, nothing staged, git diff / git diff --cached both empty).
.gitignore: OK - .env (L9) + *.env (L10), .forge-mode (L17), .agent-name (L18), .provider-choice (L19), .readme-shown (L20), .drive-record.txt (L21), /.hermes/ (L32), /.hermes-home/ (L33), .hermes.md (L34), *.log (L52 - covers forge-events.log) all present and correct.
hermes doctor: Not run - hermes not installed on this machine (command -v hermes -> not found), consistent with every prior session on this drive.
Project skills: hermes not installed - cannot list.
```

## What "the pull" is

`git status` clean, `main` even with `origin/main`, `git fetch --all --prune`
pulled nothing, `gh pr list --state open` and `gh pr status` both empty. There
is no pending merge or PR. "Check this pull" = validate the repo state that is
already checked out on this drive. The drive is a cheap USB flash stick
(Kenneth's own words), and:

```
PS> Get-Volume -DriveLetter E
FileSystem      : exFAT
FileSystemLabel : North-Forge
Size            : 248134893568       (~231 GiB)
SizeRemaining   : 248111431680       (essentially empty apart from the repo)
```

exFAT is deliberate - `launch-north-forge.sh` lines 73-77 say so: "exFAT
(needed for a drive that works on Windows/Mac/Linux) can't store the
executable permission bit". So the drive is meant to be carried between a
Windows PC and a Mac/Linux box, and both launchers are first-run entry points.

## The bug (reproduced)

### Symptom
Every tracked `*.sh` file in the working tree on this drive has **CRLF** line
endings. The committed blobs are all **LF**. `git ls-files --eol`:

```
i/lf    w/crlf  attr/                 	Advanced/full-drive-reset.sh
i/lf    w/crlf  attr/                 	Advanced/toggle-mode.sh
i/lf    w/crlf  attr/                 	launch-north-forge.sh
i/lf    w/crlf  attr/                 	scripts/ensure-hermes.sh
i/lf    w/crlf  attr/                 	scripts/hermes-drive.sh
i/lf    w/crlf  attr/                 	tests/repository-hygiene.sh
i/lf    w/crlf  attr/                 	tests/reset-integration.sh
i/lf    w/crlf  attr/                 	tests/test-drive-hermes-install.sh
i/lf    w/crlf  attr/                 	tests/test-drive-local-hermes.sh
i/lf    w/crlf  attr/                 	tests/test-free-provider.sh
i/lf    w/crlf  attr/                 	tests/test-launcher-hermes-home.sh
i/lf    w/crlf  attr/                 	tests/test-skill-assembly.sh
i/lf    w/crlf  attr/                 	tests/two-drive-hermes-isolation.sh
```

`file launch-north-forge.sh` before the fix:
`Bourne-Again shell script, ASCII text executable, with CRLF line terminators`.
`od -c` of the first line:
`# ! / u s r / b i n / e n v   b a s h \r \n`.

### Cause
Two facts combine:
1. The repo shipped with **no `.gitattributes`** at any path
   (`git ls-files '*.gitattributes' '.gitattributes'` -> empty; nothing on
   disk).
2. This drive was checked out on a Windows machine whose git has
   `core.autocrlf=true` (verified: `git config --get core.autocrlf` -> `true`;
   `core.eol` unset; `core.filemode` unset). With `autocrlf=true` and no
   attribute override, git converts LF -> CRLF in the working tree on every
   checkout, for every file it considers text - shell scripts included.

`Advanced/provision-new-drive.ps1` (the "canonical" new-drive setup) runs
`git clone $cloneUrl $repositoryPath` with whatever git config the
provisioning PC happens to have. So the CRLF conversion is not a one-off on
this drive - any Windows-side clone/pull produces the same broken `*.sh`
set. The fix has to live in the repo.

### Impact on first run
- **Windows first run (`launch-north-forge.bat`, double-click):** unaffected.
  CRLF is correct for batch files. `git ls-files --eol` shows `.bat`/`.cmd`/
  `.ps1` at `w/crlf`, which is what Windows wants.
- **macOS/Linux first run:** `FIRST_TIME_README.txt` lines 20-22 tell the
  operator to drag `launch-north-forge.sh` into a Terminal and press Enter.
  That path is broken by the CRLF:
  - Executed via the shebang (`./launch-north-forge.sh`, or the
    `North Forge.command` wrapper the script writes to the Desktop, which
    runs `bash "$SCRIPT_PATH"`): the kernel parses `#!/usr/bin/env bash\r`
    and hands `/usr/bin/env` the interpreter name `bash\r`.
    **Reproduced this session:**
    ```
    $ env "bash"$'\r' -c 'echo should-not-print'
    env: 'bash\r': No such file or directory
    $ echo $?
    127
    ```
    The script never starts.
  - Executed as `bash launch-north-forge.sh` (shebang bypassed): stock bash
    on macOS (3.2.57) and Linux treats a lone trailing `\r` as part of the
    preceding word, so reserved words become `then\r`, `fi\r`, `do\r` and
    bash raises `syntax error near unexpected token`, or runs `$'\r'` as a
    command (`command not found`). `set -e` on line 8 then aborts on the
    first such error. **This specific failure could NOT be reproduced on
    this machine** - Git-for-Windows' bash (5.2.37, MSYS2 build) is patched
    to strip a lone trailing CR, so a CRLF script runs fine here. Confirmed
    the tolerance is real: a hand-made CRLF script with `set -e`, a
    `$(dirname "$0")` cd, and an `if [ ... ]; then ... fi` ran clean under
    this box's `bash` and `sh`. That patch does not exist in Apple's bash
    or in distro bash, where CRLF `.sh` files are a well-known hard failure.
    The shebang failure above is interpreter-resolution, not shell parsing,
    so it fails identically everywhere regardless of that patch.

So: a drive provisioned on a `core.autocrlf=true` Windows PC and then taken
to a Mac fails on the first `launch-north-forge.sh` run. That is the
"issue with cheap usb flash" - the stick is exFAT so it can cross platforms,
and crossing platforms is exactly what trips the CRLF.

## Files inspected

- `launch-north-forge.bat` (full read, 368 lines, 21 091 bytes) - Zone A. Traced
  the entire first-run path. No blocking bug found in it (many prior bugs
  already fixed in-file per its own comments). CRLF is correct for `.bat`.
- `launch-north-forge.sh` (full read, 424 lines, 21 787 bytes CRLF /
  matches HEAD blob at LF) - Zone A. The CRLF break is here.
- `.env.example` (full read, 36 lines) - Zone A. `ANTHROPIC_API_KEY=your-key-here`
  (11 chars); both launchers' `< 30`-char placeholder guard catches it
  correctly. No bug.
- `.gitignore` (full read, 74 lines) - Zone A. All first-run generated
  markers and `.hermes*` paths are ignored; `*.log` covers `forge-events.log`.
  No bug.
- `Advanced/provision-new-drive.ps1` (full read, 156 lines) - Zone A. Windows
  provisioning script; rejects FAT32/FAT and requires exFAT (L71-78);
  `git clone` inherits the host's line-ending config (relevant to the cause
  above). No bug in the script itself.
- `FIRST_TIME_README.txt` (full read, 60 lines) - Zone B. Documents the
  Mac/Linux "drag the .sh into Terminal" first-run path that the CRLF breaks.
  Read only, not modified.
- `CLAUDE.md` (full, via system context, 19 425 bytes) - Zone B. Zone
  definitions + standing rules.
- `README.md` (full read, 212 lines / 24 413 bytes) - Zone B. Read for
  Task 2 to diff against Kenneth's pasted revision before placement.
- `logs/CLAUDE_CODE_LAST_AUDIT.md` (prior session's report) - Zone A.
- `NEXT_STEPS.md` (targeted reads: header, lines 200-340, 425-460, tail) -
  Zone C. Found the pre-existing 2026-08-29 carry-over flag naming the
  `.bat` vs `.sh` `.hermes.md` CRLF divergence on `core.autocrlf=true`
  machines (L229-234) - same root cause as this bug.
- `tests/repository-hygiene.sh` (full read) - Zone A. Checks `.provider-choice`
  / `.env` stay ignored and `.env` unstaged. Does not check line endings.
- `scripts/` and `tests/` directory listings; confirmed all six launcher-
  referenced scripts exist (`name_validation.py`, `assemble-skills.ps1`,
  `ensure-hermes.ps1`, `ensure-hermes.sh`, `hermes-drive.ps1`,
  `hermes-drive.sh`).
- `assets/` listing - `north-forge.ico` present (both launchers reference it
  for the shortcut icon).
- Git plumbing: `git config --get core.autocrlf` / `core.eol` /
  `core.filemode`; `git ls-files --eol`; `git show HEAD:<file> | file -`;
  `git fetch --all --prune`; `gh pr list` / `gh pr status`; `git log`,
  `git status`, `git diff`, `git diff --cached`, `git branch -a`,
  `git remote -v`.
- Reproduction scratch scripts under the session scratchpad (CRLF shebang ->
  `env` 127; CRLF heredoc under `sh`/`dash`; CRLF `set -e` + `cd` + `if`).

## Zone A changes made

### 1. New file: `.gitattributes` (repo root)

Before: did not exist. After (37 lines, full content):

```
# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: .gitattributes | Version: 1.0.0 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
#
# Line-ending policy for scripts.
#
# The drive is exFAT on purpose: one cheap USB stick has to run on Windows,
# macOS, and Linux. exFAT cannot store the executable bit, so the macOS/Linux
# first run is `bash launch-north-forge.sh` executed straight off the stick,
# reading these exact bytes (see the comment block near the top of
# launch-north-forge.sh).
#
# Without a rule here, a checkout on a Windows machine whose git has
# core.autocrlf=true rewrites every *.sh to CRLF. That drive then fails on the
# very first Mac/Linux launch:
#   - run via the shebang -> `env: 'bash\r': No such file or directory` (127)
#   - run as `bash launch-north-forge.sh` -> bash `syntax error near
#     unexpected token` on a `then` / `fi` / `do` that now ends in \r
# provision-new-drive.ps1 clones with whatever git config the provisioning PC
# has, so the fix has to live in the repo, not in a machine's global config.
#
# Pin shell scripts to LF in the working tree on every platform; keep the
# Windows-only scripts CRLF.

*.sh        text eol=lf
*.command   text eol=lf

*.bat       text eol=crlf
*.cmd       text eol=crlf
*.ps1       text eol=crlf

# Binary assets - never run line-ending or diff filters on these.
*.png       binary
*.ico       binary
```

Deliberately NOT a blanket `* text=auto eol=lf`: that would force a
line-ending renormalization of every text file, including the Zone B
authored content (`README.md`, `.hermes.template.md`, `mode-blocks/*`,
`skills-source/**`, `KYO_KB_TITAN...html`, `USER_MANUAL.md`,
`FIRST_TIME_README.txt`). Their committed blobs are already LF and their
working-tree bytes were left untouched. The rule set here only pins the
script file types, which are all Zone A.

Note: `git add` printed `warning: in the working copy of '.gitattributes',
LF will be replaced by CRLF the next time Git touches it` - `.gitattributes`
has no self-rule and `core.autocrlf=true` will store the working copy as
CRLF. Harmless (git parses `.gitattributes` regardless of its own line
endings); left as-is rather than add `* text=auto` just to silence it.

### 2. Working-tree renormalization of `*.sh` on this drive

The committed blobs were already LF, so nothing to re-commit for the scripts
themselves - only this drive's working copies were wrong. Sequence:

```
git add .gitattributes
git ls-files -z '*.sh' '*.command' | xargs -0 rm -f
git checkout -f -- .
```

With `.gitattributes` (`*.sh text eol=lf`) in place, `git checkout`
re-materialized the 13 `.sh` files with LF regardless of `core.autocrlf`.

Before -> after, per file (CR-line count -> 0; sha256 now equals the HEAD
blob):

| file | before: CR-lines / bytes / sha256 | after |
|---|---|---|
| Advanced/full-drive-reset.sh | 25 / 1900 / df01054c... | 0 CR, matches HEAD blob |
| Advanced/toggle-mode.sh | 111 / 5496 / 913569d1... | 0 CR, matches HEAD blob |
| launch-north-forge.sh | 423 / 21787 / 184b50ea... | 0 CR / sha256 628c13a1117dda4dd94c375d8218a50626c2eee1b5debd71b2dbc0bdb1e6d4c0 == HEAD blob |
| scripts/ensure-hermes.sh | 95 / 5477 / 1f7ff42c... | 0 CR / sha256 3d7bd1f6...== HEAD blob |
| scripts/hermes-drive.sh | 28 / 1243 / b73e42c0... | 0 CR, matches HEAD blob |
| tests/repository-hygiene.sh | 23 / 690 / c5c36fe7... | 0 CR, matches HEAD blob |
| tests/reset-integration.sh | 71 / 3243 / f3cd195c... | 0 CR, matches HEAD blob |
| tests/test-drive-hermes-install.sh | 74 / 4055 / 18d10c69... | 0 CR, matches HEAD blob |
| tests/test-drive-local-hermes.sh | 81 / 3397 / 57cbce95... | 0 CR, matches HEAD blob |
| tests/test-free-provider.sh | 55 / 2420 / 26273467... | 0 CR, matches HEAD blob |
| tests/test-launcher-hermes-home.sh | 61 / 3401 / 55fd906e... | 0 CR, matches HEAD blob |
| tests/test-skill-assembly.sh | 62 / 2052 / 37cea13c... | 0 CR, matches HEAD blob |
| tests/two-drive-hermes-isolation.sh | 140 / 6614 / d7338c8a... | 0 CR / sha256 5b8469cd...== HEAD blob |

Post-fix verification:
- `git ls-files --eol '*.sh'` -> all 13 now `i/lf  w/lf  attr/text eol=lf`.
- `file` on all 13 -> `... ASCII text executable` with **no** "CRLF line
  terminators".
- `head -1 launch-north-forge.sh | od -c` -> `#!/usr/bin/env bash\n` (no `\r`).
- `bash -n` (parse-only) on all 13 -> **13 PASS / 0 FAIL**.
- `.bat`/`.cmd`/`.ps1` (13 files) -> still `w/crlf`, now with
  `attr/text eol=crlf`; working-tree bytes unchanged.
- `git status` -> clean except the staged new `.gitattributes` and the
  Zone C `NEXT_STEPS.md` edit below. No `.sh` shows as modified (worktree
  LF == blob LF).

## Zone C changes made

- `NEXT_STEPS.md` - appended a dated section "Session 2026-09-05 (CRLF
  first-run break, Claude Code) - .gitattributes added" recording the
  finding, the reproduction, the fix, and that it closes the script side of
  the 2026-08-29 carry-over CRLF flag. No existing lines changed; append
  only.

## Zone B findings (not fixed - reported only)

- **Task 2 placed a new `README.md` (see the "Task 2" section below).** That
  was a Blacksmith placement, not a Claude-Code edit - byte-for-byte as
  pasted. The one carry-over it does NOT resolve: the still-open `b744b10` /
  prior-session `Advanced/` path update. The pasted README keeps the old
  flat-root paths (`toggle-mode.bat / .sh`, `full-drive-reset.bat / .sh`,
  `machine-reset.bat`, `provision-new-drive.ps1` in the file tree;
  `.\provision-new-drive.ps1` in the powershell example). Nothing was
  reverted - those paths were never fixed in README - but that Zone B gap is
  still open and now sits under a large decorative commit. Still needs its
  own byte-for-byte handoff (Option A / Option B from the b85d649 report).
- The prior session's BLOCKED `USER_MANUAL.md` `Advanced/` path update still
  needs byte-for-byte content (unchanged, not touched).
- An earlier audit flagged an unstaged `README.md` `<img>` title-icon edit.
  It was NOT present in this checkout - `git status` / `git diff` were clean
  at session start. The new pasted README does not carry an `<img>` title
  tag either (it uses an ASCII wordmark). Noted, no action.
- `WELCOME.html` at repo root is still untracked and still not in any
  CLAUDE.md zone list (prior audit's finding). `launch-north-forge.bat`
  L52-63 depends on it; a fresh clone hits the "WELCOME.html is missing"
  warning branch. Unchanged - needs Kenneth / Claude Project chat to place
  or confirm committing it.

## Commits made this session

1. **`b768e29`** "Add .gitattributes to pin shell scripts to LF (fixes
   broken macOS/Linux first run)" - pushed to `origin/main`. Files:
   `.gitattributes` (NEW, Zone A), `NEXT_STEPS.md` (Zone C dated entry),
   `logs/CLAUDE_CODE_LAST_AUDIT.md` (Zone A, the first version of this
   report). The 13 `*.sh` files are NOT in this commit - their committed
   content did not change (blobs were already LF); only this drive's working
   copies were corrected, a local checkout artifact.
2. **`4fd9fa6`** "Place blinged README.md (in-session Blacksmith handoff)" -
   pushed to `origin/main`. One file: `README.md` (Zone B placement),
   202 insertions / 6 deletions. Written byte-for-byte as Kenneth pasted it.
3. **(this commit, pending)** `logs/CLAUDE_CODE_LAST_AUDIT.md` - this
   rewritten report covering both tasks. Zone A standing authorization.

`.env` never staged (not present on this drive). `git status` clean between
each commit and at end.

## Uncertain / flagged for primary GPT review

1. **`.gitattributes` is not literally on the CLAUDE.md Zone A list.** I
   treated it as Zone A by direct analogy to `.gitignore`, which *is* on the
   list: both are git repo-config dotfiles, mechanical, no field-support or
   authored content, and a wrong line ending here is "an objective code
   defect" in the Zone A sense. If the Blacksmith wants new top-level repo
   files to route through a handoff even when they are pure plumbing, say so
   and I will revert - the working-tree renormalization of the `.sh` files
   stands on its own (those files are all explicitly Zone A) but without
   `.gitattributes` committed, the next `core.autocrlf=true` checkout / pull
   re-breaks them.
2. **The `bash script.sh` parse-failure path is asserted, not reproduced
   here.** Git-for-Windows bash tolerates trailing CR, so this machine runs
   CRLF `.sh` files fine. The shebang failure (`env: 'bash\r'...`, exit 127)
   *was* reproduced and is platform-independent. Someone with a real Mac or
   Linux box should confirm `bash launch-north-forge.sh` now runs clean off
   the renormalized drive - I could not.
3. **No end-to-end launch was run.** `hermes` is not installed on this
   machine, and there is no live model key on this drive, so neither
   launcher was executed to completion this session. The fix is verified at
   the byte / `bash -n` level only.
4. **`.gitattributes` line-ending choice for `.ps1`.** I pinned `*.ps1` to
   `eol=crlf` (Windows-native, matches current state). PowerShell 5.1+ and
   pwsh both accept LF fine, so `eol=lf` would also work and would be more
   consistent with a "LF in the repo" stance. Left as CRLF to change nothing
   about the Windows scripts' current working-tree bytes. Easy to flip if
   preferred.
5. **`archive/setup-thumbdrive.ps1`** is now covered by the `*.ps1 eol=crlf`
   rule. `archive/` is called out in CLAUDE.md as read-only historical
   storage "even though it carries no separate zone label". The attribute
   does not modify the file (it is already CRLF and stays CRLF); it only
   pins that. Flagging that the rule's glob does reach into `archive/`.

## Task 2 - `README.md` Zone B placement (commit `4fd9fa6`)

### Trigger / authorization
In the same session, after Task 1 was committed, Kenneth pasted a full
revised `README.md` and described wanting "bling navigation Wingding and
Github elements ... Just for me ... when I'm working and someone is watching
they see bling." I did NOT auto-apply it. I read the current `README.md`
(Zone B, 212 lines), read the pasted version, and presented a diff-flag
summary (dropped intro paragraph; the `Advanced/` path fix not folded in;
em-dash vs house-style hyphen; new `img.shields.io` dependency; some
sections now condensed + full). I then asked place-as-is vs revise-first vs
skin-only. Kenneth answered **"Place as-is + push"**. Per CLAUDE.md's Zone B
placement exception + the 2026-08-26 CONFIRMED note ("an in-session named
handoff from Kenneth ... identifying a specific Zone B file ... with an
instruction to commit it - is the intended and sufficient trigger"), this
is a valid placement. It is placement, not editing: I wrote the file
byte-for-byte as pasted and did not compose, rephrase, or extend it.

### Diff-before-placement check (CLAUDE.md 2026-08-29 STANDING RULE)
`git diff --cached -M README.md`: 202 insertions, 6 deletions. Verified line
by line that no previously-recorded deliberate fix is reverted:
- `forge-audit` CLAUDE.md-token CORRECTION note in the file tree - PRESERVED
  verbatim.
- `.hermes/skills/` folder-name correction paragraph - PRESERVED.
- "Project skills need to be trusted" auto-trust-tradeoff section - PRESERVED.
- "Setting up a new drive" FAT32-refusal / exFAT-or-NTFS text - PRESERVED.
- `%%LOCALAPPDATA%%\hermes`, the `full-drive-reset` "type the full path not
  YES" section, the RESET eight-marker list - all PRESERVED.
- "Built on Hermes Agent" + "Branding" ATTRIBUTION.md references and the
  "Nous Research is not affiliated with or endorsing this deployment" line -
  PRESERVED.
- `## Repo governance`, `## Model choice matters`, `## Two-repo
  architecture`, the full `## What's in here` tree, the GitHub-CLI admin
  steps (now inside a `<details>`) - all PRESERVED, content unchanged.

### What the 6 deletions are
1. Old H1 `# North Forge - Hermes Edition` -> `<div align="center">` + ASCII
   header + `# North Forge — Hermes Edition` (em-dash).
2. `North Forge - Hermes Edition (Kyocera Edition v21.8) is part of the
   North Forge project. Created and maintained by Kenneth C. Walker Jr. -
   Senior Technical Support Engineer, TSC.` -> the descriptor moves into the
   centered badge block; the "Created and maintained by Kenneth C. Walker
   Jr. — Senior Technical Support Engineer, TSC" credit is kept there.
3. `A field-support AI built specifically for Kyocera ... never asks you to
   remember a slash command you don't already know.` -> shorter one-line
   description.
4. **`Why this exists: a technician on a call shouldn't have to open a
   manual ...` - DELETED with no replacement.** Kenneth was shown this
   specific flag before answering "place as-is".
(5-6 are the blank lines around those.)

### Additions (the "bling")
ASCII compass + `NORTH FORGE` wordmark + anvil in a fenced block; 5
`img.shields.io` `for-the-badge` shields (Engine / Version / Repository /
Modes / Platform); `> [!NOTE]` and `> [!IMPORTANT]` GitHub admonitions;
`## ⚡ At a glance` 2-col table; `### What it is designed to do` bullet list;
`## 🧭 Navigate` anchor-link row; `## 🏗 Architecture` with a
```mermaid flowchart TD``` and a `<details>` "Why this architecture exists";
`## 🧰 Skills and runtime content` with a `skills-source/` tree and a
`### FULL vs SALES` capability table (✅ / —); `🔧` on the Maintenance
heading; the GitHub-admin block wrapped in `<details><summary>🔐
Maintainer-only GitHub administration`; a centered `### 🔥 North Forge`
footer with `<sub>` credit line. Several `---` rules and blank lines between
existing sections.

### Verification
- `git diff --cached --stat` -> `README.md | 208 +/- , 202 insertions(+), 6
  deletions(-)`.
- Fenced-block delimiters: 20 ` ``` ` lines = 10 balanced blocks
  (`text` ASCII art, `mermaid`, `text` skills tree, the big `What's in here`
  block, `powershell` x2, `powershell` x2 more in the admin steps...). Even
  count, no unterminated block.
- 26 `#`-headings total; all 19 `## ` sections listed and present; anchor
  targets in the Navigate row match the generated slugs for the headings
  they point at (GitHub strips the emoji + leading space, hence the
  leading `-` in `#-architecture` etc).
- Not rendered/checked: actual GitHub preview (no network render this
  session), and whether every `img.shields.io` URL returns 200 (external,
  not fetched).
- `git ls-files --eol README.md` -> `w/lf` (my Write wrote LF; the other
  `.md` files on this drive are CRLF in the working tree). `.md` has no
  `.gitattributes` rule; `core.autocrlf=true` will store the blob as LF
  anyway, same as every other tracked `.md`. Cosmetic working-tree-only
  difference, left as-is.

### Flagged for primary GPT (Task 2)
- The `b744b10` `Advanced/` path gap is still open and now sits under this
  large decorative commit. If/when the Option A/B handoff for it arrives, it
  must be diffed against `4fd9fa6`, not against `b85d649`.
- `README.md` now depends on `img.shields.io` (5 external image requests on
  render). This repo is otherwise deliberately self-contained (it gitignores
  `.claude/` for that reason). Called out; Kenneth accepted it via
  "place as-is".
- The "Why this exists" rationale paragraph is gone from the README. If that
  copy still has value it now lives nowhere in the repo's user-facing docs.
- House style drift: the placed file uses em-dashes in headings/taglines
  where every other file here uses spaced hyphens. Placement fidelity vs
  house style - placement won, per instruction.

## Status

Needs primary GPT review.
- Task 1: ratify `.gitattributes` as a Zone A addition or tell me to revert
  (Uncertain item 1); confirm on real macOS/Linux hardware that the
  renormalized `launch-north-forge.sh` now runs (Uncertain item 2). The
  first-run break on this drive is fixed and verified at the byte / `bash
  -n` level.
- Task 2: `README.md` placed byte-for-byte per an explicit in-session
  Blacksmith instruction and pushed (`4fd9fa6`). Confirm the placement is
  accepted, and note the four Task-2 flags above - especially that the
  `Advanced/` path gap is still open on top of this commit and that the
  "Why this exists" paragraph was dropped.
