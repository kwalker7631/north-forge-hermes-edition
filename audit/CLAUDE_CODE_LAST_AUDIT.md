# Claude Code Session Audit

Timestamp: 2026-08-26

Requested task: Kenneth pointed Claude Code at the repo with no initial
instruction (session-start check done, committed as 7f9365b), then gave a
specific follow-up: re-read five files/areas from current disk content -
NOT from any carried-forward summary - and quote actual grep/file output
for each. This report records that verification and corrects two stale
findings the session-start response had repeated from older audits.

## Files inspected (this verification)
- `CLAUDE.md` - lines 22-55, full read of the Zone A block.
- `README.md` - lines 22-61 (the "What's in here" inventory block) + grep
  `-in "step 1"` and grep `-in "cloning the repo below"` over the whole file.
- `launch-north-forge.sh` - full read (105 lines) + grep `mkdir -p` and grep
  `python3`.
- `launch-north-forge.bat` - grep `"tokens=\*"`.
- `.hermes.template.md` - raw-byte non-ASCII scan (Python).
- `mode-blocks/sales-menu.md` - full read (8 lines) + raw-byte non-ASCII
  scan + grep `/draft`.

## Verification results (actual output)

1. CLAUDE.md Zone A list (lines 24-34) literally contains, in order:
   launch-north-forge.bat, launch-north-forge.sh, toggle-mode.bat,
   toggle-mode.sh, setup-thumbdrive.ps1, provision-new-drive.ps1,
   .env.example, skins/north-forge.yaml, audit/CLAUDE_CODE_LAST_AUDIT.md,
   .gitignore. -> provision-new-drive.ps1 (L30), .env.example (L31),
   skins/north-forge.yaml (L32), audit/CLAUDE_CODE_LAST_AUDIT.md (L33) are
   ALL present.

2. README.md inventory: L45 `provision-new-drive.ps1 <- CANONICAL way to set
   up a new drive on Windows ...`; L46 `setup-thumbdrive.ps1 <- SUPERSEDED
   ...`; L92 prose repeats "superseded ... don't use it for new drives".
   grep -in "step 1" -> No matches. grep -in "cloning the repo below" ->
   No matches.

3. launch-north-forge.sh: `mkdir -p "$HOME/Desktop"` at L12, directly above
   the Desktop-launcher creation block (L11 DESKTOP_LAUNCHER=..., L13-26 the
   `if [ ! -f ... ]` block). `command -v python3` guard at L45 (exit 1 with
   install hint), preceding the python-dependent assembly at L51
   (`python3 - "$MODE" << 'PYEOF'` reading .hermes.template.md + mode-blocks/,
   writing .hermes.md). Skills-folder assembly (rm -rf / mkdir -p / cp,
   L38-43) runs before the guard but is pure shell, no python dependency.

4. launch-north-forge.bat L12:
   `for /f "tokens=* delims= " %%A in ("%MODE%") do set "MODE=%%A"` - present.

5. Non-ASCII scan: `.hermes.template.md` 0 non-ASCII bytes (12439 bytes
   total, also under the 20000-char Hermes truncation limit);
   `mode-blocks/sales-menu.md` 0 non-ASCII bytes (498 bytes total). Both
   pure ASCII. sales-menu.md L6 reject list:
   `... (/kb, /hl, /esc, /audit, /log, /train, /assist, /draft), explain
   plainly that this drive doesn't have that capability ...` - `/draft` IS
   in the list.

## Follow-up verification (2 more checks, same session)

6. `grep -n "command menu above\|command menu below" .hermes.template.md`:
   - L44 (startup routing, "Do not show the startup menu first"):
     `route immediately to the correct mode (see command menu below for the
     full, authoritative list)`.
   - L90 (flush_clear_rule, "/flush and /clear are the same command"):
     `stay in whatever mode was active (see command menu above for the full,
     authoritative list of modes)`.
   PASS - both parentheticals now defer to the command menu block; neither
   enumerates individual commands. "below" (L44, above the menu marker) and
   "above" (L90, below the marker) are both correct relative positioning.

7. `grep -in "draft" NEXT_STEPS.md`:
   - L27: `Confirm a real /kb draft actually renders correctly ...` - refers
     to a /kb output draft, NOT the /draft mode. Unrelated.
   - L29: `AUDIT 2026-08-26 (pre-flight): /draft ("Draft Writer") is
     referenced in .hermes.template.md's assistant_router_rule and listed in
     mode-blocks/full-menu.md, but has no entry in "Not yet built" above, no
     skills-source/ folder or placeholder ... Decide whether it is
     intentionally template-only ... or a missing placeholder that should be
     tracked here.`
   FAIL - /draft is NOT a tracked build item. The "Not yet built" section
   (L10-17) lists hotline-ticket, assist-intake, escalation-packet, audit,
   fault-logging, training-guide, sales-assist content - not /draft. L29 is
   a note flagging the gap, not an entry closing it. The session-start
   list's "/draft not tracked in NEXT_STEPS.md" item stands, unresolved.

## Zone A changes made
None to infrastructure/scripts. This audit file (itself Zone A) rewritten to
record the verification above and retract two stale findings (see below).
Commit hash in `git log`.

## Zone B findings (not fixed - reported only)
Two findings that the session-start response had carried forward from older
audits are STALE and do not hold against current disk content:
- RETRACTED: "CLAUDE.md Zone A file list omits provision-new-drive.ps1 /
  .env.example / skins/north-forge.yaml." FALSE as of this read - all three
  are in the list at lines 30-32. Fixed at some point since the audit that
  first raised it; that audit's text was being repeated without re-reading.
- RETRACTED: "mode-blocks/sales-menu.md redirect/reject list omits /draft."
  FALSE as of this read - `/draft` is in the L6 reject list.
Confirmed still open by fresh read this session:
- `/draft` mode not tracked in `NEXT_STEPS.md` "Not yet built" (check 7
  above). L29 pre-flight note flagging the gap is still unresolved -
  someone needs to decide template-only vs. missing placeholder.
Still open, NOT re-read this session:
- `.hermes.template.md` mode lists vs. `mode-blocks/full-menu.md`
  consistency; default `/assist` mode backed only by an unbuilt placeholder
  skill. These need their own fresh read before being repeated again.
Verified RESOLVED by fresh read this session:
- `.hermes.template.md` startup_sequence + flush_clear_rule mode-list
  parentheticals no longer hardcode a partial command list - both now point
  to the command menu block as the authoritative list (check 6 above).

## Commits made this session
- 7f9365b - "Write session audit report (session-start check, no changes)"
  (session-start, Zone A).
- This report - "Audit: file-content verification, retract 2 stale Zone B
  findings" (Zone A). Hash in `git log`.

## Uncertain / flagged for primary GPT review
- Process lesson, not a content bug: the session-start response repeated
  two Zone B findings verbatim from prior audit text without re-reading the
  files. Both turned out to be already fixed. Prior-audit "open findings"
  should be treated as leads to re-verify, not facts to restate.
- Off-path items unchanged: `hermes` 117 commits behind upstream; SQLite
  3.45.1 WAL-reset bug.

## Status
Clean. Checks 1-6 pass against current disk content; check 7 fails as
expected and confirms an already-known open item (/draft untracked in
NEXT_STEPS.md). Two stale carried-forward findings retracted; one
carried-forward finding (mode-list parentheticals) verified resolved; one
(/draft tracking) verified still open. No Zone A code fix needed; no new
Zone B issue.
