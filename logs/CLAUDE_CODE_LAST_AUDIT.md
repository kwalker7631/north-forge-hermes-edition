# Claude Code Session Audit

Timestamp: 2026-09-13 (place README/philosophy content, build-status check on
Excalibur, defer Pinokio wiring)
Requested task: per `Downloads/files (7).zip` ->
`CLAUDE_TASK_place_readme_build_excalibur.md` - "Reviewed and approved by
Kenneth and the primary GPT." Three parts: (1) place README.md replacement +
new PHILOSOPHY.md exactly as drafted, (2) confirm Excalibur's actual build
status against `Advanced/deploy-console/EXCALIBUR.md`, (3) place
PINOKIO-on-drive.md + pinokio-SKILL.md as documentation only, do not wire
Pinokio into the format-and-clone flow this pass.

## Files inspected

- `README.md`, `PHILOSOPHY.md` (existing vs. attached, byte diff both ways)
- `Advanced/PINOKIO.md`, new `PINOKIO-on-drive.md`, `skills/pinokio/SKILL.md`,
  `skills-source/shared/pinokio/SKILL.md`
- `logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md`,
  `logs/HANDOFF_NEXT_AGENT_2026-09-12.md`,
  `logs/CODEX_REPOSITORY_SCOPE_README_REVIEW_2026-09-12.md`
- `Advanced/deploy-console/EXCALIBUR.md`, `Zero-Touch-Deploy.ps1`,
  `Start-DeployConsole.ps1`, `ui/index.html`
- Full test suite (`python -m pytest -q`), `north-forge-agent` cron-sync
  tests, both repos' `git log`/`status`

## Zone A changes made

None. The one candidate fix found (see "Uncertain" below,
`tests/test_pinokio_lab_target.py::test_blocks_missing_ancestor`) sits
inside `scripts/pinokio_lab_target.py`, which
`logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md` explicitly flags as part of
the still-unresolved same-drive-vs-separate-disk design conflict. Fixing it
without that decision risks encoding the wrong side of the conflict, so it
was left untouched and reported instead, same as the conflict itself.

## Zone B placements made (pre-approved handoff, placed byte-for-byte)

1. **`README.md`** - replaced entirely with the attached
   `README-kyocera-passion.md`. Real diff from prior version (not just
   formatting): adds a `CAPABILITIES via public chassis` row linking
   `https://github.com/kwalker7631/north-forge-agent/blob/main/CAPABILITIES.md`,
   and reworks one capability-table line (`/web` wording). Verified every
   local link resolves on disk (`CURRENT.md`, `distribution.yaml`,
   `PHILOSOPHY.md`, `Advanced/deploy-console/DEPLOY.md`,
   `Advanced/deploy-console/ADMIN_FIRST_TIME.txt`,
   `assets/north-forge-banner-etched.png`) and that the new external link
   target, `CAPABILITIES.md`, exists on `north-forge-agent`'s `origin/main`
   at commit `6a51f8b0ac` (not just local disk).
2. **`PHILOSOPHY.md`** - already existed on disk (git commit `d76e9ad`).
   Diffed the existing file against the attached one: content is identical;
   the only difference was straight vs. curly apostrophes/quotes and
   CRLF vs. LF line endings. Placed the attached version anyway per "place
   as attached," since this is a typographic normalization, not a reversion
   of any prior deliberate fix.
3. **`PINOKIO-on-drive.md`** (new file, repo root) - placed byte-for-byte.
   Flagging explicitly, not silently: **this is a substantive rewrite/
   expansion of the same subject already covered by `Advanced/PINOKIO.md`**
   (same-drive layout, but adds a `GREGW-NORTH`-labeled example, an inline
   `Start Pinokio Lab.cmd` script, a numbered admin deploy sequence, and a
   credit section). The task named this file `PINOKIO-on-drive.md`, not
   "replace `Advanced/PINOKIO.md`," so I placed it as its own new file
   rather than overwriting `Advanced/PINOKIO.md` - composing that merge
   myself would have been deciding Zone B content, not placing it. The two
   files now overlap and will drift if not reconciled by whoever owns the
   voice. This does **not** touch the actual open conflict described next.
4. **`skills/pinokio/SKILL.md`** and **`skills-source/shared/pinokio/SKILL.md`**
   - both diffed near-identical to the attached `pinokio-SKILL.md` already
     (both last touched together in commit `5040bee`); placed the attached
     text into both so they stay in sync, no reverted content in either
     direction.

## Zone B findings (not fixed - reported only)

- **The dead `#gateway-service-requirements` anchor** (carried over from
  last session, still true): `README.md`'s replacement does not touch this
  link, and the removed section still doesn't exist on
  `north-forge-agent/README.md`. Unchanged, still needs an owner.
- **The Pinokio same-drive-vs-separate-disk conflict is still open and
  this session's placement does not resolve it.** Per
  `logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md`: `scripts/pinokio_lab_target.py`
  (+ `Install-Pinokio-Lab.ps1` / `Remove-Pinokio-Lab.ps1`) hard-block any
  drive carrying a North Forge marker file, with no override - which is
  now exactly the shape of the "same 256 GB learning stick" design that
  `Advanced/PINOKIO.md`, the new `PINOKIO-on-drive.md`, and both
  `SKILL.md` files all now describe as the intended layout. Placing more
  same-drive documentation this session makes that contradiction slightly
  more prominent, not less - three of four Pinokio docs now assume
  same-drive works via `pinokio_lab_target.py`'s validator, which as
  written today would refuse it. This still needs the design decision
  the prior handoff asked for (retire the validator's scope to a third,
  genuinely-separate tier; teach it to distinguish stick classes; or keep
  both paths as documented alternatives) before anyone runs those scripts
  against a real 256 GB learning stick.

