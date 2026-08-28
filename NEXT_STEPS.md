# Build Status

## Done
- `.hermes.template.md` - core template (identity, persona, startup routing, universal rules, Hermes-specific memory/skill-lock addendum, mode-aware banner/menu markers)
- `mode-blocks/` - FULL and SALES banner + menu content
- `skills-source/tsc-only/kb-builder/SKILL.md` - full /kb procedure, ported from the v21.8 master
- `skills-source/tsc-only/draft-writer/SKILL.md` - /draft (Draft Writer) procedure: trigger, output contract, context reuse, content scrubbing. Placed 2026-08-28 from a Claude Project chat handoff (byte-for-byte placement, not composed by Claude Code)
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
- ~~Upload `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` into this repo's root~~ - DONE: file is present at the repo root and tracked in git (commit `e7beb1f`). Confirmed 2026-08-26 audit.
- Decide whether `CLAUDE.md` (for Claude Code, same working directory) should mirror `.hermes.template.md`'s output or stay separate
- ~~Confirm `kwalker7631/north-forge-agent` is a registered GitHub fork of NousResearch/hermes-agent so `gh repo sync` works for engine updates~~ - DONE: verified via `gh repo view` on 2026-08-26 - `isFork: true`, parent `NousResearch/hermes-agent`, default branch `main`. `gh repo sync` path is valid.
- Live-test the /flush + memory-scrubbing interaction described in the Hermes addendum - this hasn't been run against Hermes's actual memory writes yet, only specified
- ~~Live-test the mode toggle end to end~~ - DONE: confirmed the launcher correctly builds separate FULL/SALES skill sets. Folder-name bug found and fixed (was `skills/`, corrected to `.hermes/skills/` after reading actual source); trust gate found and auto-approval added to the launcher.
- Decide how FULL-mode drives (TSC) vs. SALES-mode drives (reps) actually get distributed/built - e.g. does Kenneth set `.forge-mode` once per physical drive before handing it out, or is there a simpler batch process for provisioning many drives at once
- If/when local Llama (via Docker) gets wired in as a provider option: confirm the container's endpoint, port, and model name, and decide whether a large reference-docs folder for PDF research lives on the drive outside the git repo (large binaries don't belong in git)
- Confirm a real `/kb` draft actually renders correctly now that the locked HTML template has been added to the repo root
- `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md` added (2026-08-26) - complete standalone paste-in version for disaster recovery. Keep it manually in sync with `.hermes.template.md`/`skills-source/` when either changes; nothing auto-generates one from the other.
- ~~AUDIT 2026-08-26 (pre-flight): `/draft` ("Draft Writer") is referenced in `.hermes.template.md`'s `assistant_router_rule` and listed in `mode-blocks/full-menu.md`, but has no entry in "Not yet built" above, no `skills-source/` folder or placeholder.~~ - RESOLVED 2026-08-28: `skills-source/tsc-only/draft-writer/SKILL.md` placed from a Claude Project chat handoff (see "Done" above). The launcher's `skills-source/tsc-only/.` copy step picks it up in FULL mode alongside `kb-builder`; SALES drives already reject `/draft` via `mode-blocks/sales-menu.md`. STILL OPEN (Zone B, not changed by Claude Code) - "finish wiring draft-writer into the template/menu prose", one coherent edit for the Blacksmith / Claude Project chat: (A1) `mode-blocks/full-menu.md` L5 `/draft` entry lacks a `(see .hermes/skills/draft-writer)` pointer like every other skill-backed line has; (A2) `.hermes.template.md` L26 skill inventory omits `draft-writer` - it is built, belongs next to `kb-builder`, not among the placeholders; (A3) `.hermes.template.md` L28 "Skills beyond kb-builder are staged as placeholders" is now inaccurate - `draft-writer` is also built; (A4) `.hermes.template.md` L66 `<assistant_router_rule>` Draft Writer line does not name its skill file to read, unlike the KB Builder / Auditor / Training Guide / Fault Report lines. See `audit/CLAUDE_CODE_LAST_AUDIT.md` (2026-08-28 audit pass) for full quotes plus pre-existing findings A5-A7 (router rule has no natural-language routing for `/hl` or `/esc`; `/assist` menu pointer unused by router rule; "placeholder" skills have no file on disk at all).
- AUDIT 2026-08-26 (pre-flight): the default mode is `/assist` (`.hermes.template.md`: "DEFAULT MODE: /assist"), whose skill `assist-intake` is still an unbuilt placeholder. The template carries an inline minimum-evidence prompt so `/assist` degrades gracefully, but a freshly provisioned drive lands the user in a mode with no skill file behind it. Noted for demo awareness; not a blocker.
  - AUDIT 2026-08-28 (fresh read, confirmed): still open. `assist-intake` has no folder or file in `skills-source/` at all (not even an empty placeholder). It is the ONE unbuilt skill on the default / always-hit path - the other five are only reached on explicit invocation - so it arguably has an equal claim to "build next" as `fault-logging` (`DEMO_PREP_BACKLOG.md` item 2). Blacksmith prioritization call. Also new this pass: `.hermes.template.md` L7 "DEFAULT MODE: /assist" and L50 "ready for /assist" are static (not inside `{{MODE_BANNER_BLOCK}}`/`{{COMMAND_MENU_BLOCK}}`), so a SALES drive ships a template naming `/assist` as default even though `sales-menu.md` L6 rejects `/assist`. Consider mode-qualifying L7/L50 or having `sales-banner.md` set the SALES default explicitly. Full detail in `audit/CLAUDE_CODE_LAST_AUDIT.md`.
