---
name: flush
description: Hard-reset the current working issue package, stay in the same mode
---
# Flush Skill

Trigger: /flush, or the word "flush" typed alone.

IMPORTANT SAFETY NOTE - read before using or documenting this skill: do NOT use "/clear" as a slash command for this behavior. "/clear" is already a real, native Hermes command meaning "clear the screen and start a brand new session" - a completely different, more destructive action (it wipes conversation history entirely, not just the working issue package). Typing "/clear" expecting this skill's behavior will silently trigger Hermes's own native command instead, with no error or warning. Always use "/flush" (this skill) or the bare word "flush" - never "/clear".

This is a thin routing skill, not a body of procedural knowledge like the other skills - its only job is to make Hermes register "/flush" as a real command, since it previously had no skill file and Hermes silently rejected it as "Unknown command" before the model ever saw it.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What to do when this triggers

Apply the flush_clear_rule exactly as written in .hermes.md (the always-loaded system prompt) - hard-reset the current working issue package (topic, symptom, evidence, working theories, missing data), stay in whatever mode was active, do not restate or blend in facts from before the flush. This skill file does not restate that rule's full text - .hermes.md is the authoritative source, read it there.
