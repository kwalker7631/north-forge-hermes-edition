# Claude Code Session Audit

Timestamp: 2026-09-05 (session start ~05:11 local; this report written ~06:00
local, all times from tool-observed system clock during the session)
Requested task: "Pull the HERMES_HOME isolation work Codex just completed
(audit/CODEX_HERMES_HOME_ISOLATION_2026-09-05.md plus its code changes). Read
the report, read the actual diff (not just the report's description), and
empirically verify - scratch state only - that: two scratch drives never
leak config/cron state into each other or a shared install; a fresh drive's
first launch actually completes under the new isolation; cron
re-registration on a later run still targets the drive-local install, not a
shared fallback; RESET's wipe list correctly includes/excludes the new local
install folder per Codex's stated reasoning. If testing surfaces a real bug
Codex's report didn't catch, fix it directly (Zone A authority, standing)
and document the catch explicitly."

## SESSION START CHECK (per CLAUDE.md's Session Start Protocol)

Pulled: `git pull origin main` -> "Already up to date." No remote changes.
Last audit read: Yes - prior version was about a Zone B CLAUDE.md placement
(the no-PATH-shadowing standing rule), unrelated to this session's task;
status was Clean.
Uncommitted at start: `launch-north-forge.sh` modified (unstaged, no
untracked files - confirmed via `git status --porcelain=2` and
`git ls-files --others --exclude-standard`). This turned out to be the
actual Codex HERMES_HOME work in question (see finding 1 below).
.gitignore: OK - confirmed `.env`, `.forge-mode`, `.drive-record.txt`,
`.agent-name`, `.provider-choice`, `.readme-shown`, `/.hermes-home/` are all
present via `git check-ignore -v`.
hermes doctor: Clean overall on the shared host install
(`~/AppData/Local/hermes`) - 3 minor unrelated issues only (2 npm audit
advisories in bundled browser/web tooling, and a suggestion to run
`hermes setup` for optional API keys). No security advisories, config
version up to date (v40), no deprecated keys.
Project skills (shared host, `hermes skills list --source local`): 16
local skills installed and enabled (assist, audit, daily-brief, draft, esc,
flush, hl, kb, kyocera-research, log, manual, menu, sales, switch, train,
web) - all "local"/"local"/"enabled". This reflects the shared host
`~/AppData/Local/hermes` install from a prior real North Forge run on this
machine, not anything created by this session's scratch testing.

## Files inspected

- `launch-north-forge.sh` (full read, both HEAD and the uncommitted working
  copy; `git diff` of the uncommitted change)
- `scripts/ensure-hermes.sh`, `scripts/hermes-drive.sh` (full read - the two
  modules the uncommitted diff's own comment names as the reason the fix was
  needed)
- `scripts/drive-reset-safety.py`, `full-drive-reset.sh` (full read)
- `toggle-mode.sh` (grepped for `.hermes-home`/RESET handling), grep of
  `machine-reset.bat`, `full-drive-reset.bat`, `scripts/machine-reset-safety.ps1`
  for the same
- `tests/test-launcher-hermes-home.sh` (full read, then edited - see below)
- `tests/test-drive-hermes-install.sh`, `tests/test-drive-local-hermes.sh`,
  `tests/two-drive-hermes-isolation.sh` (full or partial read; all run)
- `tests/test_launcher_hermes_home.py`, `tests/test_drive_hermes_contract.py`,
  `tests/test_cron_registration.py` (full or partial read; run via
  `python3 -m unittest`)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior version), `audit/CODEX_SECOND_AUDIT_2026-09-05.md`,
  `audit/HANDOFF_2026-09-05_SESSION_CHANGES.md`, `audit/HERMES_CRON_GATEWAY_HOME_AUDIT.md`
  (read while searching for the named Codex report - see finding 1)
- `.gitignore`, `CLAUDE.md` (re-read per standing protocol)

## Finding 1 (process/provenance, not a code defect): the named report does not exist

The task named a specific file, `audit/CODEX_HERMES_HOME_ISOLATION_2026-09-05.md`,
and asked me to read it before anything else. That file does not exist -
not in the working tree, not untracked (`git ls-files --others
--exclude-standard` returned nothing), not anywhere in `git log --all
--oneline --diff-filter=A -- '*HERMES_HOME*' '*ISOLATION*'`, and no file in
the repo contains the string "Phase 0" (grepped case-insensitively across
the whole tree). I did not silently substitute something else and call it
equivalent; I searched explicitly (`Glob` for `*CODEX*` and `*HERMES_HOME*`,
git history search, full-repo grep) before proceeding.

