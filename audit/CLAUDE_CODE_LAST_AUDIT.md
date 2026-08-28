# Claude Code Session Audit

Timestamp: 2026-08-28 (third task this session)

Requested task: Place `north-forge-hermes-full-skillset-v2.zip` (Claude
Project chat handoff): overwrite `.hermes.template.md` and
`mode-blocks/full-menu.md`, add six new tsc-only skill folders
(hotline-ticket, assist-intake, escalation-packet, audit, fault-logging,
training-guide). Verify each diff against the handoff description, confirm
the six folders exist on disk, confirm FULL and SALES assembled `.hermes.md`
stay under Hermes's 20,000-char limit, commit, push, then mark the six
skills done in `NEXT_STEPS.md` and close the wiring findings from the
2026-08-28 audit. Explicit instruction: do NOT use or test any of it - a
separate deliberate QA session does that.

## STATUS: BLOCKED - waiting on Blacksmith. NOT committed, NOT pushed.

The bundle verifies clean on every point in the handoff description EXCEPT
one: it also wires in a `web-navigator` skill that is not in the bundle and
does not exist in the repo. Committing as-is would re-introduce the exact
defect class the 2026-08-28 audit raised (menu + template advertising a
skill with no file on disk). Held for a corrected bundle or an explicit
"place as-is" from Kenneth. Working tree left as extracted (2 modified, 6
untracked) - not reverted, not staged.

## Files inspected
- `north-forge-hermes-full-skillset-v2.zip` - `unzip -l` / `-Z` before
  extracting; extracted to scratchpad for inspection. 14 entries: 6 skill
  dirs + 6 SKILL.md + `.hermes.template.md` + `mode-blocks/full-menu.md`.
  No `../`, no absolute paths, no symlinks, no dotfiles beyond the intended
  `.hermes.template.md`, no executables, nothing outside the declared scope.
  sha256 `8ad566cf0be8850a397520723d1cccb81c49c26130d187318e13a86f57872894`.
- All 6 new `SKILL.md` files - full read.
- New `.hermes.template.md` - full read + unified diff vs `HEAD`.
- New `mode-blocks/full-menu.md` - full read + unified diff vs `HEAD`.
- `mode-blocks/full-banner.md`, `sales-banner.md`, `sales-menu.md` - used
  for the assembled-size computation (unchanged by this bundle).
- `git status` - working tree already had the zip extracted into it before
  this session (same pattern as the draft-writer handoff): `.hermes.template.md`
  and `mode-blocks/full-menu.md` modified, the 6 skill dirs untracked. The
  modified files are byte-identical to the zip payload (sha256 match).

## Verification against the handoff description

PASS - the six skill folders all exist on disk:
  `skills-source/tsc-only/{hotline-ticket,assist-intake,escalation-packet,
  audit,fault-logging,training-guide}/SKILL.md` - present, non-empty
  (2668 / 8845 / 2084 / 3953 / 4664 / 1831 bytes), LF line endings, each
  opens with a `Trigger:` line and the standard "Never rewrite this skill
  file on your own initiative" self-lock line, same shape as kb-builder /
  draft-writer. Content is coherent authored field-support prose,
  cross-references `.hermes.md` rules (flush_clear_rule, field_claim_rule,
  human_voice_protocol, kb-builder handoff) correctly, matches the
  `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` contracts (FORGE FAULT
  REPORT block, intake sets, depth levels). No prompt-injection or
  instruction content aimed at Claude Code.

PASS - `.hermes.template.md` skill inventory now lists the built skills
  instead of "placeholders". L26 changed from
  "(kb-builder, and placeholders for hotline-ticket, assist-intake,
  escalation-packet, audit, fault-logging, training-guide)"
  to "kb-builder, draft-writer, hotline-ticket, assist-intake,
  escalation-packet, audit, fault-logging, training-guide - all built".
  NOTE: that is 8 tsc-only skills, not "7" as the handoff text said - the
  template's count (2 pre-existing + 6 new) is the correct one; the "7" in
  the request is an off-by-one in the description, not a bundle defect.
  L28 "Skills beyond kb-builder are staged as placeholders..." rewritten to
  "All tsc-only skills listed above are built and tracked in NEXT_STEPS.md.
  This note stays as a safety net for the future...". Resolves audit
  findings A2, A3, A7.

PASS - draft-writer wired in everywhere it was missing:
  - L66 router: "run Draft Writer (read .hermes/skills/draft-writer in
    full), matching audience..." (was: no skill path). Resolves A4.
  - `full-menu.md` L5: "... or email (see .hermes/skills/draft-writer)"
    (was: no pointer). Resolves A1.

PASS - new router entries for hotline-ticket and escalation-packet
  (`.hermes.template.md` L66-70 area): natural-language routing added for
  "update a hotline ticket / put together the HL update" ->
  `.hermes/skills/hotline-ticket`, and "escalation packet / escalate this /
  package this for engineering" -> `.hermes/skills/escalation-packet`.
  Resolves A5.

PASS - DEFAULT MODE / "ready for /assist" lines made mode-aware:
  - L7: "DEFAULT MODE: see mode banner below - /assist on FULL drives,
    /sales on SALES drives" (was: "DEFAULT MODE: /assist").
  - L50: "Default state: North Forge is ready to respond - see the mode
    banner above for which default mode and commands this specific drive
    supports (/assist on FULL, /sales on SALES)." (was: "ready for /assist").
  Resolves the "new this pass" half of Finding B.

