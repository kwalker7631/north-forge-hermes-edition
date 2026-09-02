---
name: audit
description: Audit an existing prompt, KB, or draft for drift and failures
---
# Audit Skill

Trigger: /audit or /chk, or a request to review, check, test, compare, debug, clean up, find drift in, or verify consistency of an existing prompt, KB, article, response, or draft. Use this skill unless a code-maintenance or agent-configuration file is specifically requested (that's a different kind of review, outside this skill's scope).

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith in chat and wait for confirmation.

## Output format

Findings, severity, exact failure, recommended fix, and pass/fail status. For KB audits specifically, include template compliance and hallucination risk as their own explicit checks, not folded into general commentary.

## Required finding format

```
## Finding: [short title]
Severity: Critical | High | Medium | Low | Note
Category: Router | Context Handoff | Template | Output Contract | Source Discipline | Hallucination Risk | Tone | Other
Evidence: [short quote, exact observed behavior, or what's missing]
Why it matters: [practical impact]
Recommended fix: [what should change]
```

## Failure taxonomy (use these category names)

- **Router Failure** - wrong mode was triggered, or the right mode wasn't triggered when it should have been.
- **Context Handoff Failure** - specific named failure patterns:
  - A general question got an immediate KB without being asked.
  - "Make that a KB" was ignored - prior answer/context wasn't carried forward.
  - KB Builder produced Markdown, outline-only prose, or a new layout instead of the locked HTML reference.
  - Draft Writer lost uncertainty labels and turned field reasoning into confirmed fact.
  - The user was asked to repeat information already present in the current chat.
  - After /flush or /clear, the response restated, blended, or drew specific facts from a prior working issue package into the new one (see the flush_clear_rule hard-reset requirement).
- **Template Failure** - a KB doesn't follow the locked HTML reference, or the Support & Resources Contact Block is missing or altered. Check specifically: required section order followed, Support & Resources present, Contact Block Lock passed (portal URL, downloads URL, TSC phone, TSC email, authorized-login note all present and unaltered), Drafting/Review Block kept outside the publish body, media prompts kept outside the publish body, no leftover placeholder tokens.
- **Output Contract Failure** - the wrong format for the mode: an HTML KB where plain text was expected, a long essay from /a where 2-6 lines was expected, KB scaffolding leaking into a /draft response, etc.
- **Source Discipline Failure** - an unverified claim, forum note, or technician theory presented as confirmed fact without classification (see field_claim_rule categories: Confirmed Fact / Strong Clue / Working Theory / Unverified Field Note / Not Supported).
- **Hallucination Risk** - an invented file name, path, procedure, error code, or model capability that wasn't source-backed or clearly labeled as an assumption.

## Auditor's general scope (per operational_modes)

Beyond the failure taxonomy above, Auditor also checks: hallucination risk, missing evidence, unsupported claims, tone drift, template drift, visual compliance (colors, no emojis/decorative symbols, proper Mermaid/image/video prompt structure per the visual media standard), multimedia coverage (was the mandatory Mermaid map included, was media selection justified), metadata quality (is the META string complete and search-oriented, not a status log), and publish readiness (is this actually ready for a technician to use, or does it need more work).

## Pass/fail discipline

A correct "not ready" is a better audit outcome than a false "looks fine." If in doubt about whether something is a real problem, flag it as a Note-severity finding rather than silently letting it pass - the Blacksmith can downgrade a flagged non-issue far more easily than recover from a missed real one.
