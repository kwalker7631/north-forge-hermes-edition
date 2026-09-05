# Claude Code Session Audit

Timestamp: 2026-09-04 (session following the "open-items review" session
recorded at commit `cc32003`)
Requested task: User said "check if this is up to date please pull latest
version and review pull for errors." Interpreted as: run the standard
Session Start Protocol (pull, read last audit, check git/gitignore/hermes
state), then actually review the content that came down in the pull for
real defects - not just confirm the pull succeeded.

## Files inspected
- `CLAUDE.md` (re-read in full, 322 lines - noted it had changed on disk
  since a prior read earlier in this session; current Zone A list now
  includes `machine-reset.bat`, drops the old `setup-thumbdrive.ps1` entry
  in favor of a blanket `archive/` carve-out)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior report, full read, both before
  and after a second mid-session `git pull` brought in a newer version -
  the newer one, from the `cc32003` open-items-review session, was the one
  actually acted on)
- `NEXT_STEPS.md` (full read, 550 lines)
- `.gitignore` (full read, 41 lines)
- `launch-north-forge.bat` (full read; diffed line-by-line across the whole
  pulled commit range)
- `launch-north-forge.sh` (full read; diffed the same way)
- `toggle-mode.bat` (full read; diffed; then edited)
- `toggle-mode.sh` (full read; diffed; `bash -n` syntax-checked)
- `machine-reset.bat` (full read; diffed; then edited)
- git: `git pull` (x2 - see below), `git status`, `git diff a266e4b..82bd18b
  -- <Zone A files>`, `git diff 82bd18b..origin/main -- <files>`, `git log
  --oneline`, `git show 977703a:toggle-mode.bat`, `git fetch`, `git pull
  --rebase`, `git push` (x2), `git rev-parse HEAD origin/main`
- `hermes doctor`, `hermes skills list --source local`
- `.hermes/skills/` directory listing vs. `skills-source/**/SKILL.md` (to
  check for generated-artifact staleness)
- `WELCOME.html` existence check on this checkout (still absent)
- `README.md` (grepped for the `north-forge-icon` `<img>` tag flagged as an
  uncommitted edit in the prior audit - no longer present anywhere, see
  below)
- Isolated batch-file reproduction tests (own scratch files, not committed
  anywhere) to confirm a suspected cmd.exe parsing bug before touching any
  real file - detailed below

## Zone A changes made