What I did find, and treated as the actual deliverable to review, was an
**uncommitted** modification to `launch-north-forge.sh` already sitting in
the working tree at session start (see `git status` above), whose own
in-code comment says "reproduced empirically 2026-09-05; see audit" -
referring to an audit that was apparently never saved to disk. The change
itself matches the task's description exactly (a HERMES_HOME/write-probe
isolation fix), so I'm confident this is the right artifact, but I want this
gap on record rather than glossed over: **whatever process produced this
fix did not leave the written report CLAUDE.md's own audit-habit reasoning
depends on** ("Claude Code is excellent automation, but it isn't reviewed by
anyone unless this report actually gets read"). If Codex ran this fix
locally/interactively rather than through a flow that writes a report file,
that's worth knowing about on the primary-GPT side.

## Finding 2 (Phase 0 answer, derived from code since no report exists): HERMES_HOME isolates the WHOLE engine, not just config/state

This repo's `HERMES_HOME` is **not** a thin config-only pointer into an
otherwise shared Hermes engine. `scripts/ensure-hermes.sh`'s
`hermes_home_valid()` requires `$HERMES_HOME/hermes-agent/pyproject.toml`
plus a real executable under it - i.e., the entire Python package/venv/engine
tree lives inside `.hermes-home`, installed there by a real installer run
(`ensure_drive_hermes` curls `https://hermes-agent.nousresearch.com/install.sh`,
or uses `NORTH_FORGE_INSTALLER_SH` in tests, and runs it with
`HERMES_HOME="$stage"` so the installer itself populates that directory).
This is a **North Forge-specific mechanism**, not reliance on upstream
Hermes's own `HERMES_HOME` semantics - the repo's own prior handoff
(`audit/HANDOFF_2026-09-05_SESSION_CHANGES.md`, Phase 1) shows Kenneth's real
machine keeps the engine at a fixed `~/AppData/Local/hermes` regardless of
config, which is why North Forge needed its own installer/guard/wrapper
(`ensure-hermes.sh`, `hermes-drive.sh`) instead of just exporting the env
var and trusting a shared `hermes` binary to honor it for engine location
too. I could not find this stated as an explicit tradeoff anywhere in the
repo's own docs - it's implicit in the code. Recommend the primary GPT
confirm this is intentional design and consider documenting it explicitly
(e.g. in `.hermes.template.md`'s own addendum or a code comment at the top
of `ensure-hermes.sh`), since it's exactly the kind of design decision a
future session could get wrong by assuming `HERMES_HOME` alone is sufficient
isolation.

## Zone A changes made

### 1. `launch-north-forge.sh` - completed/corrected the uncommitted HERMES_HOME write-probe fix

**Before (HEAD, `5895597`):** the write-probe ran as
`mktemp "$HERMES_HOME/.north-forge-write-probe.XXXXXX"` - i.e., inside
`.hermes-home` itself, which required `mkdir -p "$HERMES_HOME"` first. This
meant a genuinely fresh drive got an empty `.hermes-home` directory created
as a side effect of the write-probe, before `ensure_drive_hermes` ever ran.
`ensure_drive_hermes`'s own logic treats any pre-existing `.hermes-home`
that isn't already a *complete, valid* install as "partial or damaged" and
refuses to touch it (by design - it must never silently overwrite a real,
if broken, install). Net effect: **every fresh drive's first launch failed**
with "ERROR: This drive has a partial or damaged .hermes-home" before the
installer ever ran.

**Empirically reproduced against HEAD** (stashed the uncommitted diff,
re-ran `tests/test-drive-local-hermes.sh`): confirmed exit 20 with exactly
that "partial or damaged .hermes-home" error on a drive that had nothing
but the checked-out repo - i.e., the bug is real and was correctly
diagnosed.

**Codex's uncommitted fix** moved the write-probe to operate on the repo
root directly (`mktemp "$(pwd -P)/.north-forge-write-probe.XXXXXX"`),
never touching `.hermes-home` before `ensure_drive_hermes` runs, and
collapsed three separate, duplicate `export HERMES_HOME=...` assignments
(visible in the pre-session `git diff`, all setting the identical value,
clearly artifacts of merged-together prior sessions) down to one. This part
of the fix is correct and I verified it live (see Empirical verification
below).

**What Codex's fix (as left, uncommitted) got wrong, and what I changed:**
it inserted the write-probe block *between* `cd "$(dirname "$0")"` and
`export HERMES_HOME=...`. `tests/test_launcher_hermes_home.py`
(`test_posix_home_precedes_every_hermes_operation`, committed in `00890ef`,
**predates this session** - confirmed via `git log -- tests/test_launcher_hermes_home.py`)
enforces, via `assertRegex`, that `export HERMES_HOME=` must be the
*literal next line* after the `cd`, with the Windows launcher held to the
same invariant. Running the test suite (not just reading it) surfaced this
as a real, currently-failing regression against a pre-existing, deliberate
safety invariant - not something I inferred from the diff alone.

Fix applied: reordered so `export HERMES_HOME="$(pwd -P)/.hermes-home"` is
again the literal line immediately after `cd`, with the write-probe (which
never reads or writes `$HERMES_HOME` - it operates on `pwd -P` directly) and
all of its explanatory comments moved after it. This is a pure reorder, not
a behavior change: verified via `bash -n` (syntax) and by re-running every
scratch test below, all of which still pass. `python3 -m unittest
tests.test_launcher_hermes_home.LauncherHermesHomeStaticTests.test_posix_home_precedes_every_hermes_operation`
now passes (it failed both before Codex's diff was touched further and
immediately after my first reorder attempt, when I mistakenly left an
explanatory comment *before* the export line rather than after it - the
regex requires zero lines between `cd` and `export`, not just semantic
adjacency; I caught this by re-running the test rather than assuming my
first edit was sufficient).

Final `git diff -- launch-north-forge.sh` against HEAD is in the working
tree; not reproduced in full here for length, but the net change is:
(a) one `export HERMES_HOME` instead of three duplicates, (b) the write-probe
now checks `pwd -P` instead of creating/touching `.hermes-home`, (c) three
`"$HERMES_EXE" ...` call sites replaced with the `hermes()` shell-function
wrapper already defined lower in the file (Codex's own change, verified no
dangling `$HERMES_EXE` references remain via grep), (d) export-then-probe
ordering restored to match the pre-existing test's invariant.

### 2. `tests/test-launcher-hermes-home.sh` - fixed two now-stale assertions

Not in CLAUDE.md's enumerated Zone A file list (see "Zone boundary gap"
below) - fixed under Kenneth's explicit in-session instruction ("fix it
directly, Zone A authority, standing") for bugs my own testing surfaces.

