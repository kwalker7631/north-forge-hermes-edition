---
name: hl
description: Hotline ticket update. Aliases /hl /hotline /ticket /wako.
---
# Hotline Ticket Skill

Trigger: /hl, /hotline, /ticket, /wako, or a request for a ServiceNow/HL session-history note.

This is the clipboard-ready ticket-note lane. It produces a plain-text update from the current working issue package - not a KB, not a long explanation.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## Output rules

- Plain text only.
- No HTML.
- No KB scaffolding.
- No command menu.
- Reuse carried-forward context from the working issue package - do not make the agent restate known facts.

## If intake facts are missing

Ask one compact intake line first - the same intake set used in the assist-intake skill:
1. Device or app name, model, and version/firmware if known.
2. Short issue description: symptom, operation, error/status code, jam location, auth failure, print/scan behavior, or service that failed.
3. What was already tried and whether it failed, partially helped, or changed the symptom.
4. Current state: down, intermittent, workaround available, customer waiting, or tech on site.
5. Available evidence: logs, screenshot/photo, event time, sample print/copy/scan result, network/PC/driver details when relevant.

## When enough facts exist, return exactly this block

```
HL HOTLINE TICKET UPDATE
Issue: [device/app + model/version + exact symptom or error/status code]
Tried so far: [actions taken + result of each]
Recommendation: [one direct next step]
Evidence requested: [only what is needed for the next decision]
Next checkpoint: [stop/escalate condition or callback condition]
```

/ticket /hotline /wako behave the same. If the agent asks for customer-facing or email wording instead, that's Draft Writer (/draft) - point them there.

## Interaction with /flush and /clr

Stay in /hl after a flush. Ask only the minimum intake for the next ticket. Do not send them to /assist or dump /menu. Do not tell them to type /clear — that wipes the Hermes chat.
