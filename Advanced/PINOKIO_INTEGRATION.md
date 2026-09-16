# Pinokio integration (exploration)

Fleet sticks still do **not** install Pinokio. This page is how the two
products can cooperate later without becoming one binary.

Official: https://pinokio.co/docs  
Scripts: JSON-RPC (`shell.run`, `script.start`, `web.open`, …)  
Home: one folder (`api`, `bin`, `drive`, `cache`) on Win / macOS / Linux.

## What integration is not

- Not a Hermes skill that downloads 30 GB of weights onto GREGW-NOREX.
- Not embedding Electron inside `hermes dashboard`.
- Not sharing SOUL.md or the Kyocera well with a Comfy graph.
- Not dual-boot or a second partition on BLACK-NORTH.

North Forge owns tickets. Pinokio owns local generation. A link and a
folder path are the joint.

## Four depths (stop at the first that earns its keep)

| Depth | What | When |
|---|---|---|
| **0. Docs + screenshots** | Current state. PINOKIO.md downloads. | Now |
| **1. Launch sidecar** | `Start Pinokio Lab.cmd` / `.sh` / `.command` if `Pinokio.exe` or AppImage exists on *another* disk. Hermes `/dash` stays Hermes. | First optional |
| **2. Recommend, don't install** | `daily-brief` or a workshop cron lists 1–2 Discover apps. Human clicks in Pinokio. | Designer lab |
| **3. Pinokio script in `api/`** | A small `north-forge-lab.json` that `script.start`s one known image app. Lives in *their* `pinokio-home`, not in our pack. | After someone used depth 1 |
| **4. Shared dashboard** | Hermes page that iframes Pinokio or writes recommendations into both. | Do not start |

## Depth 1 — detect, don't bundle

```text
IF exists <otherDisk>/pinokio-app/Pinokio.exe     → Windows start
IF exists /Applications/Pinokio.app               → macOS open
IF exists ~/Pinokio*.AppImage                     → Linux
ELSE → print PINOKIO.md download table
```

Hermes skill `pinokio` already in the pack can stay as *help text*.
Zero-Touch must keep excluding it from teammate sticks.

## Depth 3 — what a script looks like (theirs, not ours)

Pinokio scripts are JSON. Cross-platform via `{{platform}}` / kernel.path.
A lab script would `script.start` a published app URI, then `web.open`
the local port. Weights land under *their* `pinokio-home/drive` (dedup).
Our repo does not vendor those URIs until a Blacksmith picks one demo app.

## Research loop (the Chrome idea)

Hermes cron + `web_search` on BLACK-NORTH (see RESEARCH_AGENT.md) drafts
"what is trending." Output is markdown in the well. A designer reads it
and, if they have Pinokio installed, tries one app. No Chrome extension
required for v1. Chrome/Playwright exists *inside Pinokio's kernel* if a
script needs a browser — that is their stack, not ours.

## Platform

Same integration story on Windows, macOS, Linux: detect binary, else link.
exFAT fleet volume stays North Forge only. Pinokio home, if any, is NTFS
or APFS on the machine that runs the lab.

## Stop condition

If depth 1 is not used in 30 days of Greg being live, do not build 2–4.