**`machine-reset.bat` and `toggle-mode.bat`** - commit `e342f7a`
("fix: escape parens in admin_gate PASS echo - was silently bypassing
password check").

**The bug, reproduced (not assumed) before any fix was applied:**
The `:admin_gate` subroutine (both files carry a byte-identical copy) gates
mode switches, RESET, API key rotation, and full machine purge behind a
hardcoded password (`RumpleStiltskin`). Its PASS branch is:

```bat
if "!PW!"=="RumpleStiltskin" (
    >> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: attempt !ADMIN_ATTEMPTS! PASS (%~1)
    exit /b 0
)
>> "forge-events.log" echo [%DATE% %TIME%] [INFO] [admin-gate]: attempt !ADMIN_ATTEMPTS! FAIL (%~1)
echo Wrong password - %~1 cancelled.
if !ADMIN_ATTEMPTS! GEQ 3 echo Hint: Brothers Grimm
exit /b 1
```

The PASS-branch echo line contains a literal, unescaped `(%~1)` - a balanced
pair of parens as plain text - inside a `(...)` if-block. cmd.exe's block
parser miscounts parens embedded as literal text inside a compound
statement even when they are balanced; this is a well-known, if obscure,
batch-scripting pitfall, and every other place in this same codebase that
echoes parenthesized text inside a block already escapes it as `^(...^)`
(e.g. the cron re-registration log lines added in the same pull, `^(0 6 * *
*^)`; the `^(exit 0^)` hermes-exit line). This one instance was not escaped.

I built an isolated, minimal repro of the exact function shape (own scratch
`.bat` files, PowerShell tool, never touching the real repo files) before
concluding anything:
- A wrong password: the entire FAIL branch produced **zero output** and the
  function returned **errorlevel 0** - i.e. "PASS" - instead of erroring
  out with `exit /b 1`.
- A correct password: returned errorlevel 0 as intended, but the printed/
  logged line was silently truncated at the swallowed `)` (`PASS (rotate
  key` instead of `PASS (rotate key)`).

**Impact: the admin password gate accepted ANY password, including a wrong
one, silently.** Every action it was meant to protect - FULL/SALES mode
switching, drive RESET, per-machine API key rotation, and full machine
purge - was unprotected. Checked `git show 977703a:toggle-mode.bat` (the
commit that introduced this admin-gate feature, "Add two-tier passcode/
activation system per finalized simplified spec," part of the range this
session's first `git pull` brought in): the exact same unescaped-parens
`admin_gate` body was already present there, byte-for-byte identical to
what shipped in the later "Phase B" logging commit. **This bug has existed
since the password gate was first introduced in this pull - it did not
regress from something that once worked.**

**Fix applied:** escaped the PASS-branch line's parens as `^(%~1^)` in both
`machine-reset.bat` and `toggle-mode.bat`, matching the escaping convention
already used everywhere else in these files. Also found and fixed one more
instance of the identical unescaped-parens pattern in `toggle-mode.bat`'s
RESET flow (`else` branch of the drive-record check: `RESET executed (no
drive record present)`) - confirmed via a second isolated repro that this
specific instance was cosmetic-only (truncated the closing paren in the log
line, but did not corrupt the subsequent `.forge-mode`/`.hermes.md`/`.hermes
\skills` cleanup commands, which still ran correctly in the repro). Fixed
it anyway for consistency and because leaving one instance of a known-buggy
pattern in the same file, right next to the one that was just fixed for
being dangerous, seemed worth cleaning up rather than leaving as a landmine.

**Verification, both before and after the fix, against the real files (not
just the isolated repro):**
1. Isolated repro of the byte-identical function shape with a wrong
   password (before fix): confirmed silent errorlevel-0 bypass.
2. Isolated repro with the `^(...^)` fix applied: wrong password now
   correctly logs `FAIL` and returns errorlevel 1; correct password
   correctly logs `PASS` with the full parenthesized text intact.
3. **End-to-end test against the actual, fixed `toggle-mode.bat`** (copied
   into an isolated scratch dir, run under real `cmd.exe` with piped
   stdin: `FULL` + wrong password, then `SALES` + `RumpleStiltskin`,
   then `EXIT`). Result: the wrong password correctly printed "mode switch
   to FULL cancelled" and left `.forge-mode` unset; the correct password
   correctly set `.forge-mode` to `sales`. `forge-events.log` from that run
   shows exactly:
   ```
   [Fri 09/04/2026 21:58:40.82] [INFO] [admin-gate]: attempt 1 FAIL (mode switch to FULL)
   [Fri 09/04/2026 21:58:40.83] [INFO] [admin-gate]: attempt 2 PASS (mode switch to SALES)
   ```
   both lines now with correctly matched parens.
4. `machine-reset.bat` was not run end-to-end (it operates on
   `%LOCALAPPDATA%\hermes` by default, i.e. this machine's real per-machine
   Hermes install - running it live would risk deleting or purging real
   state). Its `:admin_gate` body is byte-identical to `toggle-mode.bat`'s
   (confirmed via diff before editing), and the same fix was applied to it
   the same way; the isolated repro in points 1-2 above covers the
   underlying function logic directly, which is sufficient given the two
   files share the exact same subroutine text.
5. `git diff` reviewed before committing: exactly 3 lines changed across
   the two files, nothing else touched.

Also reviewed and found clean (no defects): `launch-north-forge.bat`'s and
`.sh`'s new first-run blocks (WELCOME.html auto-open, drive-record prompt,
Desktop-shortcut creation, git-state logging, the `.hermes.md` size guard,
cron self-healing, hermes-exit logging) - all parens in echoed/logged text
in these blocks were already correctly escaped where they sit inside a
block, or don't need escaping because they sit outside one. `bash -n` was
run against both `.sh` files pulled this session - clean on both.

## Zone B findings (not fixed - reported only)

Nothing new this session. Two items already on record from the prior
(`cc32003`) audit remain open and were re-confirmed still open, not
re-investigated in depth (this session's task was the pull/review, not a
re-chase of these):

1. **`WELCOME.html` is still untracked and unzoned.** Confirmed absent from
   this checkout (`ls WELCOME.html` -> "No such file or directory").
   `launch-north-forge.bat` line 7 (`start "" "WELCOME.html"`) still
   depends on it existing; a fresh clone still hits the "auto-open FAILED"
   branch. No new action taken - still needs either a named handoff to
   place it, or an explicit zone decision.
2. The README.md `<img>`-tag edit the prior audit flagged as "uncommitted,
   not made by Claude Code" is **no longer present anywhere** - `git diff`
   on README.md is empty and `grep -n "north-forge-icon" README.md` returns
   zero matches. This was an uncommitted, local working-tree edit on
   whatever machine/session produced the prior audit; since it was never
   committed, it could not and did not travel via `git pull` to this
   checkout. Not a finding requiring action - just confirming it did not
   silently vanish from tracked content (it was never tracked to begin
   with).

## Commits made this session

- `e342f7a` - "fix: escape parens in admin_gate PASS echo - was silently
  bypassing password check" (Zone A: `machine-reset.bat`, `toggle-mode.bat`)

Push history this session: first push attempt was rejected (remote had
gained 3 new commits - `0c11bbb`, `9c88064`, `cc32003` - mid-session, a
Desktop-shortcut OneDrive fix plus a backlog cleanup pass from a concurrent
session). Ran `git fetch` + diffed the newly-arrived commits against the
files I'd touched to confirm no overlap before integrating (per the
STANDING RULE diff-before-placement habit, applied here to a rebase rather
than a handoff, since the same principle - don't blindly merge over
something without checking what it touches - applied): the OneDrive fix
touches a different code block (`launch-north-forge.bat`'s Desktop-shortcut
section) than the admin_gate fix, no overlap. `git pull --rebase` replayed
`e342f7a` cleanly on top of `cc32003`; confirmed the fix's exact diff lines
survived the rebase unchanged before pushing. Second push succeeded:
`cc32003..e342f7a main -> main`. `git rev-parse HEAD origin/main` confirms
both at `e342f7a` after push.

