# CLAUDE.md - North Forge Hermes Edition - Claude Code Working Rules

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

Note on AGENTS.md: this repo also has an `AGENTS.md` at its root, which
plays the equivalent role for Codex sessions that this file plays for
Claude Code sessions. It is not a separate, hidden rule set - it points
back to this file's zone definitions as the single source of truth rather
than duplicating them, and adds one Codex-specific hard requirement (every
Codex session must write and commit an audit report, added 2026-09-06
after a session that skipped this left no record of a real fix it made).
If AGENTS.md's own audit-report requirement needs to change, that's a
Codex-process change and doesn't need to route through this file; if the
zone definitions themselves change, update them here only - AGENTS.md
refers to this file rather than keeping its own copy.

---

## Zone A - Infrastructure / plumbing (Claude Code MAY fix directly)

Files:
- `launch-north-forge.bat`
- `launch-north-forge.sh`
- `toggle-mode.bat`
- `toggle-mode.sh`
- `machine-reset.bat`
- `provision-new-drive.ps1`
- `.env.example`
- `skins/north-forge.yaml`
- `logs/CLAUDE_CODE_LAST_AUDIT.md`
- `.gitignore`
- `scripts/*.sh`
- `scripts/*.ps1`
- `scripts/*.py`
- `tests/*.sh`
- `tests/*.py`
- `full-drive-reset.sh`
- `full-drive-reset.bat`

Extended 2026-09-06 to explicitly include the seven `scripts/`/`tests/`/
`full-drive-reset.*` entries above: mechanical glue/test code, same
category already justifying Zone A status for the files explicitly named
above. Multiple sessions (Claude Code and Codex) have already treated it
this way in practice - this closes a recurring gap rather than establishing
new policy.

`archive/` is explicitly outside this list's scope - read-only historical
storage. Claude Code does not modify its contents or move files into or
out of it without an explicit instruction, even though it carries no
separate zone label of its own.

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

## Zone B - Authored content (Claude Code is READ-ONLY / audit-only)

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

CONFIRMED (2026-08-26, by the primary GPT, after being asked in two separate
audit reports): yes, an in-session named handoff from Kenneth - identifying
a specific Zone B file, including CLAUDE.md itself, as originating from the
Claude Project chat, with an instruction to commit it - is the intended and
sufficient trigger. This applies to CLAUDE.md the same as any other Zone B
file. Audits do not need to keep re-flagging this as an open question unless
the handoff mechanism itself changes.

STANDING RULE (2026-08-29, added after two consecutive handoffs were cut
from a stale base and would have silently reverted a real fix -
`provision-new-drive.ps1`'s STOP-message wording, then `.gitignore`'s
`/skills/` guard): before applying ANY Zone A fix or Zone B placement,
diff the incoming content against current HEAD for that specific file, not
just against what the handoff describes itself as changing. If the diff
would remove, revert, or contradict something a previous audit report
recorded as a deliberate fix, do NOT silently apply the handoff verbatim.
Instead: preserve the previously-fixed content and apply only the genuinely
new part of the handoff (as already done correctly, twice, before this rule
existed), and say so explicitly in the audit report - name the specific
prior commit/fix that would have been lost and confirm it was kept. This is
not optional caution to apply when something looks suspicious; it is a
required diff-before-placement step for every handoff, every time,
specifically because the Claude Project chat's own sandbox has repeatedly
drifted behind the real repo state and cannot be trusted to hand over a
byte-for-byte-safe base on its own.

## Zone C - Operational docs (Claude Code MAY update and commit freely)

Files:
- `NEXT_STEPS.md`
- `DEMO_PREP_BACKLOG.md`
- `CHANGELOG.md`

Reasoning: this is a running work-status log, not field-support content and
not infrastructure code - it's closer to the audit report than to Zone A or
Zone B. Keeping it current (what's done, what's still open, what was found
during a session) is useful exactly because it's low-stakes to get slightly
wrong and easy to correct next time.

Claude Code MAY: add, check off, or revise entries in `NEXT_STEPS.md` and
`DEMO_PREP_BACKLOG.md`
reflecting real session findings, and commit/push those changes
automatically, same standing authorization as Zone A.

Claude Code MUST NOT: use `NEXT_STEPS.md` edits as a backdoor to describe or
imply a Zone B content change that didn't actually happen - entries must
describe real findings/actions from that session, not aspirational or
assumed ones.

## Zone B (continued) - user-facing documentation

`README.md`, `ATTRIBUTION.md`, `FIRST_TIME_README.txt`, and `USER_MANUAL.md`
are ALSO Zone B (read-only for Claude Code), in addition to the files
already listed above.
Reasoning: these are Blacksmith-reviewed documentation the team and Kenneth
rely on being accurate as written - not code, not a status log, closer in
spirit to authored content even though they don't contain field-repair
procedures. Same placement exception applies: Claude Code may place and
commit a specific revised version handed over from the Blacksmith or the
Claude Project chat, but does not compose or edit their content itself.

