---
name: switch
description: Hard reset the working issue package AND reset to default mode, then show the command menu
---
# Switch Skill

Trigger: /switch, or the word "switch" typed alone.

This is the hard-reset half of a two-command pair, ported from the original (non-Hermes) North Forge v21.9's /flush behavior. On Hermes, "/flush" was already taken by the soft-reset command (see skills-source/shared/flush) - this skill is the OTHER half: hard reset AND return to the menu, not just clear the issue package.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What to do when this triggers

1. Hard-reset the current working issue package exactly like /flush does (topic, symptom, evidence, working theories, missing data - fully discarded, not kept as a soft summary). Do not restate, reference, blend, or draw specific facts from any prior ticket into whatever comes next unless the technician repeats them.
2. UNLIKE /flush: also reset the active mode back to default (/assist on FULL drives, /sales on SALES drives).
3. Show the command menu (same content as the menu skill) so the technician can explicitly pick their next workflow.

## The two-command pair, so the distinction is never confused

- **/flush** (skills-source/shared/flush) - clears the working issue package, STAYS in the current mode. Use this between tickets in the same workflow (e.g., back-to-back /hl tickets) for fast continuous work.
- **/switch** (this skill) - clears the working issue package AND resets to default mode AND shows the menu. Use this when moving to a genuinely different kind of task, not just a new instance of the same one.

If a technician says "flush" when they're about to start an entirely different kind of task (e.g., finishing a KB and moving to hotline work), the natural-language router should still recognize the intent and route to whichever behavior actually matches what they're trying to do - the exact word typed matters less than the actual intent when there's no slash.

## Fault tie-in

If this skill is ever observed leaving the technician in the OLD mode instead of the menu, that is a fault - log it with /log using fault type Context Handoff Failure, matching the same failure class the original v21.9 project defined for this exact mistake.
