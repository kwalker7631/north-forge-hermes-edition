---
name: kyocera-research
description: Targeted research pass over public Kyocera resources - firmware notes, known issues, forums - logging only genuinely new findings
cron:
  - name: nightly-kyocera-research
    schedule: "0 6 * * *"
    prompt: "Run the kyocera-research pass"
---
# Kyocera Research Skill

Trigger: invoked by a scheduled /cron job (see setup note at the bottom), or directly if someone asks to "run the research pass" or similar.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## What this actually does

A focused research pass over public Kyocera-related resources, looking for real, source-backed information relevant to field service and TSC work - not a general web crawl, not speculation. Same discipline as everything else in this system: confirmed fact, not invented.

## Where to look

- Kyocera's own public support/documentation (Download Center, service bulletins, release notes)
- Public technician forums and communities where Kyocera field techs discuss real problems
- Firmware release notes for models actively in the field
- Public discussion of HyPAS apps and cloud-connected Kyocera applications (KYOCERA Cloud, and the broader suite of connected apps Kyocera ships) - this space moves fast and documentation lags, so recent forum/community discussion is often more current than official docs

## What counts as a genuine finding (log it) vs. noise (skip it)

Log it if it's:
- A specific, real error code or symptom with a confirmed cause or fix not already in the existing knowledge base
- A firmware/software change with real field-reported impact (a transition, a breaking change, a new requirement)
- A documented workaround for a known issue that isn't yet reflected in official material

Skip it if it's:
- Generic marketing content
- Something already logged in a previous research pass (see continuity note below)
- Unverifiable forum speculation with no corroboration - if it's genuinely uncertain but seems important, log it explicitly labeled as Unverified Field Note (per field_claim_rule), never upgraded to a confirmed fact

## Continuity - do not re-report the same thing every night

This skill is meant to run on a recurring schedule. Before logging a new finding, check research-log/kyocera-research-log.md (create the file and folder if this is the very first run) for whether this exact finding was already logged. Only append genuinely new items. If a prior finding needs correction or an update, note that explicitly rather than silently duplicating it.

## Output format - append to research-log/kyocera-research-log.md

```
## [DATE] - [one-line topic]
Source: [URL or specific named source]
Finding: [what was actually found, in plain language]
Classification: Confirmed Fact / Strong Clue / Working Theory / Unverified Field Note (per field_claim_rule)
Relevance: [why this matters for TSC field work - which mode/skill it might feed into, e.g. kb-builder, assist-intake]
```

This log is a plain git-tracked file, not something living only in Hermes's own session memory - findings here survive a RESET, survive a fresh clone, and are visible to every skill and every technician using this drive, not just whoever happened to be running the session when it was found.

## Setup note (not part of the skill's own behavior - for whoever is reading this to configure the schedule)

As of 2026-09-12 this is automatic: the `cron:` block in this file's frontmatter
(above) is read by `north-forge-agent`'s `scripts/nf_sync_cron.py`, which runs
at every launch and after `nf-setup.ps1` provisioning, on Full and Basic tier
alike - no admin step, no manual `/cron add`, and it survives a HERMES_HOME
flush the same way the old launcher-embedded self-heal used to. It never pins
a model/provider, so the job runs on whatever the drive is already configured
with (the free default on a Basic drive included).

To do it by hand instead (equivalent to what the sync script runs), inside a
live Hermes session:

    /cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research

(Schedule corrected 2026-09-04 with Blacksmith approval: originally "every 24h", which anchors to whenever the job was created and drifts to mid-day runs. Fixed 6 AM gives the 8 AM daily-brief fresh findings to read every morning.)

Check progress any time with `/cron list`. A registered job still only *fires*
while a Hermes gateway process is running for this drive's `HERMES_HOME` - the
sync script now handles that too (12 September 2026): the same
`scripts/nf_sync_cron.py` pass that registers the job also installs and
starts the gateway as a background service (systemd/launchd/Windows
Scheduled Task, whichever this host has) using the same zero-prompt path
`hermes setup` itself relies on, so a teammate closing the terminal doesn't
stop the job from firing. If that install can't complete on a given host (no
supported service manager, a container, a permissions issue), the sync
script's on-screen output says so plainly and falls back to the manual
step: `hermes gateway install` (see `north-forge-agent`'s README, "Gateway
service requirements" section, for exactly what a Windows or Linux host
needs — admin rights, D-Bus/linger — for that install to succeed on its
own). The job's own memory/continuity (a real
Hermes feature as of the v0.21.0 release) helps it avoid re-researching the
same ground twice, on top of this skill's own explicit dedup-against-the-log-file
instruction above - two layers of protection against repeating findings, not
just one.
