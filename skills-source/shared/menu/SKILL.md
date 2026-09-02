---
name: menu
description: Show the full command menu for this drive's current mode
---
# Menu Skill

Trigger: /menu, or the word "menu" typed alone, or "help", "show options", "start", "hello", "hi" with no other actionable content.

This is a thin routing skill, not a body of procedural knowledge like the other skills - its only job is to make Hermes register "/menu" as a real command, since it previously had no skill file and Hermes silently rejected it as "Unknown command" before the model ever saw it.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What to do when this triggers

Show the command menu exactly as it already appears in the command_menu section of .hermes.md (the always-loaded system prompt already contains the correct menu for whichever mode this drive is running - FULL or SALES). Show it as written there, do not invent a different menu, do not summarize it. This is the one situation where showing the full menu is correct and expected - it does not conflict with the "don't dump a giant menu on every response" rule elsewhere, because this skill only triggers when the menu was explicitly asked for.
