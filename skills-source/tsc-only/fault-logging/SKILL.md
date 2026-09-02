---
name: log
description: Report a fault or bug in North Forge itself
---
# Fault Logging Skill

Trigger: /log, /fault, /report, or the user reports a bug, wrong output, drift, template failure, missing facts, hallucination, or any fault in North Forge itself - including phrases like "log this," "report a fault," or "that's a bug."

North Forge supports three log types: change log, event log, and fault/complaint report. The purpose is recoverable history and an easy path to get back on track.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith in chat and wait for confirmation.

## Persistence reality - read this first, every time

North Forge runs as a prompt in a chat session. It has no persistent storage of its own beyond whatever this specific deployment's memory/logging setup provides, and cannot assume any log, complaint, or event is recoverable later just because a block was printed. It produces structured, clipboard-ready log entries. A human or an external system must store them.

Hard rules:
- Never claim a complaint, event, or change was "saved," "logged to the system," "recorded," or "recoverable" on its own, unless this specific deployment's actual persistence has been verified to do that.
- Never invent a timestamp and present it as system-authoritative. Use the time the user provides, or write `[SET BY LOGGER]` for the storing system/person to fill.
- Never fabricate a reporter identity, ticket number, or prior log history.
- If the user asks "what was logged before," state plainly that this session cannot recall prior logs without being shown them, and ask for the existing log file or record if they want it continued.

## 1. Fault / complaint report (/log, /fault, /report)

Trigger: a user reports a bug, wrong output, drift, template failure, or hallucination in North Forge itself.

Behavior, in order:
1. Acknowledge the fault plainly. Do not get defensive.
2. If a workaround or correct output exists, give it first so the user isn't blocked.
3. Emit the FORGE FAULT REPORT block below, filled from what is known. Mark unknown fields `[UNKNOWN]`.
4. State plainly that the user should preserve this block wherever their fault log actually lives (Kenneth relays these to the Claude Project chat per the repo's governance model - this skill doesn't need to know that mechanism, just that persistence is the human's job, not this session's).
5. Classify Fault type using this taxonomy (matches the audit skill's failure categories): Router Failure / Context Handoff Failure / Template Failure / Output Contract Failure / Source Discipline Failure / Hallucination Risk / Other.

```
FORGE FAULT REPORT
Report ID: [SET BY LOGGER]
Timestamp: [user-provided time or SET BY LOGGER]
Reporter: [user/agent identifier or role, or UNKNOWN]
Package: North Forge - Kyocera Edition (Hermes)
Mode at fault: [/assist, /kb, /draft, /audit, /hl, /esc, etc., or UNKNOWN]
Severity: [Low / Medium / High / Critical]
Fault type: [Router Failure / Context Handoff Failure / Template Failure / Output Contract Failure / Source Discipline Failure / Hallucination Risk / Other]
What happened: [observed behavior]
Expected: [what should have happened]
Repro / trigger: [input or steps that caused it, or UNKNOWN]
Suspected source: [rule block or skill file, if identifiable, else UNKNOWN]
Workaround given: [yes/no + one-line summary]
Status: [Open / Needs Blacksmith review / Fixed in vNext]
```

## 2. Event log (on request)

Trigger: the user asks to capture a runtime event (mode route taken, KB TEMPLATE MISSING stop, escalation packet generated, flush, repeated fault pattern). Do not auto-write events - emit the block only when asked, since this session cannot persist on its own.

```
FORGE EVENT LOG
Timestamp: [user-provided time or SET BY LOGGER]
Package: North Forge - Kyocera Edition (Hermes)
Event: [mode route / template-missing stop / escalation generated / flush / fault pattern / other]
Detail: [what occurred]
Linked report: [Report ID if tied to a fault, else None]
```

## 3. Change log (on request, or after a package edit the user describes)

Trigger: the user asks to record a change, or describes an update/correction they just made to North Forge itself. Emit a ready-to-append entry matching a version/date/Type/Changed/Preserved/Validation format. Do not renumber versions on your own initiative - propose a version and let the human confirm.

## Self-reporting tie-in

When the audit skill detects a failure during /audit or /chk, it may also emit a FORGE FAULT REPORT block for that finding so audit results feed the same log format. This is the closest this system gets to "self-reporting" - it is not self-fixing. A human applies the fix and re-versions.
