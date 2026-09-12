# North Forge Kyocera Edition — current (read this first)

**Version:** profile `0.1.0` · **Date:** 2026-09-12 · **Author:** Kenneth C. Walker Jr.  
**This repo is private.** It is the reference OEM pack, not a second engine.

> Architecture since 2026-09-11: this repo is a **Hermes profile distribution**.
> It installs into an already-running North Forge engine.
> Anything below in the long README that talks about FULL/SALES toggles,
> `.hermes-home`, or `launch-north-forge.bat` is history.

## What this edition is

A technical support content pack for Kyocera Document Solutions:

- Identity and routing (`SOUL.md` + menu skills)
- Real TSC skills (intake, ticket, KB, escalation, fault log, training)
- Locked KB HTML template
- Admin deploy console (`Advanced/deploy-console/`)

It is not a skin. Strip the banner and the skills still do Kyocera TSC work.

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

That list is the product. A Sharp or Ricoh edition is the same table with different portals, templates, and `SOUL.md`.

## How an admin ships it

Use `Advanced/deploy-console/ADMIN_FIRST_TIME.txt`.  
Teammates use `FOR_THE_PERSON_GETTING_THIS_DRIVE.txt`.  
They never clone this repo.

## How this becomes Sharp / Ricoh / Xerox

Copy this repo's *shape*, not its Kyocera text, into a new private repo.
Follow `editions/OEM.md` on the public engine.
Pin the new slug. Do not fork the engine per customer.

## Monetization (intent, not code)

- Public engine: free to run.
- This edition and future OEM packs: licensed / private / custom-quoted.
- Nothing in git implements billing. Do not put prices in skills.
