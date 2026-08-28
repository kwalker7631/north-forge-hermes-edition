# Claude Code Session Audit

Timestamp: 2026-08-28
Requested task: Kenneth handed over `north-forge-hermes-draft-writer.zip`
(from the Claude Project chat) for placement of a single Zone B file,
`skills-source/tsc-only/draft-writer/SKILL.md` - the `/draft` (Draft Writer)
skill that resolves the "/draft untracked / no skill folder" gap flagged in
the last two audits. Task: extract into repo root, verify coherence, commit +
push, then update `NEXT_STEPS.md` (Zone C) to mark `/draft` as built.

## Files inspected
- `north-forge-hermes-draft-writer.zip` (`C:\Users\kwalk\Downloads\`) -
  listed without extracting, then extracted to a scratchpad first for
  inspection. 2 entries only: `skills-source/tsc-only/draft-writer/` (dir)
  and `skills-source/tsc-only/draft-writer/SKILL.md` (2045 bytes). No `../`
  path traversal, no absolute paths, no symlinks, no dotfiles, no
  executables, nothing outside the one intended skill folder.
- `skills-source/tsc-only/draft-writer/SKILL.md` (the handoff file) - full
  read.
- `skills-source/tsc-only/kb-builder/SKILL.md` - full read, as the sibling
  skill to compare structure/voice against.
- `.hermes.template.md` - `/draft` router lines (grep).
- `mode-blocks/full-menu.md`, `mode-blocks/sales-menu.md` - `/draft` lines
  (grep).
- `launch-north-forge.sh` / `launch-north-forge.bat` - skill-assembly logic
  (grep): FULL mode copies `skills-source/tsc-only/.` into `.hermes/skills/`.
- `NEXT_STEPS.md` - full read (Zone C, edited this session).
- `.gitignore` - full read; confirms `skills-source/` is source, not
  ignored; `/.hermes/` + `.hermes.md` build artifacts stay ignored.
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (previous) - full read.
- `hermes doctor` + `hermes skills list --source local`.

## Coherence check (what "verify it's coherent" covered)
- Placement path correct: `skills-source/tsc-only/draft-writer/SKILL.md`
  matches the folder pattern of `kb-builder`; the launcher's
  `skills-source/tsc-only/.` copy step (sh L42 / bat L23) picks it up
  automatically in FULL mode. Correctly `tsc-only` - `mode-blocks/sales-menu.md`
  already lists `/draft` in the SALES reject list.
- Trigger alignment: SKILL.md trigger ("/draft or /d, or a request for an
  email, customer update, internal message, ServiceNow note, escalation
  note, or live chat wording") matches `.hermes.template.md` L66 and
  `mode-blocks/full-menu.md` L5.
- Output contract matches the `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md`
  "Draft Writer" contract (audience-ready prose; preserve facts/uncertainty;
  no KB-only drafting scaffolding; no HTML unless requested).
- Structure/voice consistent with `kb-builder/SKILL.md`: same "Trigger:"
  opener, same "Never rewrite this skill file on your own initiative - flag
  it to the Blacksmith" self-lock line, same content-scrubbing standard
  (explicitly defers to kb-builder's). Shorter than kb-builder, which is
  appropriate for the lighter task.
- No prompt-injection or instruction content aimed at Claude Code; it reads
  as authored field-support content for the Hermes agent.
- sha256 of placed file == sha256 of the file inside the zip:
  `c259df12047d2fa1010753df9198761393b4bf5a1abdf8ca1765a258cc73a2d0`.
  Byte-for-byte placement; nothing composed, rephrased, or extended.

## Zone A changes made
None to infrastructure/scripts. This audit file (itself Zone A) written to
record the session. Commit hash in `git log`.

## Zone B changes made (placement exception - not authoring)
- `skills-source/tsc-only/draft-writer/SKILL.md` - NEW. Placed byte-for-byte
  from `north-forge-hermes-draft-writer.zip`, an in-session named handoff
  from Kenneth identified as originating from the Claude Project chat, with
  an instruction to commit. This is the CONFIRMED (2026-08-26) placement
  trigger. Claude Code did not write or modify any of its content.

## Zone B findings (not fixed - reported only)
- `mode-blocks/full-menu.md` L5: the `/draft or /d` menu entry still has no
  `(see .hermes/skills/draft-writer)` pointer, where the `/kb` entry on L4
  has `(see .hermes/skills/kb-builder)`. Now that the skill folder exists,
  adding the matching pointer would make the menu internally consistent.
  Zone B - left for the Blacksmith / Claude Project chat. Recorded in
  `NEXT_STEPS.md` under the now-resolved `/draft` audit note.

## Zone C changes made
- `NEXT_STEPS.md`: added `draft-writer/SKILL.md` to the "## Done" list;
  converted the 2026-08-26 pre-flight `/draft` gap note to RESOLVED, keeping
  only the one still-open sub-point (the full-menu.md pointer, above).

## Commits made this session
[filled in git log - 3 commits: (1) place draft-writer skill, (2) NEXT_STEPS
Zone C update, (3) this audit report]

## Uncertain / flagged for primary GPT review
- The `draft-writer/SKILL.md` folder was already present in the working tree
  (untracked, timestamped 19:07 today, identical hash to the zip) when the
  session started - i.e. someone had already extracted the zip into the repo
  root before Claude Code ran. Claude Code re-extracted it idempotently to
  satisfy the literal instruction and hash-verified it against the zip. No
  discrepancy, but noting that the "extract" step was partly already done.
- Off-path items unchanged from prior audits: `hermes` behind upstream;
  SQLite 3.45.1 WAL-reset bug still the only `hermes doctor` warning.
- `hermes skills list --source local` shows only `kb-builder` +
  `sales-assist` because `.hermes/skills/` is assembled at launch and the
  launcher was not run this session. `draft-writer` will appear there after
  the next FULL-mode launch. Not a defect.

## Status
Clean. One Zone B file placed under the confirmed handoff/placement
exception (byte-for-byte, hash-verified); one Zone C doc updated to match.
One Zone B consistency finding (full-menu.md pointer) reported, not touched.