Ran this test against the working tree before touching anything: it failed
with "FAIL: drive-local Hermes home was not created," because its own
assertion (`[ -d "$expected" ]`, i.e. `.hermes-home` must already exist at
the point the launcher's first `python3` call is intercepted) encodes the
*old, buggy* behavior the fix above deliberately removes. Confirmed this by
re-running the same test against HEAD via `git stash` - it passed on the
old code and fails on the fix, which is exactly backwards for a regression
test meant to guard the fix.

Also investigated the file's second scenario (pre-existing `.hermes-home`
as a plain file) and found it was **already broken independent of this
session's diff** - it only copies `launch-north-forge.sh` in isolation
(not `scripts/`, `skills-source/`, etc.), so the real launcher now fails
immediately at `python3 scripts/name_validation.py drive` with "No such
file or directory" (confirmed by running the exact narrow-copy setup),
never reaching the `.hermes-home` check the scenario claims to test. This
predates Codex's session (the `assemble_skills`/`name_validation.py`
dependencies were added later without this test being updated) and I fixed
it too since I was already in this file for the directly-related fix.

Changes made:
- `[ -d "$expected" ]` (require `.hermes-home` exists) -> `[ ! -e "$expected" ]`
  (require it does NOT exist yet at this point) - now a live regression
  guard for the exact bug fixed above. Verified by `git stash`-ing just
  `launch-north-forge.sh` and confirming this specific assertion (correctly)
  fails against the old code with the message "REGRESSION: .hermes-home was
  created before ensure_drive_hermes ran (write-probe side effect
  reintroduced)."
