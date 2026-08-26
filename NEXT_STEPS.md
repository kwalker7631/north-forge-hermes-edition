# Build Status

## Done
- `.hermes.template.md` - core template (identity, persona, startup routing, universal rules, Hermes-specific memory/skill-lock addendum, mode-aware banner/menu markers)
- `mode-blocks/` - FULL and SALES banner + menu content
- `skills-source/tsc-only/kb-builder/SKILL.md` - full /kb procedure, ported from the v21.8 master
- `skills-source/shared/sales-assist/SKILL.md` - scoped and boundary-defined, but NOT yet given real content
- Mode toggle system (`.forge-mode`, `toggle-mode.bat`/`.sh`, launcher assembly logic) - built but not yet tested on a real Hermes session

## Not yet built (do not invent content for these - flag and wait)
- `skills-source/tsc-only/hotline-ticket/` - /hl, /ticket
- `skills-source/tsc-only/assist-intake/` - /a, /assist and minimum evidence packs
- `skills-source/tsc-only/escalation-packet/` - /esc
- `skills-source/tsc-only/audit/` - /audit, /chk, including context_handoff_failure_rule taxonomy
- `skills-source/tsc-only/fault-logging/` - /log, /fault, /report and change/event log procedure
- `skills-source/tsc-only/training-guide/` - /train
- `skills-source/shared/sales-assist/SKILL.md` real content - needs actual spec sheets/datasheets, curated and Blacksmith-approved, not written from general knowledge

## Also outstanding
- Upload `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` into this repo's root (currently only in the Claude Project's knowledge base)
- Decide whether `CLAUDE.md` (for Claude Code, same working directory) should mirror `.hermes.template.md`'s output or stay separate
- Confirm `kwalker7631/north-forge-agent` is a registered GitHub fork of NousResearch/hermes-agent so `gh repo sync` works for engine updates
- Live-test the /flush + memory-scrubbing interaction described in the Hermes addendum - this hasn't been run against Hermes's actual memory writes yet, only specified
- Live-test the mode toggle end to end: confirm a SALES-mode drive actually can't produce KB/hotline/escalation output, and that project-skill discovery correctly picks up the assembled `skills/` folder (see the open question about the exact discovery path noted earlier)
- Decide how FULL-mode drives (TSC) vs. SALES-mode drives (reps) actually get distributed/built - e.g. does Kenneth set `.forge-mode` once per physical drive before handing it out, or is there a simpler batch process for provisioning many drives at once
- If/when local Llama (via Docker) gets wired in as a provider option: confirm the container's endpoint, port, and model name, and decide whether a large reference-docs folder for PDF research lives on the drive outside the git repo (large binaries don't belong in git)