## Session Start Protocol (automatic - runs before any task, no prompting needed)

This runs at the start of every Claude Code session in this repo, unprompted
- Kenneth should never need to ask for this, and his team members
definitely won't know to.

1. `git pull` - get whatever's changed since last session.
2. Read `logs/CLAUDE_CODE_LAST_AUDIT.md` if present - the only continuity
   between sessions.
3. `git status` and `git diff` - check for anything uncommitted sitting in
   the working tree (Zone A/C changes get committed per standing
   authorization below; Zone B changes get reported, not committed, unless
   this session includes an explicit handoff).
4. Confirm `.gitignore` exists and actually excludes `.env`, `.forge-mode`,
   `.hermes.md`, `.hermes/`. If missing or wrong, this is a Zone A fix - make
   it and commit it.
5. Run `hermes doctor` and `hermes skills list --source local` if `hermes`
   is installed, to confirm the last known-good state still holds.
6. Report a short session-start status before doing anything else:

```text
SESSION START CHECK
Pulled: [Yes/No + what changed, or "Already up to date"]
Last audit read: [Yes/No + one-line summary of its status]
Uncommitted at start: [list, or "None"]
.gitignore: [OK / Missing - fixed / Missing - fixing now]
hermes doctor: [Clean / Issues found: ...]
Project skills: [list with status, or "hermes not installed yet"]
```

Only after this does Claude Code proceed to whatever the actual session's
task is. If none was given, a clean session-start check IS the whole task -
write the audit report and stop rather than inventing work to do.

## Git command policy



Claude Code MAY run freely, any time: `git status`, `git diff`, `git log`,
`git show`, `hermes doctor`, `hermes skills list`, and any other read-only
inspection command.

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

## Standing rule - no PATH-shadowing for verification (added 2026-09-05)

When verifying a fix's behavior under a simulated command failure (e.g.
"what does the launcher do if `hermes` returns nonzero"), never shadow the
real system command by prepending a scratch directory to `PATH` so a fake
script of the same name intercepts calls to it. This failed unsafely in a
prior session here: a `PATH`-shadow attempt to fake a failing `hermes`
command was defeated twice by the shell's command-hash cache (an earlier
real `hermes` invocation in that session had already cached its real path,
so the `PATH` prepend never took effect), and the real `hermes` binary ran
instead - twice mutating Kenneth's actual `hermes` config
(`model.provider`/`model.default`) before being caught and reverted (see
audit history for the incident this rule is based on).

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

## Required first response

When Claude Code starts a session in this repo, before doing anything else,
state:

```text
NORTH FORGE HERMES EDITION - CLAUDE CODE WORKING RULES ACTIVE
Zone A (infrastructure, may fix + commit + push automatically): launch scripts, toggle scripts, machine-reset.bat, setup script, provision-new-drive.ps1, .env.example, skins/north-forge.yaml, this audit report, .gitignore
Zone B (authored content, read-only, including this file): .hermes.template.md, mode-blocks/, skills-source/, fallback/, KYO_KB_TITAN template, README.md, ATTRIBUTION.md, FIRST_TIME_README.txt, USER_MANUAL.md, CLAUDE.md
Zone C (operational docs, may update + commit freely): NEXT_STEPS.md, DEMO_PREP_BACKLOG.md, CHANGELOG.md
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
for review, so mistakes get caught rather than silently compounding across
sessions with no shared memory between Claude Code and that chat. This is
the whole point of the audit habit - Claude Code is excellent automation,
but it isn't reviewed by anyone unless this report actually gets read.

UNCONDITIONAL - every session, no exceptions. This used to be conditional
on "anything notable happened," and that conditional is exactly why reports
were sometimes skipped: a session that did nothing but read files and find
nothing wrong still needs to say so in a written report, because "no report
this time" is indistinguishable from "the report step got skipped" once
Kenneth is relaying files between sessions with no memory of his own either.
A clean, boring, nothing-to-report session still ends with a real file that
says exactly that - never silently end a session without writing one.

At the end of every session, write (overwriting any previous one) to:

```
logs/CLAUDE_CODE_LAST_AUDIT.md
```

DEPTH: the primary GPT (Claude, in the Claude Project chat) is the actual
reader of this file, not a human skimming for a summary. Write for that
reader - full technical detail, exact line numbers, exact grep/command
output quoted verbatim, exact file sizes and byte counts where relevant,
full reasoning for any judgment call. Do not compress, simplify, or
soften findings for readability the way a report written for a person
skimming quickly might. If something is uncertain, say exactly what was
and wasn't checked rather than rounding up to a confident-sounding summary.

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

