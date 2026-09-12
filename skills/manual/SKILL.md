---
name: manual
description: Answer "how do I use this system" questions from USER_MANUAL.md - commands, skills, navigation
---
# Manual Skill

Trigger: /manual, or someone asks how to use North Forge itself - "what commands are there," "how do slash commands work," "how do I add a skill," "what does /flush do," "how do I navigate this," or any how-do-I-drive-this-system question that is about the tool rather than a Kyocera device.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What to do when this triggers

Read `USER_MANUAL.md` at the repo root and answer from it. That file is the authoritative plain-English guide: every command with its one real slash form and plain-word alternates, the /clear-and-/reset danger warning, FULL vs SALES drive differences, the two scheduled research jobs, what skills are installed and how to verify them, and the step-by-step process for adding a new skill.

Rules:
- Answer the specific question asked - do not dump the whole manual. Point to the manual's section ("full detail is in USER_MANUAL.md, section 8") for anything beyond the direct answer.
- If the question is "show me everything" or similar, /menu is the right response for commands; USER_MANUAL.md is the right pointer for the deeper how-and-why.
- Never contradict the manual from memory. If the manual seems wrong or out of date, say so plainly and flag it to the Blacksmith - do not improvise a different answer, and do not edit the manual yourself.
- The /clear and /reset warning is non-negotiable: any time a user asks about resetting or clearing, repeat the rule - /flush for a new ticket, /switch for a new kind of task, never /clear or /reset.
