# This is a learning device, not a search box

A general chatbot looks up a page and forgets the shop.
North Forge is supposed to get less wrong the longer it sits on a working PC.

The first week it will miss things. That is expected. An F248 answer that
stops at “print data error” is incomplete until this desk taught it KX vs
V4/IPP, the removal tool, spooler restart, RJ45 out, then U917 before
U021 / U024 Data Only Format. Once that is written down, the next tech
should not have to re-teach it.

What improves is **memory, skills, and the research log** — not the raw
model weights. Say that plainly so nobody thinks the USB is “training a
new brain” overnight.

## Two teachers

| Teacher | What it writes |
|---|---|
| The tech / admin on a live call | The hole, the page, the shop procedure (KX removal, U917, MyQ caveats) |
| Cron research agents | Public industry news only: product launches, firmware notes, forum threads, known-good public KBs |

Cron must **not** scrape private ServiceNow, internal SM PDFs, or customer
data into a public log. Forum talk is rumor until a source is named.

## Agents that should be running (admin PC, network on)

Schedule these in the engine (`/cron add …`). Names can match the skills
already in this pack.

| Job | When | Does |
|---|---|---|
| `nightly-kyocera-research` | daily off-hours | New firmware / product notes, public F-code threads, PaperCut / MyQ public changes |
| `daily-kyocera-brief` | morning | One short brief from last night's log. No essays. |
| `forum-watch` | daily | Copytechnet / public boards — title + link + one-line claim, marked **unverified** |
| `driver-wpp-watch` | weekly | KX vs IPP/WPP / V4 collision notes from public sources |

Leave the gateway or a logged-in session able to run cron on the **admin
PC** (or a lab box that stays on). A teammate stick that is unplugged
overnight will not learn while it is in a drawer. That stick still *keeps*
what was already persisted on it.

## What a tech should hear

“If this is thin, tell me what I missed. I will keep it.”

Not: “I searched the web for you.”