- Write-probe leftover check moved from searching inside `.hermes-home` to
  searching the repo root (`-maxdepth 1`), matching where the probe file
  actually lives now.
- Second scenario's setup changed from copying only `launch-north-forge.sh`
  to a full tar-based repo copy (same exclude list I used in my own scratch
  harness: `.git`, `.hermes`, `.hermes-home`, `install-logs`, and every
  per-drive state file, so no real machine state leaks into the test) so the
  launcher actually reaches `ensure_drive_hermes`.
- Assertions updated to match `ensure_drive_hermes`'s actual current
  behavior: exit `20` (not the old code's `1`) and the message "partial or
  damaged .hermes-home" (not the old, now-nonexistent "could not create its
  drive-local Hermes home" text). Dropped the `forge-events.log` assertion
  for this path since `ensure_drive_hermes` never writes to that log for
  this error (confirmed empirically - only `echo` to stdout).

Verified: `bash tests/test-launcher-hermes-home.sh` now passes against the
fixed working tree.

## Empirical verification performed (all scratch-only; nothing touched
Kenneth's real machine state - his real `.env`, `.agent-name`,
`.drive-record.txt`, `.forge-mode` in this checkout were explicitly excluded
from every scratch copy so they could never leak into or contaminate a test;
confirmed this exclusion was necessary by first running without it and
observing real values like an existing agent name leak into a "fresh drive"
scratch copy - fixed the harness before drawing any conclusions from it)

Wrote two harnesses to `<scratchpad>/verify-isolation.sh` and
`<scratchpad>/verify-reset.sh` (session scratchpad, not the repo; not
committed). All use a fake `NORTH_FORGE_INSTALLER_SH` installer stub and a
fake `hermes` binary under `.hermes-home/bin/hermes` (matching the real
layout `ensure_drive_hermes`/`hermes_home_valid` expect) rather than any
real network install or the real host `hermes`.

1. **Fresh drive completes onboarding end-to-end under the new isolation:**
   PASS. Exit 0, `.hermes-home` correctly installed, `.provider-choice=free`,
   `.hermes.md` assembled, skills assembled, and the fake drive-local
   `hermes` (not the shared-host sentinel on PATH) received every call.
2. **Two scratch drives never leak config/cron state into each other or a
   shared install:** PASS. Both drives independently installed, each
   drive's `fake-config.txt`/`fake-cron.txt` (inside its own `.hermes-home`)
   contained exactly its own writes (1 config line each, both drives'
   `nightly-kyocera-research` cron entries present in their own store only),
   and the shared host's `.hermes/config.yaml` sentinel and the shared-host
   `hermes` call-log stayed untouched/empty throughout.
3. **Cron re-registration on a later relaunch still targets the
   drive-local install, not a shared fallback:** PASS. Re-ran the launcher
   on drive-a a second time (simulating a later session) with the shared
   sentinel armed and its call log cleared first; the relaunch's
   self-healing cron-list check invoked only drive-a's own local `hermes`
   (verified via the per-call `$HERMES_HOME|args` log line), and the shared
   sentinel log stayed empty.
4. **Write-probe fix confirmed live (not just via the stale test):** PASS.
   Intercepted the launcher's first `python3` call on a genuinely fresh
   drive and confirmed `.hermes-home` did not exist yet at that point -
   directly reproducing the fixed behavior, and (via the earlier `git
   stash` comparison) confirming this same check fails against HEAD.

## RESET wipe-list verification (task item 4)

There is no single "RESET" - three distinct tools exist, and I verified
each is correctly scoped rather than assuming the comments were accurate:

- **`toggle-mode.sh`'s RESET** (mode-switch admin gate): removes `.env`,
  `.forge-mode`, `.hermes.md`, `.drive-record.txt`, `.hermes/skills` only
  (confirmed via `grep -n "rm -f\|rm -rf" toggle-mode.sh`, line 75-77).
  `.hermes-home` is deliberately **not** in this list - the script's own
  on-screen text says so ("`.hermes-home` is PRESERVED"), and the code
  matches the claim. Correct by design: this is a content/provider reset,
  not an engine wipe.
