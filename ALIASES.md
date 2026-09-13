# Slash shortcuts

Type the short or the long form. Same job.

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
| `/web` | `/links` | Official pages |
| `/fl` | `/flush` `/clr` | Drop this ticket, **stay** in the same job |
| `/switch` | | Drop this ticket **and** go back to the menu |

## Do not confuse these two

| You type | What actually happens |
|---|---|
| `/fl` `/flush` `/clr` | Our reset. This call is gone. You stay in `/hl` or `/assist`. |
| `/clear` or `/reset` | **Hermes native.** Wipes the whole chat. Not our ticket flush. |

If someone types `/clear` and they meant the next hotline call, say so:
that was an engine wipe. Next time use `/fl` or `/clr`.

Hermes only registers one official slash `name` per skill (`hl`, `kb`,
`audit`, `flush`…). The long forms work because the skill text and this
list tell the model they are the same job. Keep this file and `/menu` in
sync when you add a command.
