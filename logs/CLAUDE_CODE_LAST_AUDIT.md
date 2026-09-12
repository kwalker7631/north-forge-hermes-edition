# Claude Code Session Audit

Timestamp: 2026-09-11 (session continuing from a north-forge-agent D:-drive
verify-and-reclone task; Kenneth then gave a major correction/new task in the
same session)
Requested task: Retire this repo's standalone install model entirely. Strip
its own launcher/installer, restructure real content (`skills-source/`,
`mode-blocks/`, the KYO_KB_TITAN template) to match `north-forge-agent`'s
`editions/` pattern (`SOUL.md` + `distribution.yaml` + `skills/`), then have
it git-cloned directly into a new gitignored `private-editions/` slot in
`north-forge-agent`, switched into via Hermes's own `hermes profile
install`/`use` (no new command). Plan was written and approved in
`north-forge-agent`'s session context; this report covers this repo's half.

## Files inspected
`launch-north-forge.bat`/`.sh`, `scripts/ensure-hermes.ps1`/`.sh`,
`scripts/hermes-drive.ps1`/`.sh`, `scripts/machine-reset-safety.ps1`,
`Advanced/*`, `tests/*` (the launcher-coupled ones), `mode-blocks/*.md`,
`scripts/assemble-skills.ps1`, `skills-source/shared/*`,
`skills-source/tsc-only/*`, `skills/kb-builder/SKILL.md`,
`.hermes.template.md`, `CLAUDE.md` (this repo's own Zone A/B/C governance),
`AGENTS.md`, `CHANGELOG.md`, `NEXT_STEPS.md`, `README.md`, `USER_MANUAL.md`,
`FIRST_TIME_README.txt`, `WELCOME.html`.

## Zone A changes made
None yet committed as of writing this report (committed together with the
Zone B *placements* below in one commit - see "Commits made this session").
`AGENTS.md` was inspected (its one launcher reference, line 19, is historical
narrative explaining why the file exists, not a live instruction - left as-is,
no fix needed there).

## Zone B findings (not fixed - reported only)

**Note on the Zone B moves below:** Kenneth gave this repo's specific
restructuring instruction directly, in-session, naming the exact files/
folders and the exact target shape (`SOUL.md` + `distribution.yaml` +
`skills/`, matching `north-forge-agent`'s other editions) - per this file's
own "CONFIRMED (2026-08-26)" clause, an in-session named handoff identifying
specific Zone B content with an instruction to act on it is a sufficient
trigger. What follows below are **moves of existing content, byte-identical,
via `git mv`** - not composition of new prose - which is why they were done
rather than only reported. Nothing in Zone B's actual *text* was authored,
rephrased, or extended by Claude Code this session:

1. `skills-source/shared/*` (8 skills) and `skills-source/tsc-only/*` (8
   skills) moved byte-identical into a single flat `skills/` (16 folders).
2. `mode-blocks/*.md` (4 files) and `scripts/assemble-skills.ps1` moved
   byte-identical into `archive/legacy-mode-system/` (the FULL/SALES mode
   system is retired; reachability is now `north-forge-agent`'s tier/
   passcode gate, not a baked-in mode).
3. `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` moved byte-identical into
   `skills/kb-builder/assets/`. Its owning skill (`skills/kb-builder/
   SKILL.md`, Zone B, untouched) already phrases its reference as "repo
   root or wherever the Blacksmith has placed it" - tolerates the new
   location without a text change.
4. `launch-north-forge.bat`/`.sh`, `scripts/ensure-hermes.ps1`/`.sh`,
   `scripts/hermes-drive.ps1`/`.sh`, `scripts/machine-reset-safety.ps1`,
   `Advanced/provision-new-drive.ps1`, `Advanced/full-drive-reset.sh`,
   `Advanced/toggle-mode.sh`, and 11 dedicated test files moved
   byte-identical into `archive/legacy-standalone-launcher/`, with a new
   `README.md` there explaining what was retired and why. These are listed
   as Zone A in this file's own governance, so moving them carries no Zone B
   concern either way - noted here for completeness since they're part of
   the same physical restructuring pass.

**Genuinely NOT done (real Zone B authoring, left for the Blacksmith):**
- `SOUL.md` at the repo root - needs composing from `.hermes.template.md`
  (extract the always-loaded identity/persona/rules; drop the
  `{{MODE_BANNER_BLOCK}}`, `{{COMMAND_MENU_BLOCK}}`, and `{{AGENT_NAME}}`
  per-drive templating markers, since the launcher that filled those in is
  retired). `.hermes.template.md` itself is left untouched at the repo root
  as the source for that pass - not moved, not edited.
- `skills/menu/SKILL.md` - still describes routing between "whichever mode
  this drive is running - FULL or SALES," which no longer applies
  structurally. Needs a Blacksmith rewrite once there's one flat skill set.
- `README.md` (architecture diagram at L67-90, "Skills and runtime content"
  at L105-140, "What's in here" file tree at L181-236, "Setting up a new
  drive" at L272-313, and several smaller mentions), `USER_MANUAL.md`
  (L21-22 launch instructions, L166 mode-toggle instructions, L181 reset
  instructions, L233-268 skills-source authoring instructions),
  `FIRST_TIME_README.txt` (L18-21 launch instructions), and `WELCOME.html`
  (L36-40 launch instructions) all still describe the retired launcher/mode
  system throughout and need Blacksmith-authored replacement text - same
  pattern as the existing 2026-09-05 CHANGELOG entry ("Not done here (Zone
  B - needs Blacksmith...)") for a smaller version of this exact gap.
  Claude Code did not compose any replacement text for these, per this
  file's Zone B rule.
- `CLAUDE.md` itself (this file) still lists Zone A/Zone B/Zone C file
  paths that no longer match this restructuring (e.g. `mode-blocks/*` and
  `skills-source/**` in the Zone B list no longer exist at those paths;
  `launch-north-forge.*` etc. moved into `archive/`). Per this file's own
  rule, Claude Code does not edit `CLAUDE.md` itself without an explicit
  Blacksmith/Claude-Project-chat handoff - flagged here rather than fixed.

## Commits made this session
(To be made immediately after this report is written - see below.)
One commit covering: the quarantine moves (launcher, installer, mode
system), the `skills-source/` -> `skills/` flatten, the KB template move,
the new root `distribution.yaml`, the new `archive/legacy-standalone-
launcher/README.md`, and the `CHANGELOG.md`/`NEXT_STEPS.md`/this audit
report entries. Not pushed (no push authority exercised this session;
Kenneth reviews before it goes anywhere further, consistent with the
sibling `north-forge-agent` repo's own review-before-push practice).
Tagged `v0.1.0` after commit, per the profile-distribution versioning
convention (`hermes-agent.nousresearch.com/docs` - profile-distributions
guide: bump `version:` in `distribution.yaml`, commit, tag).

## Uncertain / flagged for primary GPT review
- Whether `tests/test-free-provider.sh` (moved into
  `archive/legacy-standalone-launcher/tests/`) was correctly identified as
  launcher-coupled: confirmed by reading it - it directly invokes
  `bash ./launch-north-forge.sh --configure-free-provider`, so yes.
- Whether moving Zone B content (skills-source/, mode-blocks/) without
  Kenneth handing over literal replacement file content, rather than only
  reporting it, was the right call under this file's own rules - reasoned
  through above (in-session named handoff + byte-identical `git mv`, no
  new prose authored). Worth a second look if that reasoning doesn't hold
  up under closer reading of the CONFIRMED clause.
- No verification yet that `hermes profile install <this-repo>` actually
  succeeds against the restructured tree (that check happens from the
  `north-forge-agent` side, once `private-editions/` exists there - see
  that repo's own session report).

## Status
Needs primary GPT / Blacksmith review - real Zone B authoring (SOUL.md,
menu skill, four user-facing docs) is still outstanding and blocking a
genuinely complete restructuring, even though the mechanical half is done.
