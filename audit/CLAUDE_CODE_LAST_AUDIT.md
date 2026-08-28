# Claude Code Session Audit

Timestamp: 2026-08-28 (session continued from the draft-writer placement task
earlier the same session)

Requested task: Two parts this session.
(1) Place `skills-source/tsc-only/draft-writer/SKILL.md` from a Claude
Project chat handoff zip - DONE earlier (commits `bd8969c`, `3f28184`,
`7e4d55d`); see "Commits made this session" below.
(2) Then, on request, run an audit pass on the two findings the 2026-08-26
audit explicitly deferred as "need their own fresh read before being
repeated again": (A) `.hermes.template.md` mode/skill lists vs.
`mode-blocks/full-menu.md` consistency, and (B) the default `/assist` mode
being backed only by an unbuilt placeholder skill. This report records that
fresh read. Read-only - no Zone B file was changed.

## Files inspected (this audit pass)
- `.hermes.template.md` - full read (124 lines) + targeted grep for
  DEFAULT MODE / skill-inventory / `.hermes/skills/` lines.
- `mode-blocks/full-menu.md` - full read (15 lines).
- `mode-blocks/sales-menu.md` - full read (8 lines).
- `mode-blocks/full-banner.md`, `mode-blocks/sales-banner.md` - full read.
- `launch-north-forge.sh` - full read (105 lines), focus on the
  skills-source -> `.hermes/skills/` assembly and the
  `{{MODE_BANNER_BLOCK}}` / `{{COMMAND_MENU_BLOCK}}` substitution.
- `skills-source/` - full tree walk. On disk: `tsc-only/kb-builder/SKILL.md`,
  `tsc-only/draft-writer/SKILL.md`, `shared/sales-assist/SKILL.md`. Nothing
  else - the other six "placeholder" skills have no folder or file at all.
- `NEXT_STEPS.md` - full read (32 lines).

## Zone A changes made
None to infrastructure/scripts. This audit file (itself Zone A) rewritten to
record the pass. Commit hash in `git log`.

## Zone B findings (not fixed - reported only)

### Finding A - `.hermes.template.md` <-> `full-menu.md` skill-list drift

The 2026-08-26 note asked whether `/draft` was "intentionally template-only"
or "a missing placeholder." Task (1) this session resolved that: `/draft` now
has a real skill file. But that placement was a Zone B *file* handoff only -
it did NOT (and could not, from Claude Code) update the surrounding Zone B
prose that describes the skill set. Four spots are now stale or asymmetric:

A1. `full-menu.md` L5:
    `/draft or /d - write a live chat response, ServiceNow note, customer
    update, escalation note, or email`
    - every other skill-backed menu line carries a `(see .hermes/skills/
    <name>)` pointer (L3, L4, L6, L8, L9, L10, L11, L12). L5 still has none,
    even though `skills-source/tsc-only/draft-writer/SKILL.md` now exists.
    Should read `... or email (see .hermes/skills/draft-writer)`.

A2. `.hermes.template.md` L26:
    `skills-source/tsc-only/ holds TSC-exclusive procedures (kb-builder, and
    placeholders for hotline-ticket, assist-intake, escalation-packet,
    audit, fault-logging, training-guide).`
    - `draft-writer` is missing from this inventory. It is a built skill,
    not a placeholder, so it belongs next to `kb-builder`:
    `(kb-builder, draft-writer, and placeholders for ...)`.

A3. `.hermes.template.md` L28:
    `(Skills beyond kb-builder are staged as placeholders in this initial
    build - see NEXT_STEPS.md. ...)`
    - now inaccurate: `draft-writer` is also built. Should read
    `Skills beyond kb-builder and draft-writer are staged as placeholders`.

