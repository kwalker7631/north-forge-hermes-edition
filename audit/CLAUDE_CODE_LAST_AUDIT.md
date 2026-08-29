# Claude Code Session Audit

Timestamp: 2026-08-29 (place a single Zone B handoff: CLAUDE.md, adding a STANDING RULE about diffing handoffs against HEAD)

Requested task: Extract a handed-over `CLAUDE.md` into the repo root,
overwriting the current one. Handed over by the Claude Project chat for
placement. It adds a standing rule making explicit the diff-before-apply
behavior Claude Code has now performed correctly twice on its own: diff every
Zone A fix and Zone B placement against current HEAD before applying, and if
it would revert a previously-fixed thing, preserve the fix and say so in the
audit report rather than silently taking the newer handoff as-is. Commit and
push.

## Authority basis for placing CLAUDE.md

This is a Zone B file (CLAUDE.md is explicitly in Zone B, "this file,
itself"). Placement is authorized by the CONFIRMED 2026-08-26 note in
CLAUDE.md: "an in-session named handoff from Kenneth - identifying a specific
Zone B file, including CLAUDE.md itself, as originating from the Claude
Project chat, with an instruction to commit it - is the intended and
sufficient trigger [...] This applies to CLAUDE.md the same as any other Zone
B file." Kenneth's message this session meets every element: names the file
(CLAUDE.md), names the origin (the Claude Project chat), gives the commit
instruction. Placed byte-for-byte; not composed, reworded, or edited by
Claude Code.

## Files inspected

- `~/Downloads/CLAUDE.md` (the handoff, 15456 bytes, mtime 2026-08-29 02:03).
- Working-tree `CLAUDE.md` (already present as a modification at session
  start).
- `git show HEAD:CLAUDE.md` (blob `e383d46`, 14266 bytes) for the diff.
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior session - continuity).

## Session-start check

```
SESSION START CHECK
Pulled: Already up to date (origin/main at 59c6d13 before this session).
Last audit read: Yes - prior session placed the onboarding + custom-agent-name
  handoff (commit cfd618d): 4 Zone B files byte-for-byte, 2 Zone A launchers
  wired for .agent-name, .gitignore given +.agent-name with the 8e1eb69
  /skills/ guard re-appended after the handoff copy was found stale-based.
  Reverted a stray RESET-stripping toggle-mode.sh edit. Status "Needs primary
  GPT review"; open flags: (1) confirm the .gitignore /skills/ re-append was
  wanted, (2) source of the toggle-mode.sh edit, (3) .bat/.sh CRLF divergence
  on autocrlf machines, (4) .bat not run end-to-end, (5) no live model session.
Uncommitted at start: CLAUDE.md (modified). git diff --stat: 18 insertions,
  0 deletions. The working-tree copy is byte-for-byte identical to
  ~/Downloads/CLAUDE.md (sha256 171266eb9f7a0944bfb015b0039868770c35026acb2a6e84f7f188b769b1e104
  on both) - the working tree had been pre-populated from the handoff before
  this session started, same pattern as the last two sessions.
.gitignore: not modified this session; unchanged from cfd618d (has .agent-name
  and the re-appended /skills/ guard; .env / .forge-mode / .hermes.md /
  .hermes/ all still excluded).
hermes doctor: not re-run (this task is a single documentation-file placement,
  touches no skills, no launcher, no engine config; prior two audits recorded
  only pre-existing environment issues - no Anthropic key on this drive,
  SQLite 3.45.1 WAL advisory, optional deps absent).
Project skills: not re-listed; unaffected by a CLAUDE.md-only change.
```

## Diff-before-placement check (the rule being added, applied to itself)

`git diff HEAD -- CLAUDE.md`, full output:

```
@@ -106,6 +106,24 @@ sufficient trigger. This applies to CLAUDE.md the same as any other Zone B
 file. Audits do not need to keep re-flagging this as an open question unless
 the handoff mechanism itself changes.

+STANDING RULE (2026-08-29, added after two consecutive handoffs were cut
+from a stale base and would have silently reverted a real fix -
+`provision-new-drive.ps1`'s STOP-message wording, then `.gitignore`'s
+`/skills/` guard): before applying ANY Zone A fix or Zone B placement,
+diff the incoming content against current HEAD for that specific file, not
+just against what the handoff describes itself as changing. If the diff
+would remove, revert, or contradict something a previous audit report
+recorded as a deliberate fix, do NOT silently apply the handoff verbatim.
+Instead: preserve the previously-fixed content and apply only the genuinely
+new part of the handoff (as already done correctly, twice, before this rule
+existed), and say so explicitly in the audit report - name the specific
+prior commit/fix that would have been lost and confirm it was kept. This is
+not optional caution to apply when something looks suspicious; it is a
+required diff-before-placement step for every handoff, every time,
+specifically because the Claude Project chat's own sandbox has repeatedly
+drifted behind the real repo state and cannot be trusted to hand over a
+byte-for-byte-safe base on its own.
+
 ## Zone C - Operational docs (Claude Code MAY update and commit freely)

 Files:
```

