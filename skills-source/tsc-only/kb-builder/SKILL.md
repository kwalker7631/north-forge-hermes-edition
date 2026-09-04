---
name: kb
description: Build a locked-HTML-template KB draft
---
# KB Builder Skill

Trigger: the user asks for a KB, KB draft, ServiceNow KB, knowledge article, publishable article, uses /kb or /k, or says "make that a KB."

When /kb triggers, run the full pipeline as one deliverable - research, Mermaid map, multimedia selection, image/video prompts, META, and the compliance check are all part of the standard output. Do not ask the user to select research, Mermaid, multimedia, image prompts, video prompts, META, or audit separately.

## Primary source format

The standard KB Builder input is a ServiceNow Hotline Case Details export paired with its associated Knowledge Details export - the case that generated the KB, and the KB record itself. This pair already carries the HL case number and the KB number together. QA/Service Bulletin documents and other reference material are supplementary: cited as reference documents layered on top of this primary pair, not treated as the primary source themselves. When only a QA/SB document is supplied without an accompanying case export, build from that document as the primary source per usual, but note in Deep Search Notes that no source hotline case was supplied.

This skill is authoritative for KB structure and content. Read it in full before drafting. Do not fall back to a general impression of "what a KB usually looks like" - the locked template and the rules below are the standard, not a starting point to improvise from.

Never rewrite this skill file on your own initiative, even to fix something that looks wrong. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## CRITICAL: HTML template lock

Approved HTML reference source of truth: `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`. This file must be present in the project (repo root or wherever the Blacksmith has placed it) before a publishable KB can be generated.

The HTML reference is a mold, not inspiration:
- Do not convert the KB to Markdown for a publishable draft.
- Do not create a new layout.
- Do not rename standard sections unless the reference file itself has changed.
- Do not remove the brand header, affected products table, technical summary block, advisory/firmware block, procedure sections, media reference area, support/resources block, or drafting/review block when those sections exist in the reference.
- Do not move META, media prompts, deep search notes, or drift review into the published KB body.

Default /kb output:
1. Short line: "KB Builder: HTML template locked to KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html."
2. Complete KB as valid HTML using the reference structure and inline CSS.
3. Replace bracketed placeholders with synthesized content.
4. Preserve HTML comments and section order from the reference wherever practical.
5. ServiceNow-safe: inline CSS, no absolute positioning, no emojis, no external scripts, no unsupported embedded JavaScript.
6. Technician Drafting / Review Block clearly marked: DELETE BEFORE PUBLISHING.
7. End with a Template Compliance Check (see below).

If the reference HTML file is unavailable or not loaded: stop before generating a publishable KB and return exactly:
"KB TEMPLATE MISSING - attach or load KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html. I will not freestyle a KB."

Exception: if the user explicitly asks for a non-publishable outline, produce a plain text outline only, labeled "NOT PUBLISHABLE - HTML TEMPLATE NOT APPLIED."

### Template Compliance Check (required at the end of every /kb output)
- Reference used: filename and version.
- Output type: full HTML document or ServiceNow HTML fragment.
- Required section order followed: Yes/No.
- Support & Resources present: Yes/No.
- Contact Block Lock passed: Yes/No.
- Portal URL present: Yes/No.
- Downloads URL present: Yes/No.
- TSC phone present: Yes/No.
- TSC email present: Yes/No.
- Authorized-login note present: Yes/No.
- Drafting / Review Block outside publish body: Yes/No.
- Media prompts outside publish body: Yes/No/Not applicable.
- Placeholder tokens remaining: list them or "None".
- Non-template sections inserted: list them or "None".
- Publish status: Draft / Needs Blacksmith review / Ready after Blacksmith approval.

## CRITICAL: Support & Resources contact block lock

Mandatory in every publishable KB, sourced from the same locked HTML reference. Must include exactly:
- HTML comment: `<!-- SUPPORT & RESOURCES -->`
- Heading: Support & Resources
- Opening line: "Need additional assistance? Contact the Technical Support Center directly using the options below."
- Support Portal button -> https://kyocera.service-now.com
- Support & Downloads button -> https://mykyocera.kyoceradocumentsolutions.us
- Authorized-login note: "You must log in with authorized credentials. Without a login, only end-user materials are accessible."
- Contact logo placeholder, 128x64
- Technical Support Center (TSC) label, phone 1-800-255-6482, hours Monday-Friday 9 AM - 6 PM EST
- TSC EMAIL label, customer.service@da.kyocera.com
- KB Recommendation language for field-submitted tips
- Technical note positioned after the contact data, not before it

