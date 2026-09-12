# North Forge Deploy Console

**Version:** 0.2.0  
**Date:** 2026-09-12  
**Author:** Kenneth C. Walker Jr.  
**Access:** Admin only (this folder lives in the private Kyocera edition repo)

Builds a portable USB that runs North Forge without installing anything on the teammate's PC.

If you are building a stick, start at `ADMIN_FIRST_TIME.txt`.  
If you were handed a stick, start at `FOR_THE_PERSON_GETTING_THIS_DRIVE.txt`.

## Why this exists

A teammate should never type `git`, `gh`, or PowerShell. Those belong on **your** admin PC, once. After `gh auth login`, every stick is: plug in → Run as administrator → fill in the web page → wait.

## What a finished stick contains

```
E:\
  Start North Forge.lnk          double-click this
  HOW_TO_START.txt
  north-forge-agent\             public engine
    private-editions\kyocera\    only if this stick is a Kyocera stick
  north-forge-agent-venv\
  north-forge-agent-data\        HERMES_HOME + admin passcode hash
```

## Stick types (2026-09-11 architecture)

The old on-drive FULL / SALES toggle is retired. Do not use `toggle-mode.bat`.

| Choice in the page | What it means |
|---|---|
| Locked stick | `basic` tier. The pin is the only project they can reach. |
| Open stick | `full` tier. You can switch later. Also installs Penny, Pine Barron, field-service overlays when they exist in the engine. |
| North Forge / Kyocera | Private profile from this repo. Priority for TSC. |
| Pocket Penny | Public overlay `editions/penny-pincher` in the engine. |
| Pine Barron Farms | Public overlay `editions/pine-barron-farms`. Studio is still growing; canon packet is deploy-time, not in git. |
| Field-service | Public voice overlay. |

## Files

| File | Role |
|---|---|
| `ADMIN_FIRST_TIME.txt` | Admin setup with almost no typing |
| `FOR_THE_PERSON_GETTING_THIS_DRIVE.txt` | Tape this to the stick |
| `Launch-Deploy-Console.cmd` | Start the local web page |
| `Start-DeployConsole.ps1` | Local server on 127.0.0.1:8765 |
| `Zero-Touch-Deploy.ps1` | Format, clone, bootstrap, pin, lock |
| `ui/index.html` | The page |
| `VERSION.txt` | Version and authorship |

## Safety

- Refuses `C:` and the Windows system drive
- Formats only removable USB (`DriveType=2`) and only if you type `FORMAT`
- Format requires Run as administrator
- Passcode is not put on the process command line; hash only on the stick
- Private Kyocera clone requires GitHub signed in as the repo owner

## Authorship

Kenneth C. Walker Jr. — sole admin of the private edition.  
Engine is a public fork of Hermes Agent (Nous Research, MIT). See the engine `ATTRIBUTION.md`.
