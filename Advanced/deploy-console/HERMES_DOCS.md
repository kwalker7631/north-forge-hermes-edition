# Engine manual (Nous — not us)

Canonical: https://hermes-agent.nousresearch.com/docs/

Index for any "can Hermes do X?":
https://hermes-agent.nousresearch.com/docs/llms.txt

Full dump: https://hermes-agent.nousresearch.com/docs/llms-full.txt

North Forge docs cover the pack, the stick, and the room. They do not
replace this site. If a page here and a page on nousresearch.com disagree
about *Hermes*, theirs wins.

## Use these pages; do not rebuild them

| Job | Official page |
|---|---|
| Install (PC, not our USB) | /docs/getting-started/installation |
| First chat | /docs/getting-started/quickstart |
| Models / providers | hermes model — /docs/user-guide/configuration |
| Web UI keys + skills | /docs/user-guide/features/web-dashboard |
| Many keys, rotate when one dies | /docs/user-guide/features/credential-pools |
| 300+ models, one login | /docs/integrations/nous-portal |
| Slash commands | /docs/reference/slash-commands |
| Bundled skills (the 50+) | skills catalog on that site |
| Telegram / Discord / … | /docs/integrations/ |

Dashboard Env **is** the API-key screen. Documented. Models page is the
engine picker. That is why we stopped drawing a second settings app.

Credential pools are the official name for "I keep five or six keys and
switch when one burns." Hermes can rotate them when a quota dies. That
is the auto-switch you asked for — already in the engine. Wire it later
on BLACK-NORTH. Do not write a plugin that duplicates `hermes auth add`.

Nous Portal (`hermes setup --portal`) is their recommended path: one
OAuth, large catalog, Tool Gateway. Compatible with a 30-day burner
mindset (subscription minutes, then free/local). Optional for Greg.
Anthropic key on the stick remains the production default we chose.

## Do not run their one-liner on the stick

```
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

That installer is for a PC home directory (`~/.hermes`). Our USB already
has a venv + `HERMES_HOME` on the volume. Their script would fight
isolation. Use Deploy Console / Start North Forge instead.

`hermes update` on a stick will pull upstream skills into the profile.
That is how 200 extras arrive. Keep `hermes-extra` off Greg unless you
promote a name onto tsc-core.
