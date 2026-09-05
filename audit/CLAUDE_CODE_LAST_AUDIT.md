# Claude Code Session Audit

Timestamp: 2026-09-04 (session following the prior same-day "Full integrity
audit, report-only" session recorded in git history at commit `82bd18b`)
Requested task: User said "update hermes," which surfaced a standing block
in `NEXT_STEPS.md` ("do not run `hermes update` until the [4279-commits-
behind] figure is explained") - flagged that back rather than running it.
User then said "Fix all open items please." This report covers that second
request: a full pass over `NEXT_STEPS.md`'s and `DEMO_PREP_BACKLOG.md`'s
open/OPEN-tagged items, fixing everything in Zone A/C and reporting the rest.

## Files inspected
- `CLAUDE.md` (re-read for zone boundaries before acting)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior session's report, full read)
- `NEXT_STEPS.md` (full read, 485 lines before this session's edits)
- `DEMO_PREP_BACKLOG.md` (full read, 248 lines before this session's edits)
- `audit/HANDOFF_2026-09-04_SESSION_CHANGES.md` (full read - the GPT-facing
  handoff narrative from the earlier same-day session, used to cross-check
  which "open" backlog items were actually already closed)
- `.gitignore` (full read)
- `launch-north-forge.bat` (full read, then edited)
- `launch-north-forge.sh` (full read, not edited - the bug fixed this session
  is Windows-only)
- `WELCOME.html` (full read - untracked, referenced by the Windows launcher)
- `README.md` (diffed against HEAD - has an uncommitted Zone B edit, not
  read in full this session since no action was taken on it)
- `forge-events.log` (repo-root, gitignored per-drive log - tailed, then a
  specific `[ansi-fix]` line investigated in detail)
- git: `git pull`, `git status`, `git diff`, `git log --oneline -5 -- <file>`,
  `git log --stat -- assets/`, `git ls-files`, `git ls-files assets/`
- `hermes doctor`, `hermes skills list --source local`
- Windows registry: `HKCU:\Console` (`Get-ItemProperty`, `Get-Item -Path
  ... | Select Property`, `Get-ChildItem` for subkeys) - to check the
  `forge-events.log` `[ansi-fix]` claim against live state
- `[Environment]::GetFolderPath("Desktop")` and the
  `HKCU:\...\User Shell Folders\Desktop` registry value - to diagnose the
  Desktop-shortcut bug

## Zone A changes made
**`launch-north-forge.bat`** - commit `0c11bbb`.

Before: the first-run Desktop-shortcut block hardcoded
`%USERPROFILE%\Desktop\North Forge.lnk` for both the `if not exist` guard
and the `WScript.Shell.CreateShortcut(...)` target path.

Bug, reproduced (not assumed): on this machine, `%USERPROFILE%\Desktop`
(`C:\Users\kwalk\Desktop`) does not exist - `[Environment]::GetFolderPath
("Desktop")` and the `HKCU:\Software\Microsoft\Windows\CurrentVersion\
Explorer\User Shell Folders` `Desktop` value both resolve instead to
`C:\Users\kwalk\OneDrive\Desktop` (OneDrive Desktop redirection, a common
Windows configuration). Running the exact PowerShell line from the launcher
directly reproduced the real failure: `$s.Save()` threw
`System.IO.DirectoryNotFoundException` ("Unable to save shortcut ..."). The
batch file's own `2>nul` was swallowing this error and only logging a bare
`[WARNING] [shortcut]: Desktop shortcut creation FAILED` - which is in fact
already sitting in this drive's `forge-events.log` (timestamp `Fri
09/04/2026 21:44:05.31`, from an earlier session/launch, not something I
triggered). Confirmed via `ls "$USERPROFILE/Desktop/"` that no
`North Forge.lnk` currently exists anywhere - this is a live, current bug,
not a historical one.

After: resolves the real Desktop path via
`(New-Object -ComObject WScript.Shell).SpecialFolders('Desktop')` into a
batch variable (`DESKTOPDIR`) before both the existence check and the
shortcut creation, falling back to the old `%USERPROFILE%\Desktop` if that
call ever returns nothing. Both the success and failure log lines now also
record the resolved target path.

Verification performed (two independent methods, not just "looks right"):
1. Direct PowerShell repro against the real OneDrive Desktop - created a
   test shortcut with the new resolution logic, confirmed `Test-Path` true,
   removed it.
2. Extracted the *exact* new batch snippet (not a paraphrase) into a
   standalone `.bat` and ran it under real `cmd.exe` (`cmd.exe /c
   test-shortcut-snippet.bat`, not just Git Bash, since quoting/expansion
   inside `powershell -Command ^`-continued lines is cmd.exe-specific and
   would not be validated by Git Bash alone) - output: `Resolved
   DESKTOPDIR=C:\Users\kwalk\OneDrive\Desktop` / `RESULT: SUCCESS`. Test
   file deleted afterward, cleaned up.
3. Paren-balance check on the full file after editing: depth 0 (via a small
   Python script counting `(`/`)` across the whole file).

`.sh` was NOT touched - OneDrive Desktop redirection is a Windows-only
failure mode; the Mac launcher's `$HOME/Desktop` is not subject to it.

## Zone B findings (not fixed - reported only)

1. **`README.md` has an uncommitted working-tree edit.** At session start
   (before I touched anything), `git diff` showed the title line changed
   from `# North Forge - Hermes Edition` to add an `<img src="assets/
   north-forge-icon.svg" ...>` tag before the heading text. This was not
   made by me this session, and no in-session handoff named this specific
   change as ready to place - so per the Zone B rules I left it exactly as
   found, uncommitted, untouched. Flagging so it isn't mistaken for
   something Claude Code did, and so it doesn't get silently lost if
   someone runs a stash/reset later without knowing it's there.

2. **`WELCOME.html` is untracked and not in ANY CLAUDE.md zone list** - a
   real gap, more urgent than the `research-log/` gap the prior audit
   found, because it is already load-bearing: `launch-north-forge.bat`
   line 7 does `start "" "WELCOME.html"` on every first run
   (`.readme-shown` gate), and this exact behavior is what the
   `82bd18b` "welcome open" logging (recent commit history) was built
   to support. Read the file in full - it's a styled quickstart page
   (Kyocera + North Forge branded header, "how to open it," `/menu`
   pointer, "keep your judgment in charge" caution section), referencing
   `assets/logo-kyocera-1024.png` and `assets/north-forge-icon.svg` - both
   of which ARE already tracked and committed (`3e979ed`, `4cc2c9f`), so
   once `WELCOME.html` itself is committed the images will resolve
   correctly with no further work. Content-wise this reads as Zone B
   material by the same reasoning CLAUDE.md already applies to
   README.md/FIRST_TIME_README.txt (Blacksmith-reviewed, user-facing,
   accuracy matters) - so I did not compose, edit, or commit it. Right now,
   on a genuinely fresh `git clone` to a new drive, the first-run welcome
   page would silently fail to open (hit the `[WARNING] [welcome]:
   first-run WELCOME.html auto-open FAILED` branch) because the file
   simply wouldn't exist. Needs either: Kenneth/the Claude Project chat
   handing this exact file over for placement (even though it's already
   sitting in the working tree - the handoff is the authorization, not the
   file transfer), or an explicit decision that it's fine as Zone A/C
   instead (I don't think it is, given its content, but I'm not the one
   who gets to decide that).

3. **`forge-events.log` contains an unverified/possibly-false "fixed"
   claim about the ANSI/VT100 escape-code issue** (see "Uncertain /
   flagged" below - documented there in full since it's as much an
   integrity concern as a Zone B content issue).

## Commits made this session
- `0c11bbb` - "Fix Desktop shortcut creation failing on OneDrive-redirected
  Desktops" (Zone A, `launch-north-forge.bat`)
- `9c88064` - "Open-items review: close 2 stale backlog entries, annotate 2
  unresolved ones" (Zone C, `NEXT_STEPS.md` + `DEMO_PREP_BACKLOG.md`)

Both pushed: `82bd18b..9c88064 main -> main`. `git push` output confirmed
clean (fast-forward, no conflicts).

## Zone C corrections made this session (part of `9c88064` above)

- `DEMO_PREP_BACKLOG.md` item 2 (fault-logging skill priority bump) was
  still marked "(OPEN)" and said "Build this one next" even though
  `skills-source/tsc-only/fault-logging/SKILL.md` was actually placed
  2026-08-28 (`d414f81`) per `NEXT_STEPS.md`'s own "Done" section. Marked
  RESOLVED with a cross-reference. This was a documentation-sync miss from
  an earlier session, not a real open task.
- `DEMO_PREP_BACKLOG.md` item 12 (`/audit` missing from `hermes skills
  list`) was still marked "(OPEN - Zone B reword needed)" even though the
  real fix landed and was *live-verified* 2026-08-29 (`a49580f`) - see
  `NEXT_STEPS.md`'s "Real-fix placement + live verification" section,
  which explicitly records `hermes skills list --source local` showing
  `forge-audit` listed (10/10, up from 9) after the fix. Marked RESOLVED
  with the same cross-reference. Also a stale-doc issue, not a real open
  task.
- `NEXT_STEPS.md`'s 2026-09-04 "Open items" section annotated in place
  (not removed - the checkboxes and original text are preserved, with
  status notes appended) rather than declared closed, since neither of the
  two items there actually resolved this session (see next section).

## Uncertain / flagged for primary GPT review

1. **The "4279 commits behind" banner remains completely unexplained.**
   Re-checked this session: `git branch -vv` still shows no ahead/behind
   annotation, `git pull` still reports "Already up to date," `git fsck`
   was not re-run this session (no reason to expect it changed since the
   prior session's clean result) but nothing else points at any drift. No
   new evidence in either direction. `hermes update` was correctly NOT run,
   per the explicit standing instruction in `NEXT_STEPS.md`. This stays
   open until Kenneth can reproduce the actual banner with a raw
   copy-paste/screenshot.

2. **The `forge-events.log` `[ansi-fix]` entry is suspicious and should be
   looked at, not trusted at face value.** Full detail: the log (repo root,
   gitignored, per-drive) contains this line, timestamped 2026-09-04
   20:56:57 - *before* this session started:
   ```
   [2026-09-04 20:56:57] [INFO] [ansi-fix]: HKCU\Console VirtualTerminalLevel was MISSING (ForceV2=0x1); set to 1 and re-query confirmed 0x1 - VT/ANSI escape rendering now enabled for legacy console sessions
   ```
   I grepped both `launch-north-forge.bat` and `.sh` for anything that
   writes an `[ansi-fix]` tag or touches the registry - zero matches in
   either file. Neither launcher produced this line. The most likely
   source is a live Hermes session itself, using its own terminal/
   computer-use tool capabilities (confirmed available per `hermes
   doctor`'s "Tool Availability" section: `computer_use`, `desktop_ui`,
   `terminal` all show as enabled) to self-diagnose and "fix" a garbled-
   escape-code symptom it or Kenneth encountered live.

   I then independently re-checked the actual current registry state this
   session, three ways:
   - `Get-ItemProperty -Path 'HKCU:\Console' -Name VirtualTerminalLevel` -
     errored (property does not exist).
   - `Get-Item -Path 'HKCU:\Console' | Select -Expand Property` (full
     property list, 44 entries) - no `VirtualTerminalLevel` anywhere in it.
     `ForceV2 = 1` IS present (confirming the log's own stated precondition
     was accurate), but `ForceV2` alone does not enable ANSI/VT processing
     by itself.
   - `Get-ChildItem -Path 'HKCU:\Console'` (per-application override
     subkeys) - five subkeys exist (`%%Startup`, two PowerShell entries,
     "Git Bash", "Git CMD") - none for `cmd.exe`, and none contain
     `VirtualTerminalLevel` either.

   **Conclusion: the registry does not currently show the fix the log
   claims was applied and confirmed.** I cannot tell from here whether (a)
   the fix was applied and then reverted by something else since 20:56:57,
   (b) the "re-query confirmed 0x1" part of that log line is simply false -
   whatever wrote it may have written to the wrong key, a different
   registry view (32-bit vs 64-bit `WOW6432Node`, not checked this
   session), or misreported success without actually re-querying, or (c)
   there's a distinction I'm missing between what that session's live
   Hermes agent could see/do and what a fresh PowerShell process run by me
   sees now. I did NOT attempt to re-apply the fix myself this session,
   deliberately: I never directly observed the original garbled `?[1;33m`
   symptom (I only have `NEXT_STEPS.md`'s prose description of it), so I
   have no reproduction to verify a fix against, and CLAUDE.md's Zone A
   rule requires reproducing a real bug before patching, not just finding a
   plausible-looking registry tweak in a log. This needs one of: Kenneth
   confirming the garbled-text symptom is gone (in which case the
   discrepancy is moot and can be closed as "fixed some other way"), or
   confirming it's still happening (in which case whatever wrote that log
   line either failed or was undone, and a real fix - registry, or possibly
   this repo's launchers setting `ENABLE_VIRTUAL_TERMINAL_PROCESSING`
   themselves - is still needed).

   Separately, worth noting for the primary GPT specifically: this is the
   second time in two sessions that a `forge-events.log` entry has recorded
   an action that doesn't trace back to any code in this repo's own
   launchers - the first being the underlying question of who/what fires
   the research/brief cron jobs versus what the launchers' self-healing
   blocks do. Not asserting a pattern from n=1, just flagging that
   `forge-events.log` entries with no corresponding source in the tracked
   scripts should probably be treated as "something external happened,
   verify before trusting" rather than "confirmed done," going forward.

3. **`WELCOME.html`'s zone assignment is a real open question, not just a
   missing file** (see Zone B findings above, item 2). Recommend this get
   an explicit answer (commit it as Zone B via a named handoff, or fold it
   into an existing zone) rather than staying implicitly unzoned - the same
   shape of problem as the `research-log/` gap the prior audit flagged,
   which did get resolved cleanly once someone made an explicit call
   (`research-log/` is now intentionally tracked, per the 2026-09-04
   DECISION in `NEXT_STEPS.md`).

4. **Live-mode QA parts 2/4 remain genuinely open but are not something I
   attempted.** `NEXT_STEPS.md` and the `HANDOFF_2026-09-04_SESSION_CHANGES.md`
   both note the API-key block is gone (a real cron pass succeeded,
   `research-log/kyocera-research-log.md` committed at `a801cb8`), and the
   documented path forward explicitly requires "an explicit spend go-ahead"
   before driving live `hermes chat` sessions across all 9 mode
   combinations. "Fix all open items" did not read to me as that specific
   go-ahead given the cost/spend framing already on record, so I left this
   one for Kenneth to trigger explicitly rather than assuming consent to
   spend.

5. Several DEMO_PREP_BACKLOG.md items remain genuinely open by design and
   were left untouched because they're blocked on Kenneth's own decisions
   or external input, not on anything Claude Code can act on: item 1
   (dashboard branding - needs logo/color/layout decisions), item 3 (Pine
   Barren Farms port - needs to know what the existing material actually
   is), item 5 (drive serial tracking - needs a real conversation about
   mechanism), item 9's option (b) (Anthropic console spend cap - an
   external action, not a repo change). None of these are "open items I
   failed to fix" - they're correctly still open pending non-Claude-Code
   input, same as `NEXT_STEPS.md` already documents for sales-assist FAQ
   content and the template `manual`-skill mention.

## Status
Needs primary GPT review - two flagged items above (the `[ansi-fix]` log
discrepancy, and `WELCOME.html`'s missing zone assignment) both warrant a
second opinion before being treated as closed. Everything else is either
genuinely fixed this session (the Desktop-shortcut bug, the two stale
backlog entries) or correctly still open pending a decision/input only
Kenneth or the Blacksmith chat can supply.
