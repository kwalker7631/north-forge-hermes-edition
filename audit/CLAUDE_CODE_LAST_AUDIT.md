# Claude Code Session Audit

Timestamp: 2026-09-05 (final-batch session following the recon-only session
recorded at commit `1c48f95`)
Requested task: Kenneth sent a single "final batch" message covering three
phases: (1) switch his own dev machine's default model off the credits-
gated `claude-fable-5`; (2) rework `launch-north-forge.bat`/`.sh` so a
brand-new field user defaults to zero-config OpenCode Free instead of a
hard Anthropic-API-key gate, with the key flow moved to an explicit opt-in;
(3) close out five specific items pending across multiple prior handoffs
(paste `FIRST_TIME_README.txt` verbatim, re-verify a registry value, run
two specific greps and report output with line numbers, add two files to
CLAUDE.md's zone lists, optionally bump two files' Script version). Full
detail, all verbatim outputs, and the exact diffs are in
`audit/HANDOFF_2026-09-05_SESSION_CHANGES.md` (written this session,
addressed to the primary GPT) - this report summarizes with pointers
rather than duplicating the large verbatim blocks (the full text of
`FIRST_TIME_README.txt`, all grep output) that already live there in full.

## Files inspected

- `CLAUDE.md` (re-read per Session Start Protocol; later edited under live
  approval, see below)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior report, full read)
- `launch-north-forge.bat`, `launch-north-forge.sh` (full reads before and
  after editing)
- `.env.example`, `CHANGELOG.md`, `toggle-mode.bat`, `machine-reset.bat`
  (full reads before editing)
- `FIRST_TIME_README.txt` (Zone B, read-only - re-read fresh for verbatim
  quoting in the handoff doc, per item 1)
- `.hermes.template.md` (Zone B, read-only - grepped for "manual" in the
  `<how_this_package_is_organized>` paragraph, per item 3)
- `NEXT_STEPS.md` (grepped for `research-log|DECISION`, per item 3)
- Hermes machine state (not repo content): `~/AppData/Local/hermes/
  config.yaml` (before/after Phase 1), and the installed `hermes-agent`
  Python source (`hermes_cli/auth.py`, `hermes_cli/models.py`,
  `hermes_cli/cli_agent_setup_mixin.py`, `hermes_cli/
  models_catalog_static.py`) - read to confirm the exact, non-guessed
  mechanism for the OpenCode Free provider before writing it into Zone A
  scripts
- Windows registry: `HKCU\Console\VirtualTerminalLevel` (read-only query,
  per item 2)
- git: `git pull`, `git status` (checked before every stage/commit), `git
  diff`, `git log`, `git show --stat e342f7a`

## Zone A changes made

1. **`launch-north-forge.bat` (1.0.0 -> 1.1.0) and `launch-north-
   forge.sh` (1.0.0 -> 1.1.0)** - replaced the hard Anthropic-API-key gate
   with a one-time provider-choice prompt (remembered in
   `.provider-choice`) defaulting to OpenCode Free (`hermes config set
   model.provider opencode-free` + `hermes config unset model.default`,
   zero-config, zero-key) with the old key flow moved behind an explicit
   `OWNKEY` opt-in, now carrying an added warning against defaulting to a
   credits-gated model (Fable, Mythos). Full before/after and the exact
   verification performed (isolated scratch `HERMES_HOME` tests, direct
   Python-level confirmation that `get_default_model_for_provider
   ("opencode-free")` resolves to a real live model `deepseek-v4-flash-
   free`, and two extracted-logic dry-runs of the actual new batch-file
   gate) are in the handoff doc - not re-summarized here beyond noting
   that every check was run against a scratch/isolated target, never
   against this machine's real Hermes config, and all scratch artifacts
   were deleted afterward. `bash -n` clean on the `.sh` file post-edit.
   Commit `5291b86`.
2. **`.env.example` (1.0.0 -> 1.1.0)** - reframed `ANTHROPIC_API_KEY` as
   optional/opt-in tied to the launcher's `OWNKEY` choice, OpenCode Free
   noted as the zero-cost default, added the same Fable/Mythos credits
   warning. Read back top-to-bottom post-edit to confirm it reads cleanly.
   Commit `5291b86`.
3. **`CHANGELOG.md`** - two new bullets under a new `## [Unreleased] -
   2026-09-05` section describing the Phase 2 onboarding rework and the
   Phase 3 version bumps. Commit `5291b86`.
