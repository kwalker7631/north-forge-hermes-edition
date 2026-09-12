# North Forge Kyocera Edition — current (read this first)

**Version:** profile `0.1.0` · **Date:** 2026-09-12 · **Author:** Kenneth C. Walker Jr.  
**This repo is private.** It is the reference OEM pack, not a second engine.

> Architecture since 2026-09-11: this repo is a **Hermes profile distribution**.
> It installs into an already-running North Forge engine.
> Anything in the long README about FULL/SALES toggles, `.hermes-home`, or
> `launch-north-forge.bat` is history.

## What this edition is

Three years of TSC work, not a prompt with a logo. This pack is the Kyocera
expert layer: electro-mechanical product support, the Windows / macOS / Linux
workstation the device is on, and field stacks such as PaperCut and MyKey.

It is an on-demand expert that is supposed to **mark a hole instead of filling
it with a guess**. When the tech or admin supplies the missing research, that
answer is persisted so the next session has it.

Also in this repo:

- Identity and routing (`SOUL.md` + menu skills)
- TSC skills (intake, ticket, KB, escalation, fault log, training)
- Locked KB HTML template
- Admin deploy console (`Advanced/deploy-console/`)

Strip the banner. The skills still do Kyocera TSC work. That is the test.

## Domain this pack is aimed at

- Print / scan / finish / paper path / supplies (electro-mechanical)
- Host PC and network (Windows, macOS, Linux)
- PaperCut, MyKey, and other document-management tools the skills know
- Hotline, KB authoring, escalation, fault history, new-hire training

If a fact is not in a skill, a memory, or the evidence just given — say so.
Do not invent firmware, part numbers, or “usually it is this.”

## Skill catalog (what you are customizing)

| Skill folder | Tech types | Job |
|---|---|---|
| `menu` | `/menu` | Front door |
| `assist-intake` | `/a` `/assist` | Structured intake |
| `hotline-ticket` | `/hl` `/ticket` | Hotline / ticket packet |
| `kb-builder` | `/kb` | Draft to the locked KB template |
| `draft-writer` | `/draft` | Shorter draft pass |
| `escalation-packet` | `/esc` | Escalation with evidence that exists |
| `fault-logging` | `/log` `/fault` `/report` | Durable fault record |
| `forge-audit` | `/audit` `/chk` | Check a draft against the rules |
| `training-guide` | `/train` | Teach a new tech the workflow |
| `sales-assist` | sales prompts | Pre-sales guidance |
| `web-navigator` | vendor site hops | Official public pages only |
| `kyocera-research` | research / cron | Release-note watch |
| `daily-brief` | brief | Morning digest |
| `manual` | `/manual` | In-session help |
| `flush` | `/flush` | Clear generated scratch |
| `switch` | `/switch` | Edition switch (open sticks only) |

A Sharp or Ricoh edition is this same table with different portals and templates.

## How an admin ships it

`Advanced/deploy-console/ADMIN_FIRST_TIME.txt`  
Teammate card: `FOR_THE_PERSON_GETTING_THIS_DRIVE.txt`  
Stick size: **8 GB or larger**. Windows teammate path first. Docker is an admin/lab option on the engine, not the hotline handoff.

Offline only if a local model is on the stick. Cloud models need a network.

## Roadmap (not shipped)

Database-backed KB / assets, a graphical tech workbench, first-class graph /
presentation / video / image tools in the TSC loop, more OEM packs, cleaner
offline images.

## How this becomes Sharp / Ricoh / Xerox

Copy this repo's *shape*, not its Kyocera text, into a new private repo.
Follow `editions/OEM.md` on the public engine. Pin the new slug.
Do not fork the engine per customer.

## Monetization (intent, not code)

- Public engine: free to run.
- This edition and future OEM packs: licensed / private / custom-quoted.
- Nothing in git implements billing.