- **`machine-reset.bat`**: targets only the shared host folder
  (`%LOCALAPPDATA%\hermes`), explicitly validated via
  `scripts/machine-reset-safety.ps1`, and its own comment states it "never
  uses HERMES_HOME" and deliberately ignores any inherited value. Confirmed
  via grep; does not touch a drive's `.hermes-home` at all. Correct by
  design: this is the shared-host reset, unrelated to any drive.
- **`full-drive-reset.sh`/`.bat`**: the only tool that purges `.hermes-home`,
  and does so with real safety mechanics - `scripts/drive-reset-safety.py`
  canonicalizes and validates the target is *exactly* `<repo>/.hermes-home`
  (rejects relative paths, `..`, filesystem roots, symlinks anywhere in the
  parent chain), requires the operator to type back the exact canonical
  path, and the shell wrapper stops safely (no deletion) if `hermes gateway
  stop`/`uninstall` fail first. **Verified empirically** in scratch (not
  just read): (a) a mismatched confirmation is refused and deletes nothing;
  (b) an exact confirmation purges exactly `.hermes-home` after invoking
  `gateway stop` then `gateway uninstall` on the fake drive-local `hermes`,
  leaves an unrelated sibling file and the rest of the repo untouched, and
  logs the purge to `forge-events.log`.

This is a coherent, correctly-scoped three-tool design and I found no
inconsistency in it. I could not compare this against "Codex's stated
reasoning" as the task asked, since no such report exists (Finding 1) - this
is my own independent verification of current behavior, not a check against
Codex's documented decision.

## Additional real findings surfaced by running (not just reading) the
existing test suite - NOT fixed this session, flagged instead

Running the full pre-existing test suite (beyond what the task specifically
asked about) surfaced three more real, currently-failing items, all
**pre-existing and unrelated to this session's `.sh` diff** (confirmed by
checking they don't touch any file this session's diff touches, and/or
predate it in git history):

1. **`launch-north-forge.bat` has the same duplicate-`HERMES_HOME`-assignment
   debt the `.sh` file had before Codex's fix, but for the Windows launcher
   it was never cleaned up.** `tests/test_launcher_hermes_home.py`'s
   `test_windows_home_precedes_every_hermes_operation` asserts
   `set "HERMES_HOME=%CD%\.hermes-home"` occurs exactly once; it currently
   occurs 3 times (confirmed via the test's own `AssertionError: 3 != 1`,
   and by reading the full `.bat` content the test loaded). All three
   occurrences appear to set the identical value, so this looks purely
   cosmetic/redundant rather than a functional bug (unlike the `.sh` bug,
   nothing here creates `.hermes-home` early as a side effect - `.bat`'s
   `ensure-hermes.ps1` path is architecturally different from the `.sh`'s
   write-probe). I did not fix this: it's a different file than the one
   Codex's session touched, needs its own careful diff review to confirm
   which occurrence is canonical, and ideally real Windows execution
   testing before changing a field-critical launcher - out of scope for
   "verify Codex's HERMES_HOME work." Recommend a dedicated follow-up
   session mirroring the `.sh` cleanup.
2. **Same test's `test_windows_launcher_has_equivalent_failure_handling`**
   (in `tests/test_cron_registration.py`) expects the literal string
   `set "HERMES_HOME=%~dp0.hermes-home"` in the `.bat` file; the file now
   uses `cd /d "%~dp0"` followed by `set "HERMES_HOME=%CD%\.hermes-home"`,
   which is functionally equivalent (already `cd /d`'d into the script's own
   directory) but textually different. Looks like test staleness from an
   earlier refactor of the `.bat` file's path-resolution style, not a
   functional defect. Not fixed - same reasoning as above.
3. **`tests/test-drive-local-hermes.sh` and `tests/two-drive-hermes-isolation.sh`
   are unreliable in this environment for reasons unrelated to this
   session's fix.** The former's fake `curl` stub writes its fake installer
   script to stdout and ignores the real `-o <file>` argument
   `ensure_drive_hermes` actually passes, so it never correctly hands off to
   the installer in either HEAD or the fixed working tree (confirmed both
   ways) - this looks like drift from an earlier version of
   `ensure-hermes.sh` that called `curl` differently. The latter attempts a
   real network install (no `NORTH_FORGE_INSTALLER_SH` fixture) and fails
   silently under `set -e` inside a subshell whose output is redirected to
   a file that gets deleted by its own cleanup trap before the exit code is
   visible - consistent with the no-network-access environment limitation
   Codex's own `audit/HERMES_CRON_GATEWAY_HOME_AUDIT.md` already documented
   for a similar container. I did not fix either: they test real-installer
   plumbing outside the scope of the write-probe/ordering bug this session
   is about, and fixing the `curl` stub without also being able to verify
   against a real install run risks papering over rather than fixing the
   drift. `tests/test-drive-hermes-install.sh` (which uses
   `NORTH_FORGE_INSTALLER_SH` instead of faking `curl`) passes cleanly and
   is the one I relied on for confidence in `ensure_drive_hermes` itself.
