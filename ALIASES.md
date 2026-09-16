# Slash shortcuts

Type the short or the long form. Same job — except `/clr` and `/fl`.
Those two are different on purpose.

| Short | Also | Job |
|---|---|---|
| `/a` | `/assist` | Coach the tech |
| `/hl` | `/hotline` `/ticket` `/wako` | Write the SN / HL ticket |
| `/kb` | `/k` `/knowledgebase` `/knowledge` | KB draft |
| `/esc` | `/escalate` `/escalation` | Escalation packet |
| `/log` | `/fault` `/report` | Fault record |
| `/chk` | `/check` `/audit` | Look it up; if they handed a draft, audit it |
| `/draft` | `/email` | Customer / callback wording |
| `/menu` | `/help` | Command list |
| `/train` | `/t` | New-hire path |
| `/web` | `/links` | Official vendor pages (not the dashboard) |
| `/dash` | `/ui` `WAC web` | Hermes dashboard — keys, models, credits |
| `/clr` | `/flush` | Drop **this ticket only**. Mode stays (`/hl` stays `/hl`). |
| `/fl` | `/switch` | Reset the **whole North Forge skill session**. Default mode + menu. |

## Three resets. Do not mix them.

| You type | What dies | What lives |
|---|---|---|
| `/clr` `/flush` | This ticket / this section | Mode, menu choice, Hermes chat |
| `/fl` `/switch` | All North Forge working state (tickets, mode, theories) | The Hermes chat window itself |
| `/clear` `/reset` | **Hermes native.** The whole chat | Nothing in this window |

`/fl` is our `/clear` — for the North Forge skill session only.
It does not call Hermes `/clear`. If they also want the raw chat gone,
they type Hermes `/clear` on purpose.

Between hotline calls use `/clr`. When the desk is starting over, `/fl`.
