# CLAUDE.md — North Forge Hermes Edition — Claude Code Working Rules

Scope: this file governs Claude Code sessions run inside this repo
(`north-forge-hermes-edition`) specifically. It is a DIFFERENT authority model
from the original ChatGPT-centric bundle project's `CLAUDE.md`, which
restricts Claude Code to pure read-only audit because ChatGPT was the sole
repair authority there. This repo has no ChatGPT in the loop, so a strict
audit-only model doesn't map cleanly onto it - but neither does unrestricted
fix authority, since this repo also contains authored field-support content,
not just code. The two are governed differently below.

This file does not inherit anything from the other project's `CLAUDE.md` -
they are unrelated repos with unrelated rules.

Note on Hermes's own context-file discovery: Hermes reads `.hermes.md` (if
present) before `AGENTS.md` before `CLAUDE.md`, first match wins. Since
`.hermes.md` is generated fresh at every launch, Hermes itself will never
actually load this file - it's for Claude Code only.

---

## Zone A — Infrastructure / plumbing (Claude Code MAY fix directly)

Files:
- `launch-north-forge.bat`
- `launch-north-forge.sh`
- `toggle-mode.bat`
- `toggle-mode.sh`
- `setup-thumbdrive.ps1`
- `.gitignore`

Reasoning: this is mechanical glue code - testable, low-risk, no field or
technical judgment content in it. A bug here (like the `.hermes/skills`
folder-name issue found earlier) is an objective code defect, not an
authored-content decision. Fixing it doesn't change what a technician is told
to do in the field.

Claude Code MAY: read, run, test, and directly patch these files once it has
confirmed a real bug (not "this looks off" - actually reproduce it first).

Claude Code MUST: report exactly what it found and exactly what it changed
(a real before/after, not a vague summary) in its session-ending response.
Silently fixing something and moving on without saying so is itself a
violation of this file, even if the fix was correct.

Claude Code MAY commit and push Zone A changes AUTOMATICALLY, without asking
first each time - that friction is intentionally removed. Standing
authorization: `git pull` at session start, and `git add` / `git commit`
(clear, specific message describing the fix) / `git push` for any confirmed
Zone A fix, all without waiting for a go-ahead in that session.

## Zone B — Authored content (Claude Code is READ-ONLY / audit-only)

Files:
- `.hermes.template.md`
- `mode-blocks/*`
- `skills-source/**` (every skill file, built or placeholder)
- `fallback/NORTH_FORGE_v21.8_PASTE_VERSION.md`
- `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`
- `CLAUDE.md` (this file, itself)

Reasoning: this is the technical/field-support content itself - the same
category the original bundle's `CLAUDE.md` protects, and the same principle
already stated in `.hermes.template.md`'s own Hermes-specific addendum
("skills are locked, not self-improving"). A wrong "fix" here isn't a code
bug - it's a silent change to what a technician is told to do with a live
machine. Only the Blacksmith (Kenneth Walker Jr.) approves changes here.

`CLAUDE.md` is included in Zone B deliberately: this file is instructions
Claude Code agrees to follow, not a technical permission wall Claude Code is
incapable of bypassing - it can technically edit any file here, including
this one. If it could also rewrite its own rules, there would be nothing
stopping its own authority from quietly expanding over time with no one
noticing. Updates to this file come from the Blacksmith or from the Claude
Project chat where the rest of this repo's content is authored, never from
Claude Code editing it in place.

Claude Code MAY: read, quote, and report on these files - identify
inconsistencies, drift between files, missing content, anything it notices.

Claude Code MUST NOT: edit, patch, rewrite, or "improve" any Zone B file
under any circumstance - not a wording tweak, not a typo fix, not even when
explicitly asked to "fix any issues" in the repo broadly. A broad instruction
does not extend into Zone B; if something there looks wrong, describe why in
the report and stop. Flag it back to the Blacksmith or to the Claude Project
chat where this content is authored.

EXCEPTION - placing pre-approved content: when the Blacksmith or the Claude
Project chat hands over a specific, already-authored file to be placed into
Zone B (e.g., a new or revised skill file, a template update), Claude Code
MAY place that exact file and commit/push it automatically, without asking
again for the git step - the authorization is "place and commit this file,"
given once per handoff. This is placement, not editing: Claude Code writes
the file byte-for-byte as handed over, it does not compose, rephrase, or
extend the content itself.

## Zone C — Operational docs (Claude Code MAY update and commit freely)

Files:
- `NEXT_STEPS.md`

Reasoning: this is a running work-status log, not field-support content and
not infrastructure code - it's closer to the audit report than to Zone A or
Zone B. Keeping it current (what's done, what's still open, what was found
during a session) is useful exactly because it's low-stakes to get slightly
wrong and easy to correct next time.

Claude Code MAY: add, check off, or revise entries in `NEXT_STEPS.md`
reflecting real session findings, and commit/push those changes
automatically, same standing authorization as Zone A.

Claude Code MUST NOT: use `NEXT_STEPS.md` edits as a backdoor to describe or
imply a Zone B content change that didn't actually happen - entries must
describe real findings/actions from that session, not aspirational or
assumed ones.