`git diff --numstat -- CLAUDE.md` -> `18  0  CLAUDE.md` (18 added, **0
removed**). One hunk. The insertion sits between the CONFIRMED 2026-08-26
paragraph and the `## Zone C` header - inside the Zone B section, which is
where a rule about Zone A fixes and Zone B placements belongs.

Nothing in HEAD's CLAUDE.md is removed, reworded, or contradicted. Positive
confirmation that the content added by the previous commit (`cfd618d`) is all
still present in the handoff copy:
- `FIRST_TIME_README.txt` - 2 occurrences (Zone B (continued) list + the
  Required-first-response Zone B line). Present.
- `UNCONDITIONAL - every session, no exceptions` - present (line 252).
- `DEPTH: the primary GPT (Claude, in the Claude Project chat) is the actual
  reader` - present (line 267).
- The em-dash -> hyphen normalization from `cfd618d` is intact (no `—` in the
  file; `non_ascii=0`).

So the rule's own diff-before-placement requirement is satisfied trivially
here: there is no prior fix at risk, because the handoff deletes nothing.

## Encoding / integrity

`CLAUDE.md` after placement: 15456 bytes, 316 lone-LF, 0 CRLF, 0 NUL, 0
non-ASCII (`file` -> "ASCII text"). HEAD was 14266 bytes; +1190 for the
18-line paragraph. Consistent with the rest of the repo's LF-only ASCII
convention. (`git` prints the usual "LF will be replaced by CRLF" advisory on
add because `core.autocrlf=true` on this machine; the committed blob is LF.)

## Placement action

The working tree already equalled the handoff byte-for-byte, so no copy was
needed - confirmed identical to `~/Downloads/CLAUDE.md` by sha256, then
`git add CLAUDE.md` + commit + push. No other file touched. `git status`
clean after commit.

## Zone A changes made

None. This session placed one Zone B file and wrote this audit report. No
Zone A file was read for change or modified.

## Zone B findings (not fixed - reported only)

None as defects. The one Zone B file placed (`CLAUDE.md`) is a clean additive
handoff. Observation, not a defect: the new STANDING RULE partially overlaps
the existing "EXCEPTION - placing pre-approved content" paragraph and the
CONFIRMED 2026-08-26 note - all three now speak to how handoffs are applied.
They are not contradictory (the new rule adds a pre-apply diff step; the
others govern authority to place at all), but a future consolidation pass by
the Claude Project chat could tighten them into one place. Not acting on this
- Zone B, and it is not wrong as written.

## Commits made this session

- `5911c7d` - "CLAUDE.md: add STANDING RULE - diff every handoff against
  current HEAD before placing". 1 file, +18/-0. Pushed to origin/main
  (`59c6d13..5911c7d`).
- (this audit file) - Zone A operational record, committed/pushed separately.

## Uncertain / flagged for primary GPT review

- Nothing uncertain about this placement itself - single additive paragraph,
  reverts nothing, authority trigger clearly met, placed verbatim.
- Carry-over from `cfd618d` still open (unchanged by this session): (1)
  whether the `.gitignore` `/skills/` re-append was intended or the handoff
  meant to drop it; (2) the origin of the RESET-stripping `toggle-mode.sh`
  working-tree edit; (3) the `.bat` vs `.sh` `.hermes.md` CRLF byte
  divergence on `core.autocrlf=true` machines; (4) `.bat` not exercised
  end-to-end; (5) no live model session has run against the current
  `.hermes.template.md` (missing Anthropic key on this drive).
- Meta note for the Claude Project chat: this is now the THIRD consecutive
  session where the working tree was pre-populated with the handoff files
  before Claude Code started (provision-new-drive.ps1, then the 7-file
  onboarding zip, now CLAUDE.md). It has worked out because Claude Code
  re-derives the handoff from `~/Downloads` and diffs against HEAD anyway,
  but if that pre-population is not deliberate it is worth knowing something
  is staging these files outside the session.

## Status

Clean. Single Zone B file placed byte-for-byte via the CONFIRMED named-handoff
trigger; diff-before-placement check (per the very rule being added) run and
passed with zero deletions; prior `cfd618d` content verified intact;
committed and pushed (`5911c7d`); working tree clean. No Zone A change, no
Zone B defect. Carry-over flags from last session remain open for the primary
GPT.
