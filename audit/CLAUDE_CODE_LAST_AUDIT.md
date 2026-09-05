# Claude Code Session Audit

Timestamp: 2026-09-05 (session following the Codex-audit-response/reconciliation
session recorded in the prior version of this file)
Requested task: "Add the standing testing-safety rule to CLAUDE.md (or
wherever session-process guidance lives): never shadow a real system command
via PATH manipulation for verification... Reference this session's own
incident (real hermes config mutated twice via a PATH-shadow attempt that
bash's command-hash cache defeated) as the concrete reason."

## Files inspected

- `CLAUDE.md` (full re-read of the Zone A/B/C rules, the handoff-exception
  mechanism, and the two prior STANDING RULE precedents, to determine
  whether this request qualifies)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior version, read at session start per
  the Session Start Protocol - this is where the referenced PATH-shadow
  incident is actually documented, under "Uncertain / flagged for primary
  GPT review", item 1)
- `.gitignore` (session-start confirmation - unchanged, still correctly
  excludes `.env`, `.forge-mode`, `.hermes.md`, `/.hermes/`)
- `git status` / `git diff` / `git pull` (clean, up to date, nothing
  uncommitted at session start)

## Zone A changes made

None. This session made no code/script changes.

## Zone B findings (not fixed - reported only)

**`CLAUDE.md` itself - requested edit declined per its own rules.** The
requested change (add a new standing testing-safety rule/section to
`CLAUDE.md`) is a Zone B edit. `CLAUDE.md` explicitly lists itself as Zone B
and states the only valid trigger for Claude Code to place new content there
is "an in-session named handoff from Kenneth - identifying a specific Zone B
file, including CLAUDE.md itself, as originating from the Claude Project
chat, with an instruction to commit it" (CONFIRMED 2026-08-26 entry). This
request did not identify the content as originating from the Claude Project
chat - it asked Claude Code to compose and place the rule directly from this
session's own reasoning about a past incident. That is precisely the
"broad instruction does not extend into Zone B... not even when explicitly
asked to 'fix any issues'" case the file itself warns about, so I did not
edit `CLAUDE.md`.

Separately, a factual correction on the request's own framing: the
PATH-shadow/hermes-config-mutation incident happened in the **prior**
session (documented in the previous version of this audit file, under
finding NF-CX-03's verification section and the "Uncertain / flagged" item
1), not in "this session" - this session made no `hermes` calls of that
kind at all (only the read-only `hermes doctor` / `hermes skills list`
required by the Session Start Protocol). Naming it accurately matters if
this text is going to be quoted verbatim into a permanent rule.

I drafted the proposed rule text (reproduced below, not placed into
`CLAUDE.md`) so Kenneth can carry it into the Claude Project chat for
official authoring, or explicitly declare this exact text a handoff from
that chat if he wants it placed now without a round-trip:

---
## Standing rule - no PATH-shadowing for verification (added 2026-09-05)

When verifying a fix's behavior under a simulated command failure (e.g.
"what does the launcher do if `hermes` returns nonzero"), never shadow the
real system command by prepending a scratch directory to `PATH` so a fake
script of the same name intercepts calls to it. This failed unsafely in a
prior session here: a `PATH`-shadow attempt to fake a failing `hermes`
command was defeated twice by the shell's command-hash cache (an earlier
real `hermes` invocation in the same session had already cached its real
path, so the `PATH` prepend never took effect), and the real `hermes`
binary ran instead - twice mutating Kenneth's actual `hermes` config
(`model.provider`/`model.default`) before being caught and reverted (see
this file's session-history for the incident this rule is based on).

Use one of these two safe alternatives instead, depending on what actually
needs verifying:

1. **The real binary genuinely needs to run:** isolate it via its own
   env-var home override (e.g. `HERMES_HOME=<scratch dir>`) for that
   specific process, so it reads/writes scratch state only - never by
   trying to intercept the command itself.
2. **Only in-process logic needs verifying:** use a same-name shell
   function (bash) or a local label (batch) as the stand-in - these always
   take priority over `PATH` lookup within a process, so there is zero
   ambiguity about which one runs, unlike a `PATH` prepend against an
   already-hash-cached command.
---

## Commits made this session

None yet (pending this report's own commit, per standing Zone A
authorization for the audit file itself).

## Uncertain / flagged for primary GPT review

1. Whether the declined-edit judgment call above is correct: I treated
   "add this rule to CLAUDE.md" as a direct compositional request, not a
   named Claude-Project-chat handoff, based on the CONFIRMED 2026-08-26
   trigger definition requiring the content be identified as originating
   from that chat. If the primary GPT disagrees with how narrowly that
   trigger should be read, that's worth resolving explicitly so future
   sessions don't have to re-derive it each time a similar request comes in
   directly from Kenneth.
2. The proposed rule text above is a first draft by Claude Code, not
   authored by the Claude Project chat - if adopted, it should get the same
   scrutiny any Zone B content gets before being treated as final, not be
   placed on the strength of this audit report alone.

## Status
Clean - no repo files changed this session apart from this audit report.
Requested Zone B edit correctly declined and flagged back rather than
performed directly; proposed text drafted for Kenneth/primary-GPT review
rather than placed. Needs primary GPT input on item 1 above (the handoff-
trigger judgment call) before this becomes a recurring pattern either way.