PASS - `decisive_assistant_rule` next-step rule added, and it does NOT
  conflict with the "don't dump the full command menu" rule. The new text
  is one paragraph ("NORTH FORGE TAKES THE RUDDER - no dead-end responses
  ... one short, contextual line naming the single most relevant next
  move") and it explicitly self-distinguishes: "This is not the same as
  showing the full command menu (that stays reserved for cold-start/blank
  sessions per startup_sequence)". Also scoped to both FULL and SALES with
  a SALES caveat ("never suggest a command this drive doesn't have"). No
  contradiction with `full-menu.md` L14 or `startup_sequence`.

PASS - assembled `.hermes.md` size (computed by mirroring the launcher's
  Python substitution; NOT by running the launcher):
  - FULL  = 16,076 chars (LF) / 16,227 (if CRLF on a Windows drive) / 16,076 bytes UTF-8
  - SALES = 15,869 chars (LF) / 16,013 (if CRLF) / 15,869 bytes UTF-8
  Both well under 20,000 on every measure. FULL matches the handoff's
  "~16,076" exactly. SALES is ~15,869, not 16,076 - the handoff said
  "~16,076 each"; SALES is a couple hundred under because the sales
  banner+menu are smaller than full's. Not a problem - large margin.

## FAIL / BLOCKER - undescribed `web-navigator` wiring with no skill file

The bundle's `.hermes.template.md` and `mode-blocks/full-menu.md` both add
references to a `web-navigator` skill that the bundle does not deliver and
that does not exist anywhere in the repo (or in `Downloads/` as a separate
zip - checked):

- `.hermes.template.md` L26 (new):
  "skills-source/shared/ holds anything available in every mode: sales-assist
  (built, ...) and web-navigator (built, with verified real links)."
- `mode-blocks/full-menu.md` L13 (new):
  "/web or /links - website navigation shortcuts to kyoceradocumentsolutions.us
  (see .hermes/skills/web-navigator). Also triggers naturally on 'where do I
  find X on the site' without needing the slash command."

On disk `skills-source/shared/` contains only `sales-assist/`. There is no
`skills-source/shared/web-navigator/`. Consequences if committed as-is:
1. Directly contradicts the handoff description - item 2 enumerates the
   wiring fixes and none of them is web-navigator / `/web` / `/links`. The
   instruction was "verify each diff against this description"; this part of
   the diff is not in the description.
2. Re-introduces the 2026-08-28 audit's core finding for a new skill: the
   FULL command menu would advertise `/web ... (see .hermes/skills/
   web-navigator)` and the template would assert "web-navigator (built)"
   with nothing behind either.
3. SALES inconsistency: L26 says shared/ (which is what a SALES drive gets)
   holds web-navigator, but `sales-menu.md` (not in this bundle, unchanged)
   has no `/web` entry, and the file still would not be there.

The six tsc-only skills and every other described change are clean - the
blocker is isolated to the two web-navigator references.

## Zone A changes made
None to scripts. This audit file (Zone A) written to record the blocked
state - committed per standing Zone A authorization.

## Zone B changes made
None committed. The working tree currently holds the extracted bundle
(2 modified Zone B files + 6 untracked skill dirs) but nothing was staged
or committed. Not reverted either - left exactly as found so Kenneth's
extraction isn't destroyed.

## Zone C changes made
None. `NEXT_STEPS.md` will be updated to mark the six skills done and close
findings A1-A7 / B only once the bundle is actually committed - doing it now
would imply a Zone B change that has not landed (explicitly forbidden by
CLAUDE.md's Zone C rule).

## Commits made this session
- Earlier: `bd8969c`, `3f28184`, `7e4d55d` (draft-writer placement),
  `3a44994`, `cfa18a7` (2026-08-28 audit pass).
- This report - hash in `git log`.

## Uncertain / flagged for primary GPT review
- PRIMARY: does the Claude Project chat intend a `web-navigator` skill in
  this release? Two clean paths: (a) issue a v3 bundle that includes
  `skills-source/shared/web-navigator/SKILL.md` (and, for consistency, a
  `sales-menu.md` update if `/web` is meant to be available in SALES too);
  or (b) issue a v3 bundle with the two web-navigator references removed
  from `.hermes.template.md` L26 and `full-menu.md` L13, to be added later
  when the skill is authored. Either resolves the blocker. If Kenneth
  instead wants it placed as-is with web-navigator logged as a known QA-gap,
  that is his call as Blacksmith but should be an explicit instruction.
- The "7 tsc-only skills" vs actual 8 wording in the handoff - harmless, the
  template is correct - noted so the primary GPT isn't surprised by the
  count.
- SALES assembled size is ~15,869, not the "~16,076 each" in the handoff -
  harmless, well under limit.
- Everything was static-checked only. Per Kenneth's instruction nothing was
  launched, trusted, or run through Hermes. `hermes skills list` still shows
  only kb-builder + sales-assist (the live `.hermes/skills/` is a launch
  artifact and the launcher was not run).

## Status
Blocked - waiting on Blacksmith. Six skill files and all described wiring
changes verified good; assembled size verified under limit; one undescribed
web-navigator reference (template + full-menu) with no backing skill file is
the sole blocker. Nothing committed beyond this report.
