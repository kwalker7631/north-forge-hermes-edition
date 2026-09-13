# Pinokio on the same drive as North Forge

Pinokio is the free one-click lab: years of work so someone with no
background can stand up local image, voice, and small-model tools.
It is not the desk senior. It is the **sandbox next to the desk**.

Official project: https://github.com/pinokiocomputer/pinokio

## Same-drive layout (256 GB learning stick)

Format this class of stick **NTFS**. Pinokio's notes want NTFS and no
spaces in the home path. The small teammate Excalibur stick stays
exFAT **without** Pinokio.

```
E:\
  Start North Forge.lnk
  Start Pinokio Lab.cmd
  HOW_TO_START.txt
  north-forge-agent\
  north-forge-agent-venv\
  north-forge-agent-data\
  pinokio-home\                 PINOKIO_HOME (no spaces)
  pinokio-app\                  Pinokio.exe
```

First launch: Settings → Home → `<this drive>\pinokio-home`.
A few bytes of “where is home?” may still land in the current user's
AppData. That is a pointer. The models stay on the stick.

## What it is for

Use Pinokio to **see** generation so a Blue Book reader understands
local AI without a lecture. Then go back to North Forge for the call.

| Tool | Job |
|---|---|
| North Forge | The desk. Procedures. Honesty. |
| Pinokio | The lab. Click, install, watch something generate. |

## Deploy

1. Build North Forge first.
2. On a 256 GB NTFS stick, create `pinokio-home` at the root.
3. Unpack Pinokio into `pinokio-app`.
4. Set Home to `pinokio-home` on that drive.
5. Install one Discover app. Stop.
6. Copy `Advanced/deploy-console/Start Pinokio Lab.cmd` to the root.

## Hard limits

- The stick does not carry a GPU.
- USB 3 is slower than an internal SSD.
- 256 GB = North Forge + Pinokio + one or two apps.
- Path must not contain spaces.

Pinokio is MIT, built in public, free. We wrap it. We did not write it.
