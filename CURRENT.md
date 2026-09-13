# North Forge Kyocera Edition — current (read this first)

**Version:** profile `0.1.0` · **Date:** 2026-09-12 · **Author:** Kenneth C. Walker Jr.  
**Private.** This is the TSC pack. The public engine is not the product.

The person who should never see this file is the teammate. They get a stick
and [FOR_THE_PERSON_GETTING_THIS_DRIVE.txt](Advanced/deploy-console/FOR_THE_PERSON_GETTING_THIS_DRIVE.txt).

## Why this exists

A tech on a live call should not have to become a prompt engineer. This pack
is the long prompt, broken into compartments: device, PC, network, PaperCut,
MyQ, ticket, KB, escalation. The tech talks like a coworker. If the pack does
not have the page, it is supposed to say so and keep the answer after someone
supplies it.

Built by Kenneth C. Walker Jr. as a go-to in your pocket — learns from the
shop, corrects when caught, does not sound like a brochure.

How the desk uses it: [DESK_MODES.md](DESK_MODES.md) — assist coaches the
tech, HL writes the ticket, `/check` goes looking. One engine.

Architecture since 2026-09-11: this repo is a profile pack that installs into
the public North Forge checkout. FULL/SALES launchers in the long historical
README are history.

## Domain

- Print / scan / finish / paper path / supplies
- Host PC and network (Windows, macOS, Linux)
- PaperCut, MyQ, other document tools the skills know
- Hotline, KB, escalation, fault history, new-hire training

## Skill catalog

| Skill folder | Tech types | Job |
|---|---|
| `menu` | `/menu` | Front door |
| `readme` | `/readme` | Documentation map |
| `assist-intake` | `/a` `/assist` | Coach the tech (old GPT assist) |
| `hotline-ticket` | `/hl` `/ticket` | Write the SN / HL ticket (Wako/HL) |
| `forge-audit` | `/check` `/chk` `/audit` | Look it up, then audit a draft |
| `kb-builder` | `/kb` | Draft to the locked KB template |
| `draft-writer` | `/draft` | Shorter draft pass |
| `escalation-packet` | `/esc` | Escalation with evidence that exists |
| `fault-logging` | `/log` `/fault` `/report` | Durable fault record |
| `training-guide` | `/train` | Teach a new tech the workflow |
| `sales-assist` | sales prompts | Pre-sales guidance |
| `web-navigator` | vendor site hops | Official public pages only |
| `kyocera-research` | research / cron | Release-note watch |
| `daily-brief` | brief | Morning digest |
| `manual` | `/manual` | In-session help |
| `document-search` | `/docsearch` (or ask naturally) | Index-aware lookup in dropped reference PDFs (`Documents/`) |
| `flush` | `/flush` | Clear generated scratch |
| `switch` | `/switch` | Edition switch (open sticks only) |
| `pinokio` | `/pinokio` | On-drive lab (256 GB stick) |

`readme` lives in both `skills-source/shared/readme/` and `skills/readme/`.

Sharp / Ricoh / Xerox later = this table, different portals and templates.

## Ship it

Preferred: [Advanced/deploy-console/ADMIN_FIRST_TIME.txt](Advanced/deploy-console/ADMIN_FIRST_TIME.txt)  
Stick: **8 GB or larger**. Windows first. Offline only with a local model.

Roadmap (not shipped): ServiceNow sidebar / browser extension, parts and
service-document shelf, database, graphical workbench, more OEM packs,
cleaner offline images.

## Thanks

The runtime under the public checkout is Hermes Agent by Nous Research and
contributors (MIT). Thank you. It is not what you pitch first.