Do not replace this block with a placeholder, summarize it, move it into the Drafting Block, delete the portal/download buttons, or change the phone/email/hours/URLs/authorized-login note without an updated approved HTML reference from the Blacksmith. If any required element is missing, mark: "Template Failure - Support & Resources Contact Block missing or altered."

## Content scrubbing (published KB body only)

Never include technician names, customer names, dealer/company names, or HL/case ticket numbers, even when they appear verbatim in a source hotline case export. Refer to sourcing generically. This does not apply to internal Deep Search Notes in the Drafting Block, where sourcing can be more specific as long as no personal or company identifiers appear there either.

## Writing standards (published KB body)

- Define every abbreviation/acronym in full on first use in the body, abbreviation in parentheses (e.g., "Low Voltage Printed Wiring Board (LV PWB)"), then use the short form. Titles/headings may stay abbreviated.
- Never use bare "supply" for a power supply - always "power supply" or a full descriptive term.
- Attribute technical knowledge to "TSC field engineering expertise," review/approval to "TSC Reviewer." Never use "Blacksmith" in body or Drafting/Review Block content.
- When a referenced QA/SB document already contains exhaustive reference data (exact part numbers, connector counts), link to it instead of reproducing it in the body.
- Write technician-facing only, never end-user facing. Assume no prior knowledge of the subject area, especially once a KB touches something like Windows or Linux. Add an explicit warning ahead of any step that's easy to skip but important (e.g., back up before editing the registry).

## Published KB body structure (include when relevant)

Title / Affected Products & Environment / Symptom-Failure Behavior / Technical Summary / Before You Begin / Required Tools-Access / Firmware-Software First Check / Direct Repair Procedure / Field Tactics / Tech Tip / Media Reference Placeholder / Diagnostic Map (Mermaid, mandatory - see below) / Error Codes-Logs-Evidence / Common Mistakes / Validation Before Leaving / Stop and Escalate If / Support & Resources.

A KB may also include a Power Connector Reference or similar non-template reference section when concrete connector/pin/spec data directly supports the repair procedure - declare it under "Non-template sections inserted" in the Compliance Check.

## Drafting / Review Block (outside publish body, marked DELETE BEFORE PUBLISHING)

In order:
1. **META String** - every affected model, comma-separated (not just the primary confirmed one), plus error codes, part numbers, plain-language search terms a tech would type ("motor," "motor failure," "power supply failure"), and a QA reference number placeholder if none supplied. No process/status notes - META is search terms only.
2. **Media Generation Bundle** - run the multimedia selection logic below first, state selected type(s) and reason, then generate the applicable prompts. If source material includes usable images, flag them here as candidates for TSC Reviewer/Blacksmith evaluation (after content-scrubbing check) instead of only generating from-scratch prompts.
3. **Deep Search Notes** - sources checked, confirmed findings, conflicts/gaps, publish status. Attribute to "TSC field engineering expertise."
4. **Suggested Tech Tips** - short field observations that didn't fit the body, one or two sentences each, source-backed or clearly labeled field-reasoned.
5. **Drift / Clarification Review** - Confidence (High/Medium/Low); Source Status (source-backed/field-reasoned/partially supported/unsupported); Possible Drift (unsupported firmware claim, model/family uncertainty, consumer Windows path assumption, unverified exact filename, vague repair instruction, missing logs/samples/screenshots/service code/validation step/alt text/transcript text, visual not compliant, multimedia selection not justified, unclear customer environment, unsupported forum claim); Missing Details; Blacksmith Review Required; Do Not Publish Until.

A correct "not ready" is better than a polished bad KB.

## Multimedia selection (mandatory logic, not optional)

Mermaid diagnostic/procedure map is mandatory in every KB - full decision tree for multi-branch troubleshooting, or a simple linear flow (intake -> check -> action -> validation) for single-path procedures. Never skip it or mark it "not required." Include a plain-text fallback.

For every other section, choose the most effective type:
- Image/screenshot: UI state, settings screen, menu path, physical component/defect/wiring location, before/after comparison, single reference view.
- Video: multi-step physical procedure where motion/orientation/hand position matters, 5+ sequential UI steps, high-risk procedures, jam clearing, assembly/disassembly, connector seating, component replacement.
- Text only (beyond the mandatory Mermaid map): single-step action, setting change or error code lookup, content that changes too frequently for visual media to stay current, or where a diagram/image adds no clarity.

Multiple media types in one KB is normal (Mermaid plus image or video), not redundant. Document the rationale for each in the Media Generation Bundle.

## Field tactics (physical service, image defects, paper feed, jams, developer/drum/toner, transfer, fusing, firmware, logs, escalation)

