# The path we are on now

North Forge is not a second installer and not a second settings app.

The engine is the live `north-forge-agent` fork of Hermes Agent. That
project already installs itself, already has a web dashboard, and already
lets an admin set API keys, pick models, attach skills, and change memory
/ vector settings. We customize that repo. We do not replace it.

## What Hermes already does (use this)

After the stick's own `hermes.exe` is healthy:

    <DRIVE>:\north-forge-agent-venv\Scripts\hermes.exe dashboard

Or the root template `Start-Web-Interface.cmd`.

In that browser UI (Hermes's, not ours):

| Page | Job |
|---|---|
| Env | API keys — save/clear. This is the supported key screen. |
| Models | Which model / provider. |
| Config | Full config, including memory and vector-store choices. |
| Skills | Skills the profile can load. |
| Profiles | Which pack is active (Kyocera, Penny, …). |

Official notes from the chassis `web/README.md`: EnvPage is "API key
management with save/clear." The dashboard talks to the same backend the
CLI uses. A key saved there is supposed to be the same key `hermes config
set` would write under `HERMES_HOME`.

We have not watched a dummy key round-trip in a browser from this chat.
If the Env page saves and `hermes config show` shows the masked key, that
is the proof. Send a screenshot of Env + Models if anything looks off.

## What North Forge still is

The private edition is the **pack**: persona, Kyocera skills, desk modes
(`/hl` `/chk` `/clr` `/fl`), theme, passcode on the stick, drive class.

USB mass-build (format, clone, label `GREGW-NORTH`, lock) stays the
Deploy Console. That is fleet work. It is not how a person picks Claude
vs Grok. That is the dashboard.

## What we will not build

- Another key form in the Deploy Console
- Another model picker
- Another vector-DB UI
- A fork of `web/src` just to hide the Hermes wordmark

Branding: theme + plugins on the existing dashboard. Wordmark stays.

## Admin, first stick, if you are not Kenneth

1. Deploy Console builds the stick (or `hermes` install on a folder if
   you are not making a USB).
2. Start North Forge once. Wait for `ready`.
3. Start Web Interface — **or** stay in the CLI and use Set-Inference.ps1.
   Both write the same `HERMES_HOME`.
4. Env page: paste the key. Models page: pick the model.
5. Skills / Profiles: confirm Kyocera is the landing pack.
6. Close the browser. Terminal is still the desk for a technician.

If the dashboard will not start on an exFAT stick (no junctions for
`npm` rebuild), the CLI path is the fallback. You do not reformat for that.

## Security work from the last three days

Stays. Passcode hash, no hardcoded gate, PATH check, RAW disk, buried
admin folder pointer. None of that is a second product. It is how the
pack sits on a stick on top of Hermes.