## Part 2 - Excalibur build status (investigation only, no physical build)

Read `Advanced/deploy-console/EXCALIBUR.md` end to end and diffed its
documented sequence against the actual deploy-console code on disk
(`Zero-Touch-Deploy.ps1`, `Start-DeployConsole.ps1`, `ui/index.html`):

- **Matches doc:** Tier selector in the UI maps `basic` -> "locked to
  kyocera only" (`ui/index.html` tier `<select>`), which is the `Tier:
  Locked. Pin: Kyocera.` step. Format-confirmation (`Type FORMAT`) and
  admin-passcode-min-6 gates both exist and are enforced server-side in
  `Start-DeployConsole.ps1`'s `/api/deploy` handler, not just in the UI.
  `Zero-Touch-Deploy.ps1` formats exFAT, consistent with "32 GB or larger"
  advice (EXCALIBUR.md never mandates a filesystem explicitly, but exFAT
  is what ships).
- **Gap found, not yet built:** EXCALIBUR.md step 4, "Assigned to: the
  manager's first and last name -> label `GREGW-NORTH` style," has **no
  corresponding field anywhere in the console.** `ui/index.html`'s form has
  exactly five inputs (drive, tier, skip-format checkbox, FORMAT
  confirmation text, passcode) - no name/label field. `Start-DeployConsole.ps1`'s
  `/api/deploy` handler builds `$argList` for `Zero-Touch-Deploy.ps1` from
  `letter`, `tier`, `skipFormat`, `confirm` only - it never passes `-Label`.
  `Zero-Touch-Deploy.ps1`'s own `$Label` parameter therefore always falls
  back to its hardcoded default, `'NorthForge'`, regardless of who the
  drive is being built for. I'm reporting this rather than adding a field
  myself: whether the intended fix is a new UI input wired through to
  `-Label`, or the admin renaming the volume by hand after format (which
  would make this a documentation clarification, not a code gap), is a
  product-shape decision, not a typo fix - and the prior handoff's own
  instruction was explicitly "diff before assuming... don't invent a third
  launcher path."
- **Not verifiable from this session:** the physical build/smoke-test
  steps (plugging a real USB into an admin PC, confirming
  `HOW_TO_START.txt` lands, testing on a second PC) - no physical media
  access here. That remains Kenneth's own step per the doc.

## Low-priority items - status only, not actioned this pass

- **SCOPE-05 (9 stale tests):** confirmed still present and still failing
  for the documented reason - they live under
  `archive/legacy-standalone-launcher/tests/` and reference the retired
  `launch-north-forge.bat/.sh` / `scripts/hermes-drive.sh`. Unchanged since
  `logs/CODEX_REPOSITORY_SCOPE_README_REVIEW_2026-09-12.md` flagged them.
  Parked, per instruction.
- **New, previously unflagged:** running the full suite this session
  (`python -m pytest -q`) surfaced one additional failure outside SCOPE-05:
  `tests/test_pinokio_lab_target.py::test_blocks_missing_ancestor` fails
  with `AssertionError: assert 'blocked_missing_path' in {'blocked_too_small',
  'ok', 'warn_marginal'}` against the real filesystem. Not touched - see
  the Pinokio conflict note above; this script is explicitly under the
  same open design question. Current full-suite count: **7 failed, 28
  passed** (the 7 = the 6 archived SCOPE-05 cases the discovery run
  reaches plus this one). This is a materially different number than the
  "21/21 passing" cited in `logs/HANDOFF_PERPLEXITY_PINOKIO_2026-09-12.md`
  from earlier the same day - that count did not include this Pinokio
  validator test file, which did not exist yet at that point in the
  session history.
- **Cron / research-agent auto-scheduling:** confirmed still documentation-
  only, not wired into the deploy console's format-and-clone flow. No
  change since last handoff.
- **Public README link-test:** `tests/docs/test_readme_links.py` still
  does not exist on disk. Not yet built, not actioned this pass (explicitly
  low-priority / park-unless-quick per the task).

## Commits made this session

- `<pending - Zone B placements + this report, about to commit/push>`

## Uncertain / flagged for primary GPT review

- Whether `PINOKIO-on-drive.md` should eventually replace/merge into
  `Advanced/PINOKIO.md` rather than sit alongside it - flagged above, not
  decided here.
- The Pinokio same-drive-vs-separate-disk validator conflict itself -
  unchanged, still open, now touching one more failing test.
- The Excalibur owner-label gap (no `-Label` wiring in the console) -
  needs a decision on whether it's a code gap or a manual post-format step.

## Status

Needs primary GPT review - two of the three open items above
(PINOKIO-on-drive.md/Advanced/PINOKIO.md overlap, the owner-label gap) are
new this session; the Pinokio validator conflict and the dead anchor link
carry forward unchanged. Part 1 and Part 3 placements are done and verified
link-clean. Part 2 is a status report, not a completed build - Excalibur is
not yet demo-ready until the owner-label question is resolved one way or
the other.
