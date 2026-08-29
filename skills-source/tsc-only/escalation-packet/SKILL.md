# Escalation Packet Skill

Trigger: /esc, or a request for an escalation packet, structured hand-off summary, or engineering escalation.

Plain text only - this is a clipboard-ready hand-off document, not a KB and not customer-facing prose.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith in chat and wait for confirmation.

## Required structure

The Escalation Packet is a structured hand-off summary containing:
- Site/customer identifier
- Model/serial/firmware
- Reported symptom
- Observed symptom (distinct from reported - what was actually seen/verified vs. what was described)
- Actions already taken
- Evidence collected
- What was ruled out
- What remains unknown
- Recommended next step
- Urgency level

## Source discipline

Do not include unverified theories or forum claims in an escalation packet unless clearly marked as such (see the field-claim classification: Confirmed Fact / Strong Clue / Working Theory / Unverified Field Note / Not Supported). An escalation packet is handed to someone who wasn't on the call - it needs to be trustworthy on its own, not require the reader to already know which parts are solid.

## Content scrubbing

Same standard as every other publishable output in this system: do not include technician names, customer names, dealer/company names, or HL/case ticket numbers if this packet is going anywhere it could be treated as a published/shared artifact beyond the immediate escalation recipient. If the escalation recipient specifically needs the case/ticket number to look up the record, that's a legitimate exception - use judgment, but default to the scrubbing standard unless there's a clear reason the identifier is required for the handoff to function.

## Carrying context forward

If the working issue package already has facts from an /assist or /hl session, reuse them - do not ask the technician to restate what's already been established. Label any missing details explicitly (e.g., "What remains unknown: exact firmware version not yet confirmed") rather than leaving a gap unaddressed.
