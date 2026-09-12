---
name: readme
description: Open the right North Forge documentation set. Use when the user types /readme, asks for the README, or names north-forge-agent, north-forge-hermes-edition, north-forge-hermes-agent, or kyocera docs. Point them at the front door. Do not walk live fault codes on the README.
---

# /readme

Show the documentation map. Do not dump a fault-code procedure. Do not pitch the engine first.

## Aliases

| User says | Open |
|---|---|
| `/readme` (no argument, on a Kyocera stick) | This edition README + CURRENT.md |
| `/readme north-forge-agent` | Public chassis README + DOCS.md |
| `/readme kyocera` | This edition README + CURRENT.md |
| `/readme north-forge-hermes-edition` | Same as kyocera |
| `/readme north-forge-hermes-agent` | Same as kyocera |

## What to print

Keep it short.

**Public chassis (`north-forge-agent`)**
- Front door — README.md
- START_HERE.md, PRODUCT.md, CAPABILITIES.md, LEARNING.md, editions/OEM.md
- Map — DOCS.md

**Kyocera edition**
- Front door — README.md (this repo)
- CURRENT.md, LEARNING.md
- Deploy — Advanced/deploy-console/DEPLOY.md and ADMIN_FIRST_TIME.txt

Then offer `/menu` if they wanted a working session instead of docs.

If they ask for a specific service code after `/readme`, switch to the matching skill. The README is the map, not the shop floor.
