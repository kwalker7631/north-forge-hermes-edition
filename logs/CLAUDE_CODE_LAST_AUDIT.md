# Claude Code Session Audit

Timestamp: 2026-09-13, local
Requested task: `CLAUDE_TASK_scrub_outbound_query_privacy.md` (handed over via
`D:\files_claud.zip`'s task archive) - investigate every skill/code path that can
trigger an outbound web search or fetch, confirm whether the actual query sent
externally is already reduced to technical content only, and fix any path found
leaking customer/company/ticket detail. This repo's part of that task was
investigation and one drafted-but-not-placed Zone B instruction; the actual code
fix landed in `north-forge-agent` (`RUN-2026-09-13-008`, `CHG-2026-09-13-006`,
full report at `D:\logs\OUTBOUND-SEARCH-QUERY-SCRUBBING_2026-09-13.md`) since the
real chokepoint (`tools/web_tools.py::web_search_tool`) lives there, not here.

## Files inspected

- `skills/web-navigator/SKILL.md` - read in full to check whether this skill ever
  calls out to an external source. It doesn't: it's a static curated link table
  matched against a fixed URL list ("All URLs below were verified directly
  against the live site... not guessed"). Not a leak path.
- `skills/kyocera-research/SKILL.md` - read in full. Nightly-cron, self-initiated
  research over public Kyocera topics (firmware notes, forums); never receives a
  customer's specific question, so there's no customer/company/ticket context in
  its own query to begin with. Not a leak path.
- `.hermes.template.md` - grepped for `chk`/`hl`/`hotline`/`live search` etc. to
  find the actual "/chk elevated research" trigger the task doc named. Found it
  at line 125 (`<field_claim_rule>`): "reaching for a live web search on anything
  uncertain" - this is the real place a technician's full context-heavy question
  can become a `web_search_tool` call. It currently says nothing about scrubbing
  before searching.
- `.hermes.template.md` line 35 and `CLAUDE.md` (this repo's own working rules) -
  confirmed the live skills actually sit at `skills/*/SKILL.md` (flat), while
  `CLAUDE.md`'s Zone B list names `skills-source/**`. Checked: `skills-source/`
  currently holds only `shared/pinokio` and `shared/readme` - not the tsc-only
  skills `.hermes.template.md` line 35 describes as living there
  (`hotline-ticket`, `kb-builder`, etc.). Likely drift from an earlier
  restructure that moved the live skill files to a flat `skills/` without
  updating the zone list to match.
- `skills/hotline-ticket/SKILL.md` - grepped for a fixed ticket-ID format (to
  judge whether a regex-only backstop was feasible for ticket numbers even
  without solving the customer/company-name half). No fixed format is defined -
  ticket numbers come from ServiceNow externally as free-form strings a
  technician pastes in, not a locally-generated pattern.

## Zone A changes made

None. (This session's only Zone A write is this audit report itself, per
standing authorization.)

## Zone B findings (not fixed - reported only)

1. **`.hermes.template.md` has no outbound-query scrubbing instruction.** The
   existing `<content_scrubbing_universal>` block (lines 130-132) already covers
   the sibling concern - what's fine to *publish/persist* - but says nothing
   about what's fine to *send externally* as a search query. The task doc that
   started this (`CLAUDE_TASK_scrub_outbound_query_privacy.md`) explicitly framed
   it as distinct from that existing rule. `north-forge-agent` now enforces this
   in code as of `CHG-2026-09-13-006` (`tools/web_tools.py::web_search_tool`
   blocks a search it can't confidently scrub), but a prompt-level instruction
   here would be a useful second, cheaper layer - it can't be bypassed by
   forgetting to invoke the tool in a way the code layer would catch, and it
   costs no extra LLM round-trip. Drafted for the Blacksmith to review and place
   (not placed myself - Zone B):

   ```
   <outbound_query_scrubbing>
   Distinct from content_scrubbing_universal above (that governs published/persisted output; this governs what leaves as a search or fetch query). Before any question triggers a live web search, a /chk deep-check, or any other outbound query to an external source, reduce it to its technical core first: the model/part/code/spec actually being asked about. Strip customer names, company/dealer names, HL/case ticket numbers, deal or install size, and any other detail that could identify who is asking or what business context this relates to. Example: "what's the weight and dimensions for a 200-machine install for [Bank]" becomes a query like "TASKalfa 5054ci weight dimensions" - the technical guts of the question, not the business context around it. The full original question, with all its context, is fine to keep working with inside the conversation itself - this rule is specifically about what gets sent externally. As of NF-v0.11.3, tools.web_tools.web_search_tool in north-forge-agent also enforces this in code and blocks a search it can't scrub with confidence - this instruction is a second, cheaper layer, not a substitute for it.
   </outbound_query_scrubbing>
   ```

   Suggested placement: immediately after `<content_scrubbing_universal>`
   (currently lines 130-132), same tag style.

2. **`CLAUDE.md` Zone B list names `skills-source/**`, but the live skills are
   at flat `skills/*/SKILL.md`.** Not urgent, but worth correcting so a future
   session doesn't misread the literal zone list and treat `skills/` as
   unzoned/editable. I treated `skills/*/SKILL.md` as Zone B by the same
   reasoning that already governs `skills-source/**` (authored field-support
   content, technical judgment) rather than assume the omission meant it was
   editable - flagging the drift rather than resolving it myself, since
   correcting a zone definition is exactly the kind of thing this file says
   should come from the Blacksmith.

## Commits made this session

None.

## Uncertain / flagged for primary GPT review

- The drafted `<outbound_query_scrubbing>` block (finding 1) is proposed
  wording, not authored-and-approved content - it should get the same scrutiny
  as any other Zone B change before being placed, not treated as pre-cleared
  because it's quoted in an audit report.
- Whether `skills-source/**`'s near-empty state (finding 2) reflects an
  intentional in-progress migration (skills being moved out of the flat
  `skills/` layout piece by piece) or a completed-but-undocumented one wasn't
  determined this session - worth a direct answer before editing the zone list
  either way.

## Status

Needs primary GPT / Blacksmith review - two Zone B findings above are open
(one has drafted text ready to place, one is a documentation-drift question).
No code in this repo changed.

---

Handoff bundle: not applicable to this repo - see `D:\HANDOFF_2026-09-13_2330.zip`
(built at the drive root per `north-forge-agent`'s ledger convention; this repo has
no separate handoff-bundle mechanism of its own). This file itself is Zone A and is
committed/pushed automatically per standing authorization, independent of that bundle.