## Uncertain / flagged for primary GPT review

1. **The `RumpleStiltskin` admin password is stored in plaintext,
   identically, across three files** (`machine-reset.bat`,
   `toggle-mode.bat`, `toggle-mode.sh`), visible to anyone who can read the
   repo (which, given this is a Blacksmith-reviewed, git-distributed
   project, is presumably every technician/sales rep with drive access, or
   anyone with GitHub access if the repo were ever made less private). The
   "Hint: Brothers Grimm" message shown after 3 failed attempts makes the
   password discoverable by design even without repo access. I did NOT
   treat this as a bug to fix - it reads as a deliberate, low-stakes
   friction gate ("Phase 4" per the code comments), not an attempt at real
   access control, and changing the password or the scheme would be a
   design decision, not a code-defect fix, squarely outside what CLAUDE.md
   authorizes me to change unilaterally. Flagging it only so the Blacksmith
   can confirm that's the intended threat model (a soft speed bump, not
   real security) rather than something someone assumed was more locked
   down than it actually is.
2. **The Windows admin-gate prompt (`set /p PW=`) echoes the typed password
   to the screen in plain text** as it's typed, unlike the bash version
   (`toggle-mode.sh`'s `admin_gate` uses `read -r -s -p`, which is silent).
   Native `cmd.exe` batch has no built-in masked-input primitive equivalent
   to bash's `-s`; a real fix would need an auxiliary VBScript/PowerShell
   helper reading character-by-character, which is a small feature build,
   not a bug fix, so I did not attempt it. Flagging as a Windows/Mac
   platform-behavior inconsistency worth a decision, not fixing it myself.
3. Everything else flagged as open in the prior (`cc32003`) audit was NOT
   re-investigated this session and should be considered exactly as
   documented there, not re-verified by me today: the "4279 commits behind"
   banner (still unexplained, no new evidence either way, not re-checked
   this session), and the `forge-events.log` `[ansi-fix]` entry claiming a
   registry fix that a prior session's direct registry check could not
   confirm actually holds. I did not re-run `git fsck`, did not re-check
   the `HKCU:\Console` registry state, and did not re-attempt `hermes
   update` this session - none of that was in scope for "pull and review
   the pull," and re-stating the prior session's findings as freshly
   re-verified would overstate what I actually checked today.
4. The locally-generated `.hermes/skills/` directory (last built
   2026-09-02 02:58, per file timestamps) is stale relative to the
   `skills-source/` this pull brought in - it's missing `daily-brief` and
   `manual`, both of which exist as real `SKILL.md` files in
   `skills-source/shared/` and are correctly listed in this pull's own
   `NEXT_STEPS.md` narrative (skill count 15 -> 16). This is expected,
   by-design behavior, not a bug: `.gitignore`'s own comment says these are
   "generated at each launch," and no launch has run on this machine since
   before this pull landed. `hermes skills list --source local` currently
   shows 14 local skills + `hermes-windows-maintenance` (15 total),
   confirming the stale/pre-pull count. The next `launch-north-forge.bat`
   run will rebuild `.hermes/skills/` from the current `skills-source/` and
   pick up both new skills automatically - noting this only so it isn't
   mistaken for a registration bug if someone runs `hermes skills list`
   before relaunching.
5. `hermes doctor` reported 3 issues, all environment/machine-level, none
   repo-specific and none touched by this pull: 1 npm vulnerability in the
   `agent-browser` workspace, 2 npm vulnerabilities in the `web` workspace
   (described by `hermes doctor` itself as a "build-tool advisory... clears
   via lockfile bump"), and missing optional API keys (OpenRouter, xAI,
   Nous Portal, MiniMax, Discord). None of these are Zone A/B/C content in
   this repo - they belong to the Hermes engine install itself
   (`%LOCALAPPDATA%\hermes`), outside this repo's scope, so no action taken
   here.

## Status
Findings Present - one real, now-fixed security-relevant bug (the
admin_gate password bypass, both files, Zone A, fixed and pushed at
`e342f7a`), plus two smaller flagged-not-fixed observations (plaintext
password storage, unmasked Windows password prompt) that are design
questions for the Blacksmith rather than code defects. All prior-session
open items (commits-behind banner, ansi-fix registry claim, WELCOME.html
zone gap) remain exactly as previously documented - not re-investigated
this session, not newly resolved, not newly regressed.