Include: what to open/remove, what to inspect, what normal vs failure looks like, what to clean, what to reseat, what to replace only if confirmed, what samples/logs/photos to collect, what to document, what not to disturb.

FRU-first: Kyocera field service favors full assembly swaps (FK = Fuser Kit, LV = power supply board, etc.) over in-place component diagnostics. Electrical checks should be simple and qualitative ("confirm AC is steady and grounded," "watch one 24V rail for a dip under load") - not exhaustive multi-point metering with precise spec figures. When a pattern-recognition step (a repeating log entry, a specific fault-code combination) is what actually tells the tech which FRU to replace, make that the centerpiece rather than a deep electrical explanation.

## Firmware / software first check

Every KB includes this - not conditional on whether firmware clearly relates to the symptom. Short green box, not a heavy section - must not compete with the actual problem/solution content.

- Nudge the tech to confirm current firmware/release online before going further.
- Give the reason even with no known firmware fix for this specific fault: firmware/software bundles routinely include reliability/security fixes unrelated to the reported symptom.
- When there are two or three concrete, known reasons - not vague filler - bullet them with a short "why" each. On authentication/connector/cloud-service topics, flag the shift from certificate-based to token-exchange-based authentication as a key item, since it affects whether the device keeps working with the service at all.
- Link release notes and ServiceNow. Mention attaching the relevant log (e.g., U000/event log) to whatever case is opened.
- Do not claim firmware resolves the reported issue unless supported by documentation, release notes, an approved source, or field validation - selling firmware currency is not the same as claiming it fixes this fault.

## Cautions (use only where relevant, no generic filler)

Disconnect power before removing covers/handling internals. Allow fuser/hot areas to cool. ESD care for boards/memory/controllers/SSDs/connectors - de-energized, unplugged equipment ONLY. Do not power off during firmware update. Do not enter service mode without documented reason and approved procedure. Do not measure resistance/continuity on a live circuit. Do not create missing folders/paths unless the vendor procedure says to. Do not replace boards/parts before evidence supports it.

**ESD wrist strap correction (critical):** an ESD strap is for static-safe handling of a PWB on de-energized, unplugged equipment only. Never instruct wearing one while working on, probing, or metering a powered/energized machine - the strap grounds the wearer, which is unsafe near a live circuit. For any powered step (e.g., metering voltage under load), instruct staying separated from grounded chassis metal, and remove the strap first if it's on. When a KB includes both a live-measurement step and a de-energized handling step, be explicit about which requires the strap and which requires it removed.

## Deep search requirement

Required before marking an article publish-ready. Check: approved internal documentation, Kyocera.info, global Kyocera portals, firmware release notes, driver documentation, application documentation, known issue history, public support resources, public technician forum signals when appropriate. Forum/grassroots findings must be marked unverified unless confirmed by an approved source or Blacksmith review.

If deep search was not performed, mark: "Research Incomplete - Not Ready for Publish."

If search access is unavailable in the current environment: still build the draft, mark every research-dependent claim `[UNVERIFIED - NO SEARCH ACCESS]`, add "Research Incomplete - Not Ready for Publish" as a hard stop in the Drift Review. Do not block KB Builder from producing a usable draft - produce the best draft possible, mark gaps clearly, let the Blacksmith decide.

## Visual media standard

Typography: Verdana/Arial/sans-serif. Colors: #282828 dark gray, #F2F2F2 light gray, #D32F2F Kyocera red (critical callouts), #0A9BCD blue (technical labels), #00B176 green (confirmed/recommended paths), #CCCCCC/#DDDDDD neutral borders.

Never generate: emojis, emoticons, cartoon/mascot visuals, sparkles, fantasy styling, AI-art look, irrelevant images, fake UI, customer-specific private information, unsupported model/procedure claims.

Every image asset needs: purpose, placement recommendation, required labels, alt text, caption/description, media tags. Every Mermaid diagram needs a plain-text fallback. Every chart needs a fallback table or written summary. Every image placeholder in the KB body needs visible description text so a broken image doesn't leave an empty gap.

Video prompts: plain technical narration, no music/branded intros/cheerful openers/sign-offs. Technician's-eye-view camera perspective for physical procedures. Label key components/connection points/critical steps on-screen. Duration targets: single-procedure steps under 90 seconds, multi-phase procedures under 4 minutes, orientation/overview under 2 minutes. No AI-generated faces/actors unless specifically requested and authorized, no cartoon mascots, no decorative motion graphics, no background music/sound effects, no branded promotional narration. Closed captions and a plain-text transcript are required for every video prompt.

Every video prompt needs: video type, scene description, camera perspective, key actions in sequence, on-screen labels, narration/script outline, duration target, exclusions, transcript text, media tags.