4. **`toggle-mode.bat` and `machine-reset.bat` (1.0.0 -> 1.0.1)** - Script
   version bumped per Kenneth's explicit (marked optional) ask, reflecting
   that the `e342f7a` admin_gate password-bypass fix predates the 1.0.0
   baseline set in the prior authorship/versioning session. `Updated:`
   dates bumped to 2026-09-05. Commit `d37fe9e`.

Judgment call, flagged for awareness: Phase 2's mechanism (`provider:
opencode-free` with `model.default` left unset, relying on Hermes's own
`get_default_model_for_provider` runtime fallback) was arrived at by
reading the actual installed `hermes-agent` source rather than guessing a
specific free model ID to hardcode - deliberately, since the source
comments explicitly note the free-tier model list "may lag the relay" and
that hardcoding a specific ID risked shipping one that later 401s. This
means the exact free model a field drive lands on depends on Hermes's own
live/offline-floor resolution at the time of that launch, not a fixed ID
in this repo - correct per the code, but worth the primary GPT knowing
this is a deliberately-not-pinned choice, not an oversight.

## Zone B findings / actions (approval-gated placement, not unilateral editing)

**Placed** (commit `3f48e46`) - added `USER_MANUAL.md` to CLAUDE.md's Zone
B (continued) list and `CHANGELOG.md` to its Zone C list, in three places
in the file (the Zone B-continued paragraph, the Zone C Files list, and
the Required-first-response template block), per Kenneth's Phase 3 item
4. Since the request described the change rather than handing over
pre-authored exact text, I drafted the literal diff and got explicit live
approval via `AskUserQuestion` (full before/after text shown in the
question's preview) before touching the file - consistent with, and
reinforcing rather than newly relying on, the pattern flagged as uncertain
in the 2026-09-04 authorship session's audit. This is the second time this
"draft it, show it verbatim, get live approval" pattern has been used for
CLAUDE.md itself; still worth the primary GPT's explicit sign-off that
this satisfies the Blacksmith hand-off exception's spirit even without a
pre-existing authored file, since the letter of that exception assumes
one.

**Quoted, not edited** - `FIRST_TIME_README.txt` full text pasted verbatim
into the handoff doc per Kenneth's item 1 (for his own WELCOME.html
rewrite). `.hermes.template.md`'s organization paragraph quoted (one grep
match, line 35) per item 3. No Zone B file's content was altered.

## Commits made this session

- `5291b86` - Phase 2: default onboarding to zero-config OpenCode Free,
  own-key opt-in
- `d37fe9e` - Phase 3: bump toggle-mode.bat/machine-reset.bat to 1.0.1 for
  e342f7a fix
- `3f48e46` - Phase 3: add CHANGELOG.md to Zone C, USER_MANUAL.md to Zone
  B in CLAUDE.md

All three pushed cleanly (`1c48f95..3f48e46`). `git status` was run and
reviewed before each of the three `git add`/commit steps; `.env` was never
present in any staged set (confirmed each time).

## Uncertain / flagged for primary GPT review

1. Whether a plain console `ANTHROPIC_API_KEY` (the credential the OWNKEY
   opt-in path still asks for) is subject to the same `credits_required`
   wall the prior session found on `claude-fable-5`, or whether that's
   specific to whatever OAuth-style auth this dev machine happens to have
   - **still open**, not addressed this session (Phase 2 mitigates the
   *default* path but doesn't resolve this question for anyone who does
   choose OWNKEY and later picks a premium model despite the new warning).
2. Two cron jobs' `model_snapshot` pins are now stale after Phase 1's
   model-default change on this dev machine (see handoff doc) - Kenneth's
   call whether to re-pin, left untouched this session since it wasn't
   asked for.
3. `WELCOME.html` still needs authoring/updating to reflect the Phase 2
   provider-choice flow - `FIRST_TIME_README.txt` (delivered verbatim in
   the handoff doc) does not itself describe that flow, so it can't be
   copied in as-is.
4. The "draft it, show it verbatim, get live `AskUserQuestion` approval"
   pattern for editing CLAUDE.md itself has now been used twice (2026-09-04
   and this session) without an explicit primary-GPT ruling on whether it
   fully satisfies the Blacksmith hand-off exception's letter (which
   assumes a pre-existing authored file, not text drafted by Claude Code
   and approved on the spot). Recommend this get a definitive yes/no this
   round rather than carrying forward as an open question a third time.

## Status
Clean - three commits, all verified empirically before commit (not just
asserted), all pushed, nothing left uncommitted or unreported. One
Zone B placement made under live Blacksmith approval (item 4 above,
same open-pattern-confirmation request as before). Full technical detail
and verbatim outputs: `audit/HANDOFF_2026-09-05_SESSION_CHANGES.md`.
