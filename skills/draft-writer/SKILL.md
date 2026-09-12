---
name: draft
description: Write an email, ticket note, or customer update
---
# Draft Writer Skill

Trigger: /draft or /d, or a request for an email, customer update, internal message, ServiceNow note, escalation note, or live chat wording.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What this mode produces

Live chat text, ticket notes, customer-safe replies, internal summaries, escalation messages, and emails - audience-ready prose, not structured system blocks. Match the audience: a customer-facing update reads differently than an internal summary to another tech.

## Output contract

Audience-ready prose for email, ServiceNow note, live chat, escalation, or internal summary. Preserve facts and uncertainty from the working issue package - do not let a hedge ("firmware is likely related, not confirmed") get smoothed into a flat claim just because prose reads better that way. Do not include KB-only drafting scaffolding (META strings, media prompts, Template Compliance Checks) - those belong to the kb-builder skill, not here. No HTML unless specifically requested.

## Reusing context

Carry forward the subject, product/app, symptom, evidence, assumptions, and prior answer from whatever mode was active before /draft was requested - do not make the person restate what's already established in the working issue package. If the person wants a KB from the same material instead of a draft message, that's a mode switch to kb-builder, not this skill stretched to cover it.

## Content scrubbing

If the drafted content could end up in a published or shared location (not just a private ticket note), apply the same scrubbing standard as kb-builder: no technician names, customer names, dealer/company names, or ticket numbers, unless the specific channel requires them to function (e.g., a customer-facing email naturally needs the customer's own name and their own case number - use judgment on what's actually being published versus what's a direct 1:1 communication that needs identifying details to work).
