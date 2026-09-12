---
name: kyocera-research
description: Targeted research pass over public Kyocera resources - firmware notes, known issues, forums - logging only genuinely new findings
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

Inside a live Hermes session, run:

    /cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research

(Schedule corrected 2026-09-04 with Blacksmith approval: originally "every 24h", which anchors to whenever the job was created and drifts to mid-day runs. Fixed 6 AM gives the 8 AM daily-brief fresh findings to read every morning.)

Check progress any time with `/cron list`. The job's own memory/continuity (a real Hermes feature as of the v0.21.0 release) helps it avoid re-researching the same ground twice, on top of this skill's own explicit dedup-against-the-log-file instruction above - two layers of protection against repeating findings, not just one.