## Zone B (continued) — user-facing documentation

`README.md` and `ATTRIBUTION.md` are ALSO Zone B (read-only for Claude Code),
in addition to the files already listed above. Reasoning: these are
Blacksmith-reviewed documentation the team and Kenneth rely on being
accurate as written - not code, not a status log, closer in spirit to
authored content even though they don't contain field-repair procedures.
Same placement exception applies: Claude Code may place and commit a
specific revised `README.md`/`ATTRIBUTION.md` handed over from the Blacksmith
or the Claude Project chat, but does not compose or edit their content
itself.



Claude Code MAY run freely, any time: `git status`, `git diff`, `git log`,
`git show`, `hermes doctor`, `hermes skills list`, and any other read-only
inspection command.

Claude Code SHOULD run `git pull` at the start of every session in this
repo, automatically, before doing anything else - this is how updates
authored elsewhere (this chat, the Blacksmith directly) actually reach the
drive without anyone typing git commands by hand. Also check for
`audit/CLAUDE_CODE_LAST_AUDIT.md` at session start and read it if present -
it's the only continuity Claude Code has with what happened last session,
since there's no persistent memory between sessions otherwise.

Claude Code MAY run `git add` / `git commit` / `git push` AUTOMATICALLY,
without asking first, in three cases:
1. A confirmed Zone A fix (see above) - commit message must describe the
   actual fix, not a generic "fix issues" message.
2. A Zone C update (see above) - commit message should describe what
   changed in plain terms (e.g., "mark hotline-ticket skill as still
   outstanding after this session's review").
3. Placing a specific pre-approved file into Zone B when handed one for
   exactly that purpose (see the Zone B exception above) - commit message
   should name the file and what it is (e.g., "add hotline-ticket skill
   v1", "update kb-builder skill per Blacksmith revision").

Claude Code MUST NOT run `git add` / `git commit` / `git push` for any Zone
B content it authored, edited, or "improved" itself - that content should
never exist in the first place, since Zone B is read-only for Claude Code
regardless of git permissions.

## Required first response

When Claude Code starts a session in this repo, before doing anything else,
state:

```text
NORTH FORGE HERMES EDITION - CLAUDE CODE WORKING RULES ACTIVE
Zone A (infrastructure, may fix + commit + push automatically): launch scripts, toggle scripts, setup script, .gitignore
Zone B (authored content, read-only, including this file): .hermes.template.md, mode-blocks/, skills-source/, fallback/, KYO_KB_TITAN template, README.md, ATTRIBUTION.md, CLAUDE.md
Zone C (operational docs, may update + commit freely): NEXT_STEPS.md
Git: git pull automatically at session start; auto-commit/push for Zone A fixes, Zone C updates, and placing pre-approved Zone B handoffs; never author or edit Zone B content myself
I will not edit Zone B content, including this file, and will not compose content on Zone B's behalf - only place exactly what I'm handed.
```

## Required final response

When done, state:

```text
Files inspected: [list]
Zone A changes made (if any): [before/after summary + commit hash, or "None"]
Zone B findings (if any): [describe the issue, do not fix]
Committed/pushed: Yes/No - [exact files + exact commit message, or "Nothing to commit"]
```

## Session audit report (required, written to a file - not just stated in chat)

Kenneth relays this file back to the Claude Project chat (the "primary GPT")
for review after sessions where anything notable happened, so mistakes get
caught rather than silently compounding across sessions with no shared
memory between Claude Code and that chat. This is the whole point of the
audit habit - Claude Code is excellent automation, but it isn't reviewed by
anyone unless this report actually gets read.

At the end of every session that made any change, ran any fix, or found any
Zone B issue, write (overwriting any previous one) to:

```
audit/CLAUDE_CODE_LAST_AUDIT.md
```

Using this exact structure:

```markdown
# Claude Code Session Audit

Timestamp: [date/time]
Requested task: [what Kenneth or a handoff file asked for, in a sentence or two]

## Files inspected
[list]

## Zone A changes made
[For each: file, before/after summary, why, commit hash. Or "None."]

## Zone B findings (not fixed - reported only)
[For each: file, what looks wrong or inconsistent, why it matters. Or "None."]

## Commits made this session
[commit hash - message, for each. Or "None."]

## Uncertain / flagged for primary GPT review
[Anything Claude Code wasn't fully confident about, any judgment call it
made within Zone A that's worth a second opinion, any Zone B content that
seems to need Blacksmith attention soon rather than eventually. Or "Nothing
flagged - routine session."]

## Status
[Clean / Needs primary GPT review / Blocked - waiting on Blacksmith]
```

Commit and push this file automatically as part of normal Zone A operation -
it's Claude Code's own operational record, not authored technical content,
so it doesn't require a separate go-ahead each time, same as any other Zone
A action.

If Kenneth then pastes this file into the Claude Project chat, that chat
should read it as a real audit report, not a status update to skim -
specifically check the "Zone B findings" and "Uncertain / flagged" sections
against the actual repo content before agreeing anything is fine, the same
scrutiny any audit report deserves regardless of who or what produced it.

