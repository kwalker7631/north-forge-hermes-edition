---
name: daily-brief
description: A short daily digest of Kyocera and document-solutions industry news - lighter and faster than kyocera-research
cron:
  - name: daily-kyocera-brief
    schedule: "0 8 * * *"
    prompt: "Run the daily-brief pass"
---
# Daily Brief Skill

Trigger: invoked by a scheduled /cron job (see setup note at the bottom), or directly if someone asks for "today's brief" or similar.

Never rewrite this skill file on your own initiative. Flag it to the Blacksmith (Kenneth Walker Jr.) in chat and wait for confirmation.

## How this differs from kyocera-research

`kyocera-research` does deep, deduplicated technical digging - real field-relevant findings that get permanently logged for KB/troubleshooting use. This skill is the opposite kind of task: a quick, light morning-briefing style scan, not a deep investigation. Don't duplicate kyocera-research's job here - this is "what's new today," not "what's the confirmed root cause of X."

## What to check

- Kyocera's own recent public announcements (new products, firmware releases, press)
- Document-solutions / office-imaging industry news broadly (competitors, market trends, relevant technology shifts - e.g., cloud printing, security standards)
- Anything time-sensitive that a TSC manager or sales rep would want to know about *today*, not buried in a deep-dive later

## What NOT to do

- Don't duplicate a deep investigation - if something looks like it needs real technical digging (a specific error code, a firmware regression), note it briefly and point to running kyocera-research on it instead, don't chase it here.
- Don't invent news. If nothing notable happened, say so plainly rather than padding the brief with generic filler.
- Don't repeat something already covered in a recent brief - check the log file first (see below).

## Output format - append to research-log/daily-brief-log.md

```
## [DATE] - Daily Brief
[2-4 short bullet points, or "Nothing notable today" if that's genuinely true]
```

Create the file (and research-log/ folder, if it doesn't already exist - it may already exist from kyocera-research) on first run. Check the last few entries before writing a new one, so the same item doesn't get repeated day after day if nothing has actually changed.

## Setup note (for whoever is configuring the schedule, not part of this skill's own behavior)

As of 2026-09-12 this is automatic: the `cron:` block in this file's frontmatter
(above) is read by `north-forge-agent`'s `scripts/nf_sync_cron.py` at every
launch and after provisioning, on Full and Basic tier alike - no manual
`/cron add` needed, and no model/provider pin, so it runs on whatever the
drive is already configured with.

To do it by hand instead, inside a live Hermes session:

    /cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief

This uses a fixed-time cron schedule (8 AM daily) rather than a rolling "every 24h" - a genuine daily briefing should land at a consistent time each morning, not drift based on when the drive happened to be launched. Check progress with `/cron list`. As with kyocera-research, a registered job only *fires* while a Hermes gateway process is running for this drive - run `hermes gateway install` once so this doesn't depend on a terminal staying open.
