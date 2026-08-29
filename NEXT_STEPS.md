# Build Status

## Done
- `.hermes.template.md` - core template (identity, persona, startup routing, universal rules, Hermes-specific memory/skill-lock addendum, mode-aware banner/menu markers)
- `mode-blocks/` - FULL and SALES banner + menu content
- `skills-source/tsc-only/kb-builder/SKILL.md` - full /kb procedure, ported from the v21.8 master
- `skills-source/tsc-only/draft-writer/SKILL.md` - /draft (Draft Writer) procedure: trigger, output contract, context reuse, content scrubbing. Placed 2026-08-28 from a Claude Project chat handoff (byte-for-byte placement, not composed by Claude Code)
- `skills-source/tsc-only/hotline-ticket/SKILL.md` - /hl, /ticket: clipboard-ready HL/ServiceNow ticket-note block. Placed 2026-08-28 from the full-skillset-v3 (reissue) handoff (commit `d414f81`)
- `skills-source/tsc-only/assist-intake/SKILL.md` - /a, /assist (default mode): intake fact set, depth levels, minimum evidence packs, logs-first discipline, enterprise path discipline. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/escalation-packet/SKILL.md` - /esc: structured engineering hand-off packet. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/forge-audit/SKILL.md` - /audit, /chk: finding format + failure taxonomy (Router / Context Handoff / Template / Output Contract / Source Discipline / Hallucination Risk). Placed 2026-08-28 (`d414f81`); folder renamed from `audit/` to `forge-audit/` on 2026-08-28 (`8759d15`) - see QA Finding 1 below. User-facing command still `/audit` or `/chk`
- `skills-source/tsc-only/fault-logging/SKILL.md` - /log, /fault, /report: FORGE FAULT REPORT / EVENT LOG / change-log blocks, persistence-reality rules. Placed 2026-08-28 (`d414f81`)
- `skills-source/tsc-only/training-guide/SKILL.md` - /train, /t: slower guided-explanation mode, deliberate exception to the terse default. Placed 2026-08-28 (`d414f81`)
- `skills-source/shared/web-navigator/SKILL.md` - /web, /links (both modes): direct-link directory for kyoceradocumentsolutions.us (support/downloads, sales/product, proposal/dealer, industry material). Placed 2026-08-28 (`d414f81`). Link accuracy is the author's claim ("verified against the live site") - not re-checked by Claude Code; confirm during QA
- `skills-source/shared/sales-assist/SKILL.md` - scoped and boundary-defined, but NOT yet given real content (FAQ body still a placeholder pending real spec-sheet curation)
- Mode toggle system (`.forge-mode`, `toggle-mode.bat`/`.sh`, launcher assembly logic) - built AND exercised 2026-08-28 QA session: FULL assembles all 10 skills, SALES assembles only the 2 shared, `.hermes.md` banner/menu swap correct, `hermes skills trust` + skin activation work, all artifacts gitignored. See QA notes below.

