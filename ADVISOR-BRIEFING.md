# North Forge — Advisor Briefing

*Paste this whole file into any AI tool (Grok, ChatGPT, Gemini, etc.) to get
useful analysis or suggestions with no other context needed. Last updated
2026-09-14 — kept current at the end of significant sessions.*

## What this is

North Forge is a personal AI-agent system built on Hermes Agent, split into
two repos: a public **chassis** (`north-forge-agent` — the engine, generic
skills, tiering/provisioning) and a private **content layer**
(`north-forge-hermes-edition`, this repo, callsign "kyocera") with
field-support/business-specific skills, layered in via
`private-editions/kyocera`. A deployment clones both, bootstraps a Python
venv, and provisions a pinned edition onto a drive.

## Current state (what's genuinely open right now)

- **Working:** the full deploy path — clone, bootstrap, provision, pin an
  edition, install its skills — is live-verified end to end as of today.
  The admin/designer's own drive is real and provisioned Full-tier
  ("Excalibur" as of the 2026-09-14 rename — the locked teammate-handoff
  drive this project previously called that is now "Round Table"; nothing
  about either drive changed, only the names).
- **Open, needs a human decision, not urgent:** 9 of 12 tests in this repo
  fail (`FileNotFoundError`) because they still check for a standalone
  launcher that was intentionally retired; a few admin-facing docs
  (`USER_MANUAL.md`, `FIRST_TIME_README.txt`, `WELCOME.html`,
  `skills/menu/SKILL.md`) still describe that retired install path and need
  an author's rewrite, not a code fix. Also open: `CLAUDE.md`'s own Zone A
  file list still names several launcher-era files by their old root-level
  paths (`launch-north-forge.bat/.sh`, `toggle-mode.bat/.sh`,
  `machine-reset.bat`, `provision-new-drive.ps1`, `full-drive-reset.bat/.sh`)
  that no longer exist there — most were archived under
  `archive/legacy-standalone-launcher/`, and `machine-reset.bat` now lives
  at `Advanced/machine-reset.bat` — but `CLAUDE.md` is Zone B (author-only),
  so Claude Code can flag this, not fix it.
- **New this week, still settling:** the admin/designer drive moved to a
  genuinely new machine (not just a re-lettering) — provisioning survived
  the move intact and is independently re-verified, but a re-provisioning
  passcode fix that came out of that move is committed and reviewed, not yet
  confirmed working against a real drive (a Claude Code safety classifier
  has blocked the live test twice). Full detail in the sibling
  `north-forge-agent` repo's own audit log, cross-referenced from this
  repo's `CHANGELOG.md`.
- **Do not worry about:** a known, accepted, time-boxed secret-exposure risk
  in the public chassis repo (owner-decided, already mitigated, intentionally
  left as-is); ~30 historical session reports lost in an unrelated drive
  wipe (disclosed, not a current bug).

## Your role, stated as fact

You are being consulted for analysis, review, and suggestions only. You do
not have write access to this repository and must not attempt to commit,
push, or modify anything here. Write your findings as plain text; a human
will relay anything worth acting on to Claude Code, which is the sole
authority for implementing changes in this project.

## The bar for a useful suggestion right now

This project is past the rough-build stage. What's valuable now is the final
polish pass — the equivalent of adding skin texture and pores to a sculpture
that's already anatomically correct, not reshaping the sculpture.
Concretely: visual/UI refinement (e.g., a tool that's especially strong at
interface design suggesting a specific improvement to an existing screen),
small UX friction points, wording/clarity issues, things that make an
already-working system feel more finished — not structural changes, not new
architecture, not "have you considered rebuilding X differently."