A4. `.hermes.template.md` L66 (`<assistant_router_rule>`):
    `User asks for an email ... : run Draft Writer, matching audience, no
    HTML unless requested.`
    - KB Builder (L64), Auditor (L68), Training Guide (L70) and Fault Report
    (L72) each name their skill file to read ("Read .hermes/skills/
    kb-builder in full", "read .hermes/skills/audit", etc.). The Draft
    Writer line does not. For consistency it should say "run Draft Writer
    (read .hermes/skills/draft-writer), matching audience, ...".

All four are Zone B - left for the Blacksmith / Claude Project chat. They
are a single coherent edit: "finish wiring draft-writer into the template
and menu prose." A1 is already logged in `NEXT_STEPS.md`; A2-A4 are added to
that same NEXT_STEPS note by this session's Zone C edit.

### Finding A (pre-existing, not caused by this session)

A5. `<assistant_router_rule>` (L58-75) gives natural-language routing for
    Assistant, KB Builder, Draft Writer, Auditor, Training Guide, and Fault
    Report - but NOT for `/hl` (hotline-ticket) or `/esc`
    (escalation-packet), both of which appear in `full-menu.md` (L9, L10)
    with skill pointers. A technician who describes the need ("I need to
    update the hotline ticket", "put together an escalation packet") instead
    of typing the exact slash command has no routing entry to catch it. Low
    impact today (both skills are unbuilt; the explicit commands still
    work), but it is a real coverage gap in the router rule.

A6. `full-menu.md` L3 points `/assist` at `(see .hermes/skills/
    assist-intake)`, but the router rule treats "Assistant" as inline
    default behavior (L60-62) and never instructs reading `assist-intake`.
    Menu implies a skill file the router rule does not use. Overlaps
    Finding B.

A7. `.hermes.template.md` L26 / L28 call the six unbuilt skills
    "placeholders" / "staged as placeholders", but there is no placeholder
    file or even an empty folder for any of them in `skills-source/` - they
    are simply absent. "Staged as placeholders" overstates what exists;
    "not yet built" (the `NEXT_STEPS.md` wording) is accurate. Minor.

### Finding B - default `/assist` mode has no skill file (CONFIRMED still open)

Fresh read confirms the 2026-08-26 pre-flight note holds:

- `.hermes.template.md` L7: `DEFAULT MODE: /assist`
- `.hermes.template.md` L50: `Default state: North Forge is ready for /assist.`
- `.hermes.template.md` L46: vague symptom -> `route to /assist and ask for
  the minimum evidence needed (product/app, model/version, exact symptom,
  error/status code, recent change, what the user was trying to do)`
- `full-menu.md` L3: `/assist or /a - support-call assist mode (see
  .hermes/skills/assist-intake)`
- `skills-source/` on disk: no `assist-intake` folder or file.
- `NEXT_STEPS.md` L12: `skills-source/tsc-only/assist-intake/` listed under
  "Not yet built (do not invent content for these - flag and wait)".

Assessment:
- NOT a blocker. `/assist` degrades gracefully: the minimum-evidence list is
  inlined at L46, "Assistant" behavior is defined inline at L60-62, and
  L28 + L122 (`hermes_specific_addendum` #5) both instruct "if the skill
  file is missing/placeholder, say so plainly and fall back to the general
  principles in this file."
- IS a real rough edge for a fresh drive / the Greg demo: `/assist` is the
  landing mode for every FULL-mode drive, `full-menu.md` L3 advertises a
  skill pointer to a file that is not there, and an honest application of
  L122 means the first `/assist` interaction on a new drive can open with a
  "the assist-intake skill file is missing, falling back to general
  principles" disclosure.
- `assist-intake` is the ONE unbuilt skill on the default / always-hit path.
  The other five placeholders (hotline-ticket, escalation-packet, audit,
  fault-logging, training-guide) are only reached on explicit invocation.
  `DEMO_PREP_BACKLOG.md` item 2 currently prioritizes `fault-logging` as
  "build next"; this audit's observation is that `assist-intake` has at
  least an equal claim because it is on the default path. That is a
  Blacksmith prioritization call, not a Claude Code decision - flagged, not
  acted on.

### Finding B (new this pass) - "DEFAULT MODE: /assist" is not mode-qualified

`.hermes.template.md` L7 (`DEFAULT MODE: /assist`) and L50 (`Default state:
North Forge is ready for /assist.`) are static template text - they are
NOT inside `{{MODE_BANNER_BLOCK}}` or `{{COMMAND_MENU_BLOCK}}`, so the
launcher emits them verbatim into BOTH the FULL and the SALES `.hermes.md`.
On a SALES drive:
- `sales-menu.md` L6 lists `/assist` in the reject list ("this drive doesn't
  have that capability").
- `sales-banner.md` does not set any default mode.
- yet the assembled `.hermes.md` still says "DEFAULT MODE: /assist" and
  "ready for /assist" at the top.

So a SALES drive ships a template that names an unavailable mode as its
default. The `<assistant_router_rule>` L56 ("the mode banner ... takes
precedence over anything below that would otherwise route to a TSC-only
mode") papers over routing, but L7 / L50 are unqualified identity/status
lines above that rule. Cleanest fix (Blacksmith / Claude Project chat):
make L7 / L50 mode-aware, or have `sales-banner.md` explicitly state the
SALES default is `/sales`. Zone B - not changed here.

## Zone C changes made this session
- `NEXT_STEPS.md`: (earlier) added `draft-writer/SKILL.md` to "Done" and
  marked the 2026-08-26 `/draft` gap note RESOLVED; (this pass) expanded
  that same note with findings A2-A4 and a pointer to this audit report for
  Findings A5-A7 and B.

## Commits made this session
- `bd8969c` - "Place draft-writer skill (/draft) from Claude Project chat
  handoff" (Zone B placement exception).
- `3f28184` - "Mark /draft (Draft Writer) as built in NEXT_STEPS.md"
  (Zone C).
- `7e4d55d` - "Write session audit report (draft-writer skill placement +
  Zone C update)" (Zone A) - superseded by this rewrite.
- (this report) + the NEXT_STEPS.md expansion - hashes in `git log`.

## Uncertain / flagged for primary GPT review
- Findings A1-A4 are a direct consequence of the Zone B file-handoff
  mechanism: a skill file can be placed byte-for-byte, but the template and
  menu prose that describe the skill roster cannot be touched by Claude
  Code, so they drift until the Blacksmith / Claude Project chat catches up.
  Worth deciding whether a skill handoff should always come bundled with the
  matching template/menu edits, so the repo is never in this half-wired
  state between sessions.
- Finding B prioritization (`assist-intake` vs `fault-logging` as "build
  next") is a Blacksmith call - this audit only points out that
  `assist-intake` is the one on the default path.
- Finding B (new) - the unqualified "DEFAULT MODE: /assist" on SALES drives
  - should be checked against how a SALES session actually behaves at
  startup before deciding how much it matters; it may be fully absorbed by
  the banner-precedence rule in practice.
- Off-path items unchanged: `hermes` behind upstream; SQLite 3.45.1
  WAL-reset bug is still the only `hermes doctor` warning.

## Status
Needs primary GPT review. No Zone A code fix required. One Zone B file placed
this session under the confirmed handoff exception; no Zone B file edited.
Findings A1-A7 and B (two parts) are all Zone B or Blacksmith-decision items
- none are blockers, all are for the Claude Project chat / Blacksmith to act
on.