## Not yet built (do not invent content for these - flag and wait)
- `skills-source/shared/sales-assist/SKILL.md` real content - needs actual spec sheets/datasheets, curated and Blacksmith-approved, not written from general knowledge
- (2026-08-28: the six tsc-only placeholders above - hotline-ticket, assist-intake, escalation-packet, forge-audit, fault-logging, training-guide - plus web-navigator are now all built and placed from the full-skillset-v3 reissue handoff, commit `d414f81`. All 8 tsc-only skills + both shared skills now have real SKILL.md files on disk. Remaining unbuilt item is sales-assist's real FAQ content only.)

## QA session (2026-08-28) - first real run of the built skills + mode toggle

Ran `launch-north-forge.bat` headless in FULL and SALES (audit report at
`audit/CLAUDE_CODE_LAST_AUDIT.md` from that session has the full command
output). Results:

- PASS - FULL assembly: `.hermes/skills/` builds all 10 (8 tsc-only +
  sales-assist + web-navigator); `.hermes.md` ~16,170 chars, correct FULL
  banner/menu, no stray markers.
- PASS - SALES assembly: only the 2 shared skills; SALES banner + reject
  list; `/web` present, FULL-only commands absent.
- PASS - web-navigator URLs: 7 spot-checked (one per section group), all
  HTTP 200, all land where the skill says.
- ~~FINDING 1: the `audit` skill collided with Hermes's reserved
  `hermes skills audit` sub-action and was dropped from `hermes skills list`
  though it assembled/loaded.~~ FIXED 2026-08-28 (`8759d15`): renamed
  `skills-source/tsc-only/audit/` -> `forge-audit/` (content byte-identical),
  updated `.hermes.template.md` (inventory + router) and
  `mode-blocks/full-menu.md` pointer. User-facing `/audit` / `/chk`
  unchanged. Zone B placement from the Claude Project chat.
- ~~FINDING 2: the launchers only checked that `.env` EXISTS, not that
  `ANTHROPIC_API_KEY` was real - a placeholder passed and dropped the user
  into a session that couldn't call a model.~~ FIXED 2026-08-28 (`8759d15`):
  `launch-north-forge.bat` and `.sh` now also reject a missing or
  under-30-char key and reopen the editor with a clear message. Zone A fix.

STILL BLOCKED - QA parts 2 and 4 (exercise each mode live; observe
`decisive_assistant_rule` live): Finding 2 is the reason. This specific fresh
drive has no real Anthropic API key - the repo `.env` holds only the ~13-char
placeholder and Hermes's own `.env` is empty, so `hermes doctor` reports the
`anthropic` provider has no key and can't verify the API. **Kenneth needs to
put a real (spend-capped) Anthropic key on this drive** before the live
mode-exercise can run. After that: either run the 9 modes interactively and
paste transcripts, or (with an explicit spend go-ahead) drive them with
`hermes chat -q "..." -Q --max-turns 3 --run-budget 120` per mode.

Zone B follow-up flagged, not changed: `README.md` L37 still lists the
tsc-only skills as "placeholders" and now also carries the old `audit` name
- a Claude Project chat handoff should refresh that inventory line.

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
- ~~AUDIT 2026-08-26 (pre-flight): `/draft` ("Draft Writer") is referenced in `.hermes.template.md`'s `assistant_router_rule` and listed in `mode-blocks/full-menu.md`, but has no entry in "Not yet built" above, no `skills-source/` folder or placeholder.~~ - RESOLVED 2026-08-28: `skills-source/tsc-only/draft-writer/SKILL.md` placed from a Claude Project chat handoff (see "Done" above). The launcher's `skills-source/tsc-only/.` copy step picks it up in FULL mode alongside `kb-builder`; SALES drives already reject `/draft` via `mode-blocks/sales-menu.md`. FULLY RESOLVED 2026-08-28 by the full-skillset-v3 reissue handoff (commit `d414f81`), which carried the template/menu wiring alongside the six skill files: (A1) `full-menu.md` `/draft` line now has `(see .hermes/skills/draft-writer)`, and a `/web` entry was added to both `full-menu.md` and `sales-menu.md`; (A2) `.hermes.template.md` L26 inventory now lists all 8 tsc-only skills + `sales-assist` + `web-navigator` as built; (A3) L28 rewritten - no longer calls anything a placeholder, kept as a forward-looking safety net; (A4) L70 router line now reads "run Draft Writer (read .hermes/skills/draft-writer in full)"; (A5) new router entries added for hotline-ticket (L66) and escalation-packet (L68); (A6) CLOSED 2026-08-28 (commit `07b1343`): a follow-up `.hermes.template.md` handoff added `(read .hermes/skills/assist-intake in full)` to both Assistant router lines in `<assistant_router_rule>`, matching every other mode's citation pattern; (A7) all six "placeholder" skills now have real `SKILL.md` files on disk. Nothing from Finding A remains open.
- ~~AUDIT 2026-08-26 / 2026-08-28 (Finding B): the default mode is `/assist`, whose skill `assist-intake` was an unbuilt placeholder; and `.hermes.template.md` L7/L50 named `/assist` as the default unconditionally, even on SALES drives that reject it.~~ - FULLY RESOLVED 2026-08-28 (commit `d414f81`): `skills-source/tsc-only/assist-intake/SKILL.md` now exists with real content (intake set, depth levels, evidence packs); L7 is now "DEFAULT MODE: see mode banner below - /assist on FULL drives, /sales on SALES drives" and L50 is likewise mode-aware. Nothing from Finding B remains open. (Prioritization note now moot: all six skills were built together, not one-at-a-time.)
