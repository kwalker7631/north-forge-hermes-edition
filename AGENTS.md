# AGENTS.md - North Forge Hermes Edition - Codex Working Rules

Scope: this file governs Codex sessions run inside this repo
(`north-forge-hermes-edition`). It is the Codex-equivalent of `CLAUDE.md`,
which governs Claude Code sessions in this same repo. The two files are
deliberately kept aware of each other (see "Relationship to CLAUDE.md"
below) rather than existing as silently parallel, possibly-drifting rule
sets that nobody has to reconcile.

Note on Hermes's own context-file discovery: Hermes reads `.hermes.md` (if
present) before `AGENTS.md` before `CLAUDE.md`, first match wins. Since
`.hermes.md` is generated fresh at every launch, Hermes itself will never
actually load this file either - it's for Codex only, the same way
`CLAUDE.md` is for Claude Code only.

## Why this file exists

A prior Codex session made a real, correct code fix in this repo (the
HERMES_HOME drive-write-probe fix in `launch-north-forge.sh`) but never
produced or committed a report describing it - no `audit/CODEX_*.md` file,
no explanation of what was found or why the fix was made. The change sat in
the working tree uncommitted with only an in-code comment ("see audit")
pointing at a report that did not exist. A later Claude Code session had to
reverse-engineer the reasoning from the diff alone before it could safely
build on it, and had no way to independently confirm what Codex had and
hadn't already verified. That gap is what this file closes: not by asking
nicely next time, but by making the report a structural requirement of what
"done" means for a Codex session here.

## Mandatory audit report - hard requirement, no exceptions

1. **Every Codex session that reads or modifies this repository MUST write
   a report to `audit/CODEX_<short-topic>_<YYYY-MM-DD>.md` before the
   session is considered complete.** This applies with no exceptions,
   including a session that makes no code changes at all - a "found
   nothing," "investigation only," or "confirmed existing behavior is
   correct" session still produces a written report. A session that read or
   touched this repository and produced no report is not a complete
   session, regardless of what else it accomplished.
2. **The report must be committed in the same commit(s) as any code changes
   it describes.** A session is NOT complete if code changed but the report
   describing that change wasn't committed alongside it. Do not treat
   "I'll write the report next time" or "the report is implied by the diff"
   as satisfying this - the report is a separate, required artifact, not a
   restatement of the commit message.
3. **Report structure should match the existing reports already in
   `audit/`** (see `audit/CODEX_SECOND_AUDIT_2026-09-05.md` and
   `audit/HERMES_CRON_GATEWAY_HOME_AUDIT.md` for examples already in this
   repo). At minimum: what was requested, files inspected, findings (with
   severity where applicable - HIGH/MEDIUM/LOW or equivalent), verification
   actually performed (empirical - what was run and what it showed - not
   just asserted from reading code), and a clear status line at the end.
4. **If asked to investigate a tradeoff or design decision** (e.g. "is X
   isolated or shared, and what's the cost either way," "why does this use
   approach A instead of B") **the investigation and its conclusion must be
   written into the report explicitly**, not left implicit in the resulting
   code alone. Code shows what was decided; it doesn't show what was
   considered and rejected, or why. A session that reasons through a
   tradeoff and then only changes code has thrown away half of what makes
   the session useful to whoever reads the report next.

A session that makes no repository changes still writes a report under the
same naming convention - use a topic that reflects what was actually
investigated (e.g. `audit/CODEX_HERMES_HOME_ISOLATION_2026-09-06.md`), not a
generic placeholder name.

## Relationship to CLAUDE.md

`CLAUDE.md` (repo root) governs Claude Code sessions in this same
repository and defines a zone-based authority model (Zone A: infrastructure
Claude Code may fix directly; Zone B: authored field-support/documentation
content that's read-only to Claude Code; Zone C: operational status docs).
Codex's own past audit reports in this repo already reason about and
respect that same zone model in practice (see, for example,
`audit/CODEX_SECOND_AUDIT_2026-09-05.md`'s "Zone A / Zone B boundary
assessment" section). This file does not restate those zone definitions -
`CLAUDE.md` is the single source of truth for them, so a future change to
the zone boundaries only has to happen in one place. If Codex is uncertain
whether a file it's about to touch is authored field-support content (Zone
B in `CLAUDE.md`'s terms) versus infrastructure, read `CLAUDE.md`'s zone
lists rather than guessing, and say so explicitly in the audit report if the
answer wasn't clear from that file alone.
