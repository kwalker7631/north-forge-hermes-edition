# Claude Code Session Audit

Timestamp: 2026-09-05 18:36 EDT (America/New_York), on the `E:` drive clone
(`E:\north-forge-hermes-edition`)

Requested task: Kenneth's prompt, verbatim - "Check this pull fix any erros
wil execute first run. May have an isue with cheap usb flash". Read as: check
the pulled repo, fix anything that would break the **first run** off this
drive, with a hint that the problem is drive/USB-flash related. No handoff
file, no named Zone B target.

## Outcome: FIXED (Zone A). Every shell script on this drive was CRLF and the macOS/Linux first run was broken. Added `.gitattributes`, renormalized the working tree.

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

None new this session. Pre-existing open Zone B items are unchanged and were
not touched:
- The prior session's BLOCKED `README.md` / `USER_MANUAL.md` `Advanced/`
  path update still needs byte-for-byte content.
- An earlier audit flagged an unstaged `README.md` `<img>` title-icon edit.
  It is NOT present in this checkout - `git status` / `git diff` were clean
  at session start with no `README.md` modification. Either it was resolved
  or the drive was re-cloned since. Noted, no action.
- `WELCOME.html` at repo root is still untracked and still not in any
  CLAUDE.md zone list (prior audit's finding). `launch-north-forge.bat`
  L52-63 depends on it; a fresh clone hits the "WELCOME.html is missing"
  warning branch. Unchanged - needs Kenneth / Claude Project chat to place
  or confirm committing it.

## Commits made this session

Pending in one commit (about to `git add` + `git commit` + `git push` under
the Zone A / Zone C standing authorization):

- `.gitattributes` - NEW, Zone A. Line-ending policy; fixes the CRLF `*.sh`
  checkout.
- `NEXT_STEPS.md` - Zone C. Dated session entry for this fix.
- `logs/CLAUDE_CODE_LAST_AUDIT.md` - this report (Zone A).

The 13 `*.sh` files are **not** in the commit - their committed content did
not change (blobs were already LF); only this drive's working copies were
corrected, which is a local checkout artifact, not a content change.

`.env` never staged (not present on this drive). `git status` clean at start;
after the commit, clean again.

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

## Status

Needs primary GPT review - specifically item 1 (ratify `.gitattributes` as a
Zone A addition or tell me to revert it) and item 2 (confirm on real
macOS/Linux hardware that the renormalized `launch-north-forge.sh` now runs).
The immediate first-run break on this drive is fixed and verified at the
byte / parse level.