4. Two of the three Python test modules
   (`tests/test_cron_registration.py`'s subprocess-based tests) cannot run
   under this machine's native Windows Python (`WinError 193: %1 is not a
   valid Win32 application` - it tries to `subprocess.run()` a `.sh` file
   directly rather than through `bash`). Environment/tooling limitation, not
   a code defect - I do not have a POSIX-Python environment available here
   to actually execute those specific subprocess-based cases, so they
   remain unverified by me this session (the static/regex-based tests in
   the same files did run and are reported above).

## Zone boundary gap (flagged for primary GPT / Kenneth, not fixed by me)

CLAUDE.md's Zone A file list (`launch-north-forge.bat/.sh`,
`toggle-mode.bat/.sh`, `machine-reset.bat`, `provision-new-drive.ps1`,
`.env.example`, `skins/north-forge.yaml`, this audit file, `.gitignore`)
predates a substantial amount of infrastructure that now exists in this
repo and is governed by no explicit zone at all: `scripts/*.sh`,
`scripts/*.ps1`, `scripts/*.py`, `tests/*.sh`, `tests/*.py`,
`full-drive-reset.sh`/`.bat`. All of it is exactly the "mechanical glue
code - testable, low-risk, no field or technical judgment content" CLAUDE.md
uses to justify Zone A for the files it does name, and git history shows
prior sessions (both Claude Code and Codex, via merged PRs) already treating
it that way in practice. I fixed one test file this session
(`tests/test-launcher-hermes-home.sh`) under Kenneth's explicit
in-session instruction rather than my own reading of the zone list, per the
STANDING RULE precedent of not silently expanding scope - but this gap will
keep recurring every session until the file list is updated. Recommend the
primary GPT and Kenneth formally extend Zone A's enumerated list to cover
`scripts/` and `tests/` (or state explicitly that they're intentionally
unlisted and why).

## Commits made this session

- Pending (this report is written before the commit step, per protocol,
  but committed together with the code changes below in this session's
  Zone A commit(s)).

## Uncertain / flagged for primary GPT review

1. **Finding 1 above (missing report file)** - primary item for review.
   I proceeded on my own judgment that the uncommitted working-tree diff was
   the intended artifact (strong textual match to the task's description),
   but I could not verify this against any written Codex reasoning, and
   could not fulfill the literal instruction to read "Codex's stated
   recommendation/tradeoff" since no such text exists on disk. If a report
   was supposed to exist and got lost (not just never written), that's worth
   tracking down independently of this session.
2. **Finding 2 (Phase 0 answer, derived not read)** - I'm confident in the
   derivation (direct code inspection: `hermes_home_valid` requires the full
   `hermes-agent` tree, not just config), but flagging that this is my
   inference from code, not a restatement of anything Codex wrote, since no
   such writing exists to restate.
3. **Zone boundary gap** (see above) - a repeated, structural issue, not a
   one-off judgment call; recommend closing it explicitly.
4. The three additional test-suite findings (Windows batch duplicate
   assignment, Windows/POSIX test-text drift, and the two unreliable
   installer-fixture tests) are real and reproducible but I deliberately
   left them unfixed as out of this session's scope - flagging them here so
   they don't get lost, per CLAUDE.md's own reasoning for why a boring
   session still needs a full written report.

## Status
Needs primary GPT review - primarily Finding 1 (missing named report) and
the Zone boundary gap, both process/governance questions rather than code
correctness questions. The actual HERMES_HOME isolation code is now
verified correct and regression-tested (both the original write-probe bug
Codex fixed, and a second real regression its uncommitted fix introduced
against a pre-existing test invariant, which I found and fixed in-session).
Three additional real test-suite issues were found and explicitly left
unfixed as out of scope - listed above so they're not silently dropped.
