# Pinokio on the same drive as North Forge

Pinokio is the free one-click lab: years of work so someone with no
background can stand up local image, voice, and small-model tools.
It is not the desk senior. It is the **sandbox next to the desk**.

We run it from the **same thumb drive** as North Forge. Home is on the
stick. We do not lock the zoo to one PC's AppData.

Official project: https://github.com/pinokiocomputer/pinokio

## Same-drive layout (256 GB learning stick)

Format this class of stick **NTFS**. Pinokio's own notes want NTFS,
no spaces in the home path. The small teammate Excalibur stick can stay
exFAT **without** Pinokio.

```
E:\                                volume GREGW-NORTH
  Start North Forge.lnk
  Start Pinokio Lab.cmd            ← this page
  HOW_TO_START.txt
  north-forge-agent\
  north-forge-agent-venv\
  north-forge-agent-data\
  pinokio-home\                    ← PINOKIO_HOME  (no spaces)
    api\
    bin\
    cache\
    drive\
    logs\
  pinokio-app\                     ← unpacked Electron / installed files
    Pinokio.exe
```

First Pinokio launch: Settings → Home → `E:\pinokio-home` (the letter
will change on the next PC; the folder name must stay `pinokio-home`
at the drive root).

A few bytes of "where is home?" may still land under the current
user's AppData. That is a pointer, not the product. The models and
binaries stay on the stick. If a host is dirty, delete that pointer;
the stick still holds the lab.

## What it is for (the sale)

Use Pinokio to **see** generation — image, voice, a small local
model — so a Blue Book reader understands what "local AI" is without
a lecture.

Then go back to North Forge for the call.

| | |
|---|---|
| North Forge | The desk. Procedures. Honesty. The pack. |
| Pinokio | The lab. Click, install, watch something generate. Learning. |

Do not generate a customer's problem in Pinokio and call it a KB.
Do not put Pinokio on the 32 GB manager-first stick.

## Deploy (admin, same console family)

1. Build North Forge first (`ADMIN_FIRST_TIME` → `DEPLOY.md`).
2. On a **256 GB NTFS** stick, create `pinokio-home` at the root.
3. Install or unpack Pinokio into `pinokio-app` on that same root.
4. First run, set Home to `.\pinokio-home` on that drive.
5. Install **one** Discover app you will actually demo. Stop.
6. Drop `Start Pinokio Lab.cmd` at the root (below).
7. Smoke-test on a second PC. Expect a slower first launch. GPU apps
   only run if that PC has the GPU. CPU apps still teach.

## Start Pinokio Lab.cmd

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

Drive letter will be D: or E: or F:. `%~d0` follows the stick.

## Skills (in-session)

`/pinokio` — what the lab is, what to install, when to stop.
`/readme` — still the map. Pinokio is a chapter, not the cover.

## Hard limits (say them out loud)

- The **host GPU** is still the host GPU. The stick does not carry a
  video card.
- USB 3 is slower than an internal SSD. First model download is a
  coffee break.
- 256 GB = North Forge + Pinokio + **one or two** apps. Not a zoo.
- Some installers want admin once. After that, the home folder is
  the portable piece.
- Path must not contain spaces. `pinokio-home`, not `Pinokio Home`.

## Credit

Pinokio is MIT, built in public for years by cocktailpeanut and the
Factory reviewers. Completely free. We wrap it. We do not pretend we
wrote it.
