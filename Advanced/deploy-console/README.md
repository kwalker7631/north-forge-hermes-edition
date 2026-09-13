# North Forge Deploy Console

**Version:** 0.2.0  
**Date:** 12 September 2026  
**Author:** Kenneth C. Walker Jr.  
**Access:** admin only. This folder lives in the private Kyocera edition.

Builds a portable USB that runs North Forge without installing anything on the teammate's PC.

- Building a stick: [DEPLOY.md](DEPLOY.md) or [ADMIN_FIRST_TIME.txt](ADMIN_FIRST_TIME.txt)
- Handed a stick: [FOR_THE_PERSON_GETTING_THIS_DRIVE.txt](FOR_THE_PERSON_GETTING_THIS_DRIVE.txt)
- Pinokio on a *separate* lab disk (never this stick): [../PINOKIO.md](../PINOKIO.md), run with `Install-Pinokio-Lab.ps1` / `Remove-Pinokio-Lab.ps1` in this folder

Assign every stick to a person. Volume name is **FIRSTL-NORTH** (Greg Warhol → `GREGW-NORTH`). Agent name is optional. Default is North Forge.

## Why this exists

A teammate should never type `git`, `gh`, or PowerShell. Those belong on your admin PC, once. After `gh auth login`, every stick is: plug in → Run as administrator → fill in the page → wait.

## Stick types

The old FULL / SALES toggle is retired. Do not use `toggle-mode.bat`.

| Choice on the page | Meaning |
|---|---|
| Locked stick | Teammate cannot switch projects |
| Open stick | You can switch later |
| North Forge / Kyocera | This private pack. Priority for TSC |
| Pocket Penny | Public overlay |
| Pine Barron Farms | Public overlay. Studio still growing |
| Field-service | Public voice overlay |

## Safety

- Refuses C: and the Windows system drive
- Formats only removable USB, and only if you type FORMAT
- Format needs Run as administrator
- Passcode is hashed on the stick, not stored in this page
- Private Kyocera clone needs GitHub signed in as the repo owner

## Authorship

Kenneth C. Walker Jr. Engine is a public fork of Hermes Agent (Nous Research, MIT).
