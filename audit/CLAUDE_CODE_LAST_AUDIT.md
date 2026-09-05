# Claude Code Session Audit

Timestamp: 2026-09-05 (session following the sandbox-harness session; triggered
by "Do a new Pull codex audit added")
Requested task: pull the newly-added `audit/CODEX_SECOND_AUDIT_2026-09-05.md`
(an independent adversarial audit performed by Codex, merged into `main` via
PR #1 before this session started) and act on it - independently re-verify
each finding, then fix confirmed real Zone A bugs directly per standing
authorization.

## Files inspected

- `audit/CODEX_SECOND_AUDIT_2026-09-05.md` (full read - the audit itself, 7
  numbered findings: 1 HIGH, 4 MEDIUM, 2 LOW, plus several unnumbered
  "additional independent observations")
- `toggle-mode.sh`, `toggle-mode.bat`, `machine-reset.bat`,
  `launch-north-forge.sh`, `launch-north-forge.bat`, `.gitignore`,
  `provision-new-drive.ps1` (full reads, current content, before editing -
  every finding was checked against the actual current file text, not
  assumed from the audit's line numbers, since those could have drifted)
- Installed `hermes-agent` behavior for `hermes config unset` (empirically
  re-verified exit-code/output-text behavior for both the "key absent" and
  "key present" cases, since NF-CX-03's fix design depends on being able to
  tell these apart)

## Zone A changes made

All 7 numbered findings confirmed real against current file content, then
fixed. Commit `9a48117` - "Fix 7 findings from independent Codex audit (1
HIGH, 4 MEDIUM, 2 LOW)".

1. **`machine-reset.bat` - NF-CX-01 (HIGH).** Before: `HERMES_DIR` (from the
   user/environment-controlled `HERMES_HOME`) was accepted for `rmdir /s /q`
   if it had EITHER a `hermes-agent\` folder OR a `config.yaml` file (the
   latter a very common filename in many unrelated apps), with no check
   that the path was even absolute. After: requires the path to match
   `<letter>:\...` (absolute drive path - rejects relative paths, UNC
   shares, and bare drive roots) AND both markers together, not either one.
   Implemented via substring extraction (`%HERMES_DIR:~0,1%` etc.), not
   `findstr /r` - an equivalent regex (`^[A-Za-z]:\\`) was tested standalone
   first and failed with "FINDSTR: Bad command line" on every input,
   including legitimate ones, which would have silently sent every real
   path to the rejection branch and broken the feature for everyone. Caught
   before it shipped by testing empirically rather than trusting the regex
   to "obviously" work.
   Verification: real console automation (SendKeys, same technique proven
   in the prior sandbox-harness session) against 3 live scenarios in
   scratch directories only - a directory with both real markers was
   correctly accepted and deleted; a directory with only `config.yaml` was
   correctly refused (still present after); a relative path was correctly
   refused. All three matched expected behavior.

2. **`toggle-mode.sh` / `toggle-mode.bat` - NF-CX-02 (MEDIUM).** RESET's
   delete list gained `.provider-choice`, `.agent-name`, `.readme-shown`
   (previously only wiped `.env`/`.forge-mode`/`.hermes.md`/
   `.drive-record.txt`/`.hermes/skills`). The on-screen "RESET wipes..."
   message in both scripts was updated to list all 8 items instead of 5.
   Verification: full RESET flow driven end-to-end on both scripts (direct
   stdin redirection for `.sh`; SendKeys console automation for `.bat`,
   same known limitation as before - `toggle-mode.bat` cannot be driven via
   redirected/piped stdin at all due to a `call`+goto-loop interaction with
   non-console stdin, confirmed in the prior session) against scratch
   copies seeded with all 8 marker files - all 8 confirmed gone afterward
   on both scripts.

3. **`launch-north-forge.sh` / `.bat` - NF-CX-03 (MEDIUM).** Before:
   `.provider-choice=free` was written unconditionally, then `hermes config
   set model.provider opencode-free` and `hermes config unset
   model.default` were run with all errors discarded - a total failure of
   both commands (Codex's own empirical test: a fake `hermes` returning
   exit 23 for everything) was recorded as permanent success and never
   retried, since the marker file's mere existence skips this block on
   every future launch. After: `.provider-choice=free` is written only
   after `hermes config set` genuinely succeeds (checked via the command's
   real exit code); on failure it shows an on-screen warning and falls back
   to the OWNKEY flow instead. `unset model.default` needed separate
   handling because it returns nonzero (verified empirically:
   `Config key not set: model.default`, exit 1) whenever the key was never
   set in the first place - the normal, expected case, not a failure - so a
   failure there is only surfaced as a warning when its own output text
   doesn't say "not set" (bash: checked via captured output + real exit
   code in the same `if` condition, so `set -e` doesn't trip on the
   intentionally-checked failure; batch: `for /f` erases the inner
   command's own errorlevel, so success vs. failure is told apart by
   checking the captured text for "not set" (benign-absent) vs "Unset"
   (genuine success) - anything matching neither is treated as a real,
   warn-worthy failure).
   Verification: NOT via a live fake-`hermes`-on-`PATH` test (see incident
   below - that technique proved unreliable and unsafe in this
   environment). Instead: isolated logic unit tests - a bash version using
   a same-name shell function to stand in for `hermes` (functions always
   take priority over `PATH` lookup within a process, zero ambiguity), and
   a batch version using a local label instead of an external command for
   the parts that could safely be isolated that way, plus a separate,
   fully safe verification that the real `hermes config unset`'s actual
   exit-code/text behavior matches what the fix's logic assumes. All 4
   combinations tested (both succeed / set fails / unset benign-absent /
   unset genuinely-fails) produced the correct `.provider-choice` value and
   correct warning behavior in both languages. Also confirmed via a full,
   real end-to-end integration run (real `hermes` binary, but with
   `HERMES_HOME` explicitly isolated to a scratch directory for the entire
   run) that the success path still works exactly as before with no
   regression.

4. **`launch-north-forge.sh` / `.bat` - NF-CX-04 (MEDIUM).** Before: `cp -r
   skills-source/shared/. .hermes/skills/ 2>/dev/null || true` (and the
   equivalent unchecked `xcopy` in the `.bat`) silenced every copy failure;
   the launcher would then run `hermes skills trust .` and present North
   Forge as running normally even with an empty or partial skill set.
   After: a copy failure now aborts the launch with a clear FATAL message
   (bash: `if ! cp ...; then ... exit 1; fi`, exempting it from `set -e`
   the same way as finding 3; batch: `if errorlevel 1 (... exit /b 1 )`
   after each `xcopy`).
   Verification: a scratch project with `skills-source/` intentionally
   omitted now correctly aborts with the FATAL message and exit 1 (was:
   silent exit 0 with zero files copied, per Codex's own empirical test); a
   normal scratch project with real `skills-source/shared` and
   `skills-source/tsc-only` in FULL mode still copies both correctly (8
   real files copied without error in the full integration run).

5. **`launch-north-forge.sh` / `.bat` - NF-CX-05 (MEDIUM).** Drive-record
   name and assistant name (`DRIVENAME`/`NEWNAME`/`CUSTOMNAME`) are written
   unescaped straight into `forge-events.log`'s own `[LEVEL] [component]:`
   bracketed format and into the generated `.hermes.md` context. Codex
   demonstrated entering the literal name `Mallory ] [FAILURE]
   [admin-gate]: forged PASS` and getting that exact fabricated log line
   reproduced verbatim in `forge-events.log`. Fix: strip control bytes
   (bash: `tr -d '[:cntrl:]'`) and `[`/`]` (both languages - the specific
   characters that let typed text forge bracketed-field structure) and cap
   length at 60 characters, applied to all three input points in both
   scripts.
   Verification: fed the exact Codex-demonstrated payload through the bash
   `sanitize_name` function and the equivalent batch substitution chain in
   isolation - both correctly strip the brackets (result:
   `Mallory  FAILURE admin-gate: forged PASS` - no longer capable of
   forging a bracketed log field), control bytes are stripped, and a
   100-character input is correctly capped at 60.
   NOT fully resolved, flagged for Kenneth rather than decided
   unilaterally: Codex separately noted the assistant-name customization is
   unrestricted free text substituted into the generated system-prompt
   context (`.hermes.md`), which is a broader "how much should a local
   drive holder be able to influence the assistant's instructions"
   governance question this session's fix does not settle - it only
   prevents the concrete, demonstrated log-forging and unbounded-length
   issues.

6. **`launch-north-forge.sh` / `.bat` - NF-CX-06 (LOW).** Cron scheduling
   failures (`hermes cron add` returning nonzero) were previously only
   recorded in `forge-events.log`, with nothing shown on-screen - a field
   tech would see a normal-looking launch with a silently-absent automated
   research/brief job. Both launchers now also print a plain on-screen
   warning naming which job failed. Low-risk, purely additive change
   (one `echo` line inside an already-existing, already-tested branch);
   not re-tested live beyond visual review, consistent with its LOW
   severity and trivial nature.

7. **`.gitignore` - NF-CX-07 (LOW).** `.provider-choice` (introduced by the
   Phase 2 onboarding rework in the immediately prior session) was the only
   per-drive state marker not in the per-drive-state ignore block -
   confirmed via `git check-ignore .provider-choice` before the fix (not
   ignored) and after (ignored, `.gitignore:21:.provider-choice`).

Additional fixes from the same audit's unnumbered observations, applied
alongside the numbered findings since they're small, low-risk, and directly
adjacent to files already being edited:
- **WELCOME.html first-run marker.** Both launchers previously wrote
  `.readme-shown` unconditionally regardless of whether the auto-open
  actually succeeded. Now only written on success, so a failed open (no
  opener available, file missing, opener crashed) retries on the next
  launch instead of never showing the welcome page again. Verified live in
  this session's integration run: under Git Bash (no `xdg-open`/`open`
  available), `WELOPEN="no opener available"` correctly resulted in
  `.readme-shown` NOT being created.
- **`provision-new-drive.ps1`.** `git pull`/`git clone` exit codes were
  never checked - `$ErrorActionPreference = "Stop"` does not turn a native
  executable's nonzero exit into a terminating PowerShell error on common
  Windows PowerShell versions, so a failed pull could silently launch
  stale content. Now checks `$LASTEXITCODE` after both and exits with a
  clear error if either fails. Verified via `PSParser` tokenize (syntax
  only, matching the prior session's own approach for this file) - NOT
  executed live, since this script is destructive/out-of-scope against
  real drives (same judgment Codex itself made).
- Did NOT touch the dead/unreachable `if [ $? -ne 0 ]` check after the
  Python heredoc in `launch-north-forge.sh` that Codex also flagged - real
  and harmless (confirmed: `set -e` already exits before that line could
  ever be reached), but not a bug, and removing working-but-redundant code
  without a concrete reason wasn't judged worth the edit.

## Zone B findings (not fixed - reported only)

None new this session. The audit's own scope note ("Zone B... no authored
advice was re-audited") is consistent with what I independently observed -
none of the 7 numbered findings touch `skills-source/**`,
`.hermes.template.md`, or `mode-blocks/*` content itself, only the Zone A
scripts that read/copy them.

## Commits made this session

- `9a48117` - "Fix 7 findings from independent Codex audit (1 HIGH, 4
  MEDIUM, 2 LOW)" (Zone A: `.gitignore`, `CHANGELOG.md`,
  `launch-north-forge.bat`, `launch-north-forge.sh`, `machine-reset.bat`,
  `provision-new-drive.ps1`, `toggle-mode.bat`, `toggle-mode.sh`)
- `c8e449c` - "Audit: Codex-audit-response session - 7 findings fixed,
  verified, one session incident disclosed" (this report, first draft)
- `b3eccf5` - "Merge remote-tracking branch 'origin/main'" - see the
  concurrent-work reconciliation section below; this was not a trivial
  fast-forward, it required hand-resolving 3 conflicted files

## Concurrent-work reconciliation (discovered mid-session, resolved by hand)

`git push` was rejected after commit `c8e449c` - the remote had 12 new
commits I didn't have locally (`ef4cb12..0eef03b`). Codex had been
independently fixing several of the SAME findings via its own PRs,
concurrently with and unaware of this session's work, merged to `main` by
Kenneth while this session was in progress: "Validate welcome assets and
retry failed opens" (WELCOME.html), "Stop provisioning when Git update
fails" (`provision-new-drive.ps1`), "Ignore provider choice state and test
repository hygiene" (`.gitignore` + a new `tests/repository-hygiene.sh`),
"Harden launcher name validation" (a new shared `scripts/name_validation.py`
+ both launchers, with its own `tests/test_name_validation.py`).

Did NOT force-push over this. Fetched, examined each incoming diff before
deciding how to reconcile (not a blind merge), then `git merge
origin/main` and hand-resolved the 3 resulting conflicts
(`launch-north-forge.bat`, `launch-north-forge.sh`,
`provision-new-drive.ps1` - `.gitignore` auto-merged with one duplicate
line, cleaned up by hand):

- **Name validation (the launcher-input part of NF-CX-05):** Codex's
  `scripts/name_validation.py` is a materially better fix than this
  session's own bracket-stripping approach - a real allowlist (letters,
  numbers, spaces, `'-.,()` only) with re-prompt-on-invalid-input and its
  own test suite, versus this session's blacklist-and-strip approach.
  Kept Codex's version entirely; discarded this session's `sanitize_name`
  function and inline `DRIVENAME`/`NEWNAME`/`CUSTOMNAME` sanitization code.
- **`provision-new-drive.ps1`:** Codex's version additionally validates
  that the repository folder and `launch-north-forge.bat` actually exist
  after a clone/pull reports success, on top of the same git-exit-code
  check this session made independently - strictly more thorough for the
  same underlying gap. Kept Codex's version entirely.
- **WELCOME.html marker and `.gitignore` entry:** functionally identical
  fixes for the same findings on both sides - trivial dedup.
- **Unaffected by any of this** (Codex's work never touched these):
  `machine-reset.bat` (NF-CX-01), `toggle-mode.sh`/`.bat` (NF-CX-02), the
  provider-choice config-verification fix and skill-copy-failure fix in
  both launchers (NF-CX-03, NF-CX-04), and the cron on-screen-warning fix
  (NF-CX-06) - all still stand exactly as committed in `9a48117`.

Re-verified end-to-end after merging, not just reviewed: a full launcher
run (both `.sh` directly, and `.bat` via a patched scratch copy matching
the technique from the prior sandbox-harness session) through drive-record
creation, agent-name default, provider-choice configuration, skill
copying, skin activation, skills trust, and cron scheduling - all correct,
no regressions from combining both sessions' changes. Pushed to `main`
(`ef4cb12..b3eccf5` from Codex's side, plus this session's own 3 commits)
immediately after, per standing Zone A authorization.

## Uncertain / flagged for primary GPT review

1. **Incident, corrected immediately: this session accidentally mutated
   Kenneth's real machine's Hermes model config twice during verification
   of finding NF-CX-03.** While trying to verify the fix's behavior under a
   simulated `hermes` failure, I attempted to shadow the real `hermes`
   command with a fake script by prepending a scratch directory to `PATH`
   within a Bash tool session. Twice, the real `hermes` binary was invoked
   instead of the fake - both times because bash's command-hash cache
   (populated by earlier, unrelated `hermes` invocations already in that
   session) is not invalidated by a later `PATH` prepend, so bash kept
   resolving `hermes` to its already-cached real path regardless of `PATH`
   order. Both times this actually ran `hermes config set
   model.provider/model.default` against the real
   `C:\Users\kwalk\AppData\Local\hermes\config.yaml`, overwriting the
   Phase-1 setting from the prior session (`provider: anthropic, default:
   claude-sonnet-4-6`) with `provider: opencode-free` (and, the first time,
   also clearing `model.default`). Caught immediately both times by
   checking `hermes config get` output right after, and reverted
   immediately both times back to `anthropic`/`claude-sonnet-4-6` before
   any other work continued. Final state confirmed correct at the end of
   this session (re-checked one more time as a closing sanity check). No
   other real-machine state was touched at any point - `HERMES_HOME` was
   set to an isolated scratch path in the SAME calls that caused this, but
   since the real binary (not the intended fake) was the one actually
   invoked, it read/wrote its own real config path regardless of
   `HERMES_HOME`, which is exactly why the mutation happened despite the
   isolation attempt.
   Lesson applied for the rest of the session: stopped trying to shadow
   `hermes` via `PATH` entirely. All further verification used either (a)
   real console automation where the actual `hermes` binary legitimately
   needs to run, with `HERMES_HOME` explicitly isolated for that specific
   process (verified safe in this session's HIGH-finding test and the
   final integration run - both confirmed via before/after state checks
   that nothing outside the scratch directory changed), or (b) fully
   in-process function/label mocks with no external process named `hermes`
   involved at all (used for the NF-CX-03 logic verification specifically,
   since that's the finding where the earlier mistake happened).
   Flagging this prominently rather than just noting it in passing, since
   it's exactly the kind of thing this audit habit exists to surface - a
   real, if quickly-corrected, mistake in this session's own process, not
   in the repo.
2. Everything else flagged as open in the prior sandbox-harness session's
   report (whether a plain console `ANTHROPIC_API_KEY` hits the same
   Fable/Mythos credits wall, the two stale cron `model_snapshot` pins)
   remains open and was not addressed this session - out of scope for a
   Codex-audit-response session. One item from that list IS now resolved,
   observed as a side effect of this session's merge, not actioned by
   Claude Code: `WELCOME.html` now exists as tracked Zone B content (via
   Codex's PR, content matching Kenneth's own prior untracked local copy
   byte-for-byte apart from line endings) and its text already covers the
   Phase 2 ENTER/OWNKEY provider-choice flow - confirmed by reading it,
   not edited.
3. The NF-CX-05 governance question (assistant-name as unrestricted
   system-prompt injection) - see finding 5 above - genuinely needs
   Kenneth's or the primary GPT's explicit call, not mine.

## Status
Clean - 3 commits plus a hand-resolved merge, all 7 numbered findings plus
2 additional observations fixed and verified (a mix of live
console-automation tests, direct stdin tests, and isolated logic unit
tests, chosen per-finding based on what could be tested safely), reconciled
with Codex's own concurrent independent fixes for 4 of the same findings
(deferred to Codex's version for 2 of those where it was materially more
thorough, kept this session's own fixes for the other 5 findings Codex's
work never touched), re-verified end-to-end after the merge with no
regressions. One real session-process mistake made and corrected
immediately (item 1 above - needs no further action, but worth independent
awareness). No Zone B content touched or edited (WELCOME.html was read to
confirm its content, not written). Needs primary GPT review specifically
on item 1 (session process, not repo content) and item 3 (a real
governance decision) above.
