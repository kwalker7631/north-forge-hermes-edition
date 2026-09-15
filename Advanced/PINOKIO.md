# Pinokio — the model lab next to the desk

Pinokio is the engine bay for adding, testing, and removing local models
through a real web UI. That install is **required on BLACK-NORTH**. It is
not required on Greg or a BASIC stick.

North Forge remains the desk. Pinokio remains the lab. We do not rebuild
Pinokio. We point it at a folder on the stick (or on a bigger disk).

Official project: https://github.com/pinokiocomputer/pinokio

## Where it lives

| Place | Pinokio |
|---|---|
| `BLACK-NORTH` (master, large / up to ~2 TB) | Yes. Full lab. |
| `GREGW-NOREX` and other Excalibur | Optional, small. |
| `FIRSTL-NORTH` / `BASIC-NORTH` | No. |
| Public clone | No. |

Home folder name has no spaces: `pinokio-home` at the volume root.
Format that volume **NTFS** if Pinokio will live there. Teammate sticks
stay exFAT without it.

```
<DRIVE>:\
  Start North Forge.lnk
  Start Pinokio Lab.cmd
  pinokio-home\          PINOKIO_HOME
  pinokio-app\Pinokio.exe
  north-forge-agent\
  north-forge-agent-venv\
  north-forge-agent-data\
```

First launch: Settings → Home → `<DRIVE>:\pinokio-home`.
A tiny pointer may sit in the current user's AppData. The models stay
in `pinokio-home`. Delete the pointer on a dirty host; the stick still
holds the lab.

## Thumb drive rules (absolute)

Storage does not stretch.

- Keep **one or two** models active on a USB stick.
- Offload anything you are not demonstrating this week. Delete or move
  the model folder out of `pinokio-home` through Pinokio's own UI
  (add / test / remove). Do not leave cold weights on a 256 GB stick.
- Need more models? Use a **larger drive**, or offload `pinokio-home`
  to another external disk and retarget Home. Do not pack the lab onto
  Greg's stick.
- Installing Pinokio on the **local PC** is optional. Prefer the stick
  or a second external so the lab travels. If someone wants it on C:,
  that is their disk, not the fleet standard.

## Deploy (master only)

1. North Forge on BLACK-NORTH first. Prove Terminal answers.
2. NTFS. Create `pinokio-home` and `pinokio-app` at the root.
3. First run, set Home. Discover **one** app. Stop.
4. Second model only if the free space still looks honest.
5. `Start Pinokio Lab.cmd` at the root.

```bat
@echo off
set "ROOT=%~d0\"
set "PINOKIO_HOME=%ROOT%pinokio-home"
if not exist "%PINOKIO_HOME%" mkdir "%PINOKIO_HOME%"
if exist "%ROOT%pinokio-app\Pinokio.exe" (
  start "" "%ROOT%pinokio-app\Pinokio.exe"
) else (
  echo Pinokio.exe not on this drive. See Advanced/PINOKIO.md
  pause
)
```

`%~d0` follows the letter. Do not hardcode D: or F:.

## Hard limits

- The host GPU stays in the host. The stick is not a video card.
- USB is slower than an internal SSD. First download is a coffee break.
- Path must not contain spaces.
- Some installers want admin once.

## Credit

Pinokio is MIT (cocktailpeanut / Factory). We wrap it. We did not write it.
