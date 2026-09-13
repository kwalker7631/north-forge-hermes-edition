---
name: switch
description: Reset the whole North Forge skill session. Aliases /fl /switch. Not /clr. Not Hermes /clear.
---
# fl / switch — full North Forge session reset

Trigger: /fl, /switch, or the word "switch" typed alone.

This is our equivalent of Hermes `/clear`, scoped to the **North Forge
skill session**: working issue package, theories, carried facts, and
active mode. After /fl they are at default (/assist on a locked TSC
drive) and they see the command menu.

It does **not** invoke Hermes `/clear`. The chat window may still show
old turns. That is the engine history, not our working package. If they
want that gone too, they type Hermes `/clear` themselves.

Never rewrite this skill file on your own initiative. Flag it to the
Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What to do when this triggers

1. Discard the working issue package completely.
2. Reset mode to default.
3. Show the command menu (same content as /menu).
4. Do not reuse facts from before /fl unless the tech types them again.

## Pair

- `/clr` `/flush` — this ticket only, stay in the job.
- `/fl` `/switch` — whole NF skill session, back to the menu.
- `/clear` `/reset` — Hermes chat wipe. Not us.
