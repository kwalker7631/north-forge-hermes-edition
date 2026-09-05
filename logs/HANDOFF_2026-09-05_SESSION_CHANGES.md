# Handoff: Claude Code session 2026-09-05 (final batch - all open items closed)

Audience: the Claude AI running Kenneth's GPT (Claude Project chat).
Everything here was done at Kenneth's explicit direction in a single
"final batch" message covering three phases plus five previously-open
items carried across multiple prior handoffs. This doc is the complete
record of what changed, what was verified, and the exact literal outputs
Kenneth asked to have relayed.

## Context

The immediately prior session (recon-only, see
`audit/CLAUDE_CODE_LAST_AUDIT.md` history / commit `1c48f95`) found that
this Hermes install's active default model, `claude-fable-5`, is gated
behind a separate purchased "usage credits" balance distinct from ordinary
pay-per-token billing, with no visible warning distinguishing it from
normal metered models, and that this repo's own onboarding (`launch-
north-forge.bat`/`.sh`) hard-required an Anthropic API key with no free
path at all. This session closes that out plus several other long-pending
items.

---

## PHASE 1 - Kenneth's own dev machine: off the credits wall

**Not a repo change** - machine-local Hermes config only
(`C:\Users\kwalk\AppData\Local\hermes\config.yaml`).

Ran: `hermes config set model.default claude-sonnet-4-6`

Result (verified twice - via the command's own echoed confirmation, and by
reading `config.yaml` directly afterward):

```
model:
  default: claude-sonnet-4-6
  provider: anthropic
```

Confirmed via `hermes config get model.default` -> `claude-sonnet-4-6` and
`hermes config get model.provider` -> `anthropic`.

**Side effect worth flagging:** the command's own output warned that 2
enabled cron jobs (`nightly-kyocera-research`, `daily-kyocera-brief`) have
stored `model_snapshot` values that now differ from the new global model,
and will "fail closed" (not silently use the new model) on their next
scheduled run. Kenneth did not ask for these to be re-pinned this session,
so they were left as-is - flagging so the next nightly/daily run isn't a
surprise. Fix, if wanted: `hermes cron edit <job_id> --provider anthropic
--model claude-sonnet-4-6` (or leave unpinned and let it use whatever the
global default is at run time - the exact tradeoff should be Kenneth's
call, not assumed).

---

## PHASE 2 - OpenCode Free as the onboarding default (repo change)

Commit `5291b86` - "Phase 2: default onboarding to zero-config OpenCode
Free, own-key opt-in"

### What changed

`launch-north-forge.bat` and `launch-north-forge.sh` (both Script version
1.0.0 -> 1.1.0) no longer hard-gate on an Anthropic API key. On first run
(once Hermes itself is confirmed installed), if `.provider-choice` doesn't
exist yet, the launcher now asks:

```
North Forge needs an AI provider before it can answer questions.

  Press ENTER  - start now for free, no account or key needed
                 (uses OpenCode Free - good for trying it out)
  Type OWNKEY  - use your own Anthropic API key instead
                 (paid, pay-per-token - pick this for real field/production use)

Your choice [ENTER = free / OWNKEY = your own key]:
```

- **Enter (default):** writes `free` to `.provider-choice`, runs `hermes
  config set model.provider opencode-free` and `hermes config unset
  model.default`, and launches straight into Hermes. No `.env`, no
  Notepad, no block.
- **OWNKEY:** writes `ownkey` to `.provider-choice` and falls into the
  existing `.env`-creation / Notepad / key-length-check flow, byte-
  identical to the old hard gate, just now opt-in. The first-run Notepad
  prompt now also carries an explicit warning (see below).

The choice is remembered in `.provider-choice` (same one-time-ask pattern
already used for `.agent-name` and `.drive-record.txt`) and never
re-asked. It is **not** re-enforced on every subsequent launch - if a
"free" user later runs `hermes model` themselves to switch providers, the
launcher will not silently stomp that choice back to OpenCode Free.

`.env.example` (Script version 1.0.0 -> 1.1.0) rewritten: leads with "most
people don't need this file at all," reframes `ANTHROPIC_API_KEY` as
optional/opt-in tied specifically to typing `OWNKEY` at the prompt, and
adds an explicit warning:

> IMPORTANT: once you have a real key, run 'hermes model' and pick a
> standard model such as Sonnet or Opus. Avoid a premium/credits-gated
> model (Fable, Mythos) as your default unless you specifically understand
> it requires a separate purchased "usage credits" balance on top of this
> API key - an ordinary pay-per-token key alone will not cover it, and you
> can otherwise get a "buy credits" error on your very first real
> question.

The same warning (shorter) appears in the launcher's own first-run Notepad
prompt in the OWNKEY branch.

### Why `opencode-free` is the correct, non-guessed mechanism

Traced directly in the installed `hermes-agent` Python source
(`~/AppData/Local/hermes/hermes-agent/`), not inferred from docs:

- `hermes_cli/auth.py:238` - `("opencode-free", "OpenCode Free",
  "https://opencode.ai/zen/v1", ())` - the empty tuple is the required-
  env-vars list: genuinely zero credentials needed.
- `hermes_cli/models.py:399` (`get_default_model_for_provider`) - "Cost-
  safe default model for a provider... the NON-INTERACTIVE fallback when a
  provider is configured but no model was ever selected."
- `hermes_cli/cli_agent_setup_mixin.py:241-253` - confirmed this function
  is actually called on the live CLI startup path when `model.default` is
  empty/unset: "Still empty... fall back to the provider's first catalog
  model so the API doesn't reject an empty model." Same function is also
  wired into `gateway/run_turn.py` and `gateway/platforms/api_server.py`
  (the messaging-platform paths), so this isn't a CLI-only shortcut.

### Verification performed (not just static review)

1. `hermes config set` / `unset` tested against an **isolated scratch
   `HERMES_HOME`** (never the real machine config) simulating a totally
   fresh install:
   ```
   $ HERMES_HOME=<scratch> hermes config set model.provider opencode-free
   ✓ Set model.provider = opencode-free in <scratch>\config.yaml
   $ HERMES_HOME=<scratch> hermes config unset model.default
   Config key not set: model.default
   $ cat <scratch>/config.yaml
   model:
     provider: opencode-free
   ```
2. Directly invoked the resolution function via the installed venv:
   ```
   $ ./venv/Scripts/python.exe -c "from hermes_cli.models import
     get_default_model_for_provider; print(get_default_model_for_provider(
     'opencode-free'))"
   Resolved default model for opencode-free: 'deepseek-v4-flash-free'
   ```
   Confirms a real, currently-live, non-delisted free model resolves with
   zero model ID hardcoded anywhere in the launch scripts.
3. Extracted the exact new gate logic from `launch-north-forge.bat` into a
   standalone test harness and ran it twice against an isolated scratch
   `HERMES_HOME`:
   - Blank/Enter input -> `.provider-choice` = `free`, scratch
     `config.yaml` ended up as `provider: opencode-free` with no `default`
     key, no block, no prompt beyond the one question.
   - `ownkey` input (via a real file redirect, not a PowerShell pipe - a
     PowerShell-piped `|` into `cmd.exe`'s `set /p` was found to deliver
     an empty string, a **test-harness artifact, not a script bug**;
     redirecting from an actual file reproduces real console input
     correctly and confirmed the case-insensitive `OWNKEY` match fires as
     intended) -> correctly took the OWNKEY branch.
4. `bash -n launch-north-forge.sh` - clean.
5. `.env.example` read back top-to-bottom - reads correctly, no dangling
   references to the old "required" framing.
6. All scratch test files and directories deleted after verification -
   nothing left behind outside the repo/session scratchpad.

---

## PHASE 3 - previously-open items, closed out explicitly

### Item 1 - `FIRST_TIME_README.txt`, full verbatim text (Zone B, read-only - quoted, not edited)

```
========================================
 NORTH FORGE - QUICK START
========================================

North Forge - Hermes Edition (Kyocera Edition v21.8) is part of the North
Forge project. Created and maintained by Kenneth C. Walker Jr. - Senior
Technical Support Engineer, TSC.

What this is:
An AI assistant set up specifically for Kyocera field service and sales
work. You describe what you're dealing with, in plain English, and it
helps - the same way you'd ask a knowledgeable coworker.

--------------------
HOW TO OPEN IT
--------------------

Windows: double-click "launch-north-forge.bat" in this folder.

Mac/Linux: the first time only, open Terminal and drag
"launch-north-forge.sh" into the window, then press Enter. After that
first time, use the icon it creates on your Desktop.

The first time you open it on a new computer, it may take a minute or two
to install - that's normal, just wait for it to finish.

--------------------
WHAT TO DO ONCE IT'S OPEN
--------------------

Just describe your issue, like you're texting a coworker who knows the
answer. For example:

    "TASKalfa 5054ci throwing a U240 code after the last firmware update"

    "customer wants to know if the 5054ci supports Wi-Fi Direct"

You don't need to know any special commands to get started. If you want to
see everything it can do, type:

    /menu

--------------------
IF SOMETHING GOES WRONG
--------------------

If it shows an error instead of answering, don't worry about fixing it
yourself - just tell your team lead exactly what it said (copy/paste the
error text if you can), and they'll take it from there.

--------------------
ONE THING TO KNOW
--------------------

This tool helps you find answers faster - it doesn't replace your own
judgment or your team's normal approval process. Treat it like a
knowledgeable coworker's suggestion, not the final word.
```

**Note for whoever builds WELCOME.html from this:** this text still
describes the OLD hard-gated first-run flow only indirectly (it doesn't
mention any provider choice at all, since it predates Phase 2 above). It
does not yet need editing for this handoff (FIRST_TIME_README.txt is Zone
B - not touched, per rule), but WELCOME.html's rewrite should account for
the new provider-choice prompt from Phase 2 if it's meant to walk a user
through first launch accurately.

### Item 2 - registry check

Command: `reg query "HKCU\Console" /v VirtualTerminalLevel`

Actual current output:

```
ERROR: The system was unable to find the specified registry key or value.
```

The `VirtualTerminalLevel` value does not exist under `HKCU\Console` on
this machine. (Also checked via `Get-ItemProperty -Path 'HKCU:\Console'
-Name 'VirtualTerminalLevel'` - same result, no value present.) Not
modified - this was a read-only check per the request.

### Item 3 - grep outputs, verbatim with line numbers

**`.hermes.template.md`, `<how_this_package_is_organized>` paragraph, grep
for "manual" (case-insensitive):**

```
35:skills-source/tsc-only/ (FULL mode only): kb-builder, draft-writer, hotline-ticket, assist-intake, escalation-packet, forge-audit (registers /audit via its frontmatter, not its folder name), fault-logging, training-guide. skills-source/shared/ (every mode): sales-assist (FAQ content still a placeholder pending real spec-sheet curation), web-navigator, menu, manual, flush, switch, kyocera-research, daily-brief (the last two are cron-scheduled, not typed - see each skill's own setup note; both self-schedule automatically at every launch if missing). Each skill declares its own slash-command name via YAML frontmatter (name: field) - without it Hermes falls back to the folder name instead. On a Sales-mode drive, only skills-source/shared/ gets copied into .hermes/skills/ - tsc-only skills are physically absent, on purpose, not merely hidden.
```

One match, line 35. `manual` is listed as one of the `skills-source/shared/`
skills (present in every mode, not just FULL) - confirms the `/manual`
skill added in the prior session is correctly documented here.

**`CLAUDE.md`, grep for `research-log|DECISION`:**

```
(no matches)
```

Zero matches - expected and correct. `CLAUDE.md` is a rules file, not a
decision log; it has no reason to reference `research-log/` or carry a
`DECISION` line.

**`NEXT_STEPS.md`, grep for `research-log|DECISION`:**

```
335:  Appends to `research-log/daily-brief-log.md`. Skill count 14 -> **15**
426:DECISION (2026-09-04, primary GPT review): `research-log/` is intentionally
431:- [x] Add `research-log/` to README.md's file-tree section as a real
471:(research-log/kyocera-research-log.md, a801cb8); browser fallback installed;
535:  at all - a real gap, same class as the `research-log/` gap the last audit
```

Five matches. Line 426's `DECISION (2026-09-04, primary GPT review):
research-log/ is intentionally...` is the specific decision line - present
and intact.

### Item 4 - CLAUDE.md zone-list update (Zone B placement, live-approved)

Commit `3f48e46` - "Phase 3: add CHANGELOG.md to Zone C, USER_MANUAL.md to
Zone B in CLAUDE.md"

Per CLAUDE.md's own rule, I do not compose or edit Zone B content
(including CLAUDE.md itself) from a description of the change alone - I
drafted the exact literal diff, showed it to Kenneth via `AskUserQuestion`
with the full before/after text in the preview, and he selected "Approve
as-is, place it now" before I touched the file. Three places in the file
were updated for internal consistency:

1. **Zone B (continued) section** - added `USER_MANUAL.md` to the
   already-Zone-B user-facing docs list (alongside README.md,
   ATTRIBUTION.md, FIRST_TIME_README.txt).
2. **Zone C Files list** - added `CHANGELOG.md`.
3. **Required first response template block** - added both files to the
   Zone B and Zone C entries in the verbatim template Claude Code echoes
   at every session start, so that block doesn't drift out of sync with
   the actual zone definitions (this exact kind of drift is what the
   file's own STANDING RULE warns about).

This makes explicit what the prior session's audit already treated as
precedent-by-practice (CHANGELOG.md edited freely, USER_MANUAL.md treated
as Zone B) - now written into the rules themselves instead of inferred
each session.

### Item 5 - version bumps

Commit `d37fe9e` - "Phase 3: bump toggle-mode.bat/machine-reset.bat to
1.0.1 for e342f7a fix"

`toggle-mode.bat` and `machine-reset.bat`: `Script version: 1.0.0` ->
`1.0.1`, `Updated: 2026-09-04` -> `2026-09-05`. CHANGELOG.md note (added in
the Phase 2 commit, since it touches the same file) explains this reflects
the `e342f7a` admin_gate password-bypass fix, which predates the 1.0.0
baseline set in the authorship/versioning session.

---

## Commits made this session

- `5291b86` - Phase 2: default onboarding to zero-config OpenCode Free,
  own-key opt-in (Zone A: `launch-north-forge.bat`, `launch-north-
  forge.sh`, `.env.example`, `CHANGELOG.md`)
- `d37fe9e` - Phase 3: bump toggle-mode.bat/machine-reset.bat to 1.0.1 for
  e342f7a fix (Zone A: `toggle-mode.bat`, `machine-reset.bat`)
- `3f48e46` - Phase 3: add CHANGELOG.md to Zone C, USER_MANUAL.md to Zone
  B in CLAUDE.md (Zone B placement, live-approved)

All three pushed cleanly to `main` (`1c48f95..3f48e46`). Phase 1 was
machine-local only, not a repo commit, per Kenneth's own framing of that
item.

## Flagged for primary GPT awareness (not blocking, not asked for this session)

1. The 2 cron jobs' stale `model_snapshot` pins from Phase 1 (see above) -
   Kenneth's call whether to re-pin or leave unpinned.
2. `WELCOME.html` (mentioned in item 1 above) still needs the Phase 2
   provider-choice flow folded into its rewrite - Kenneth said he's
   waiting on the FIRST_TIME_README.txt text (delivered above) to do that
   build; flagging that FIRST_TIME_README.txt itself does not mention any
   provider choice, so the new WELCOME.html content will need to be
   authored to cover it, not copied from FIRST_TIME_README.txt as-is.
3. Everything flagged as open in the prior (`1c48f95`) recon audit that
   wasn't part of this batch (e.g. whether a plain console
   `ANTHROPIC_API_KEY` hits the same Fable/Mythos credits wall, or whether
   that's specific to OAuth-style auth) remains open and unverified.

## Status
Clean - all three phases closed, all quick-checks passed empirically (not
just asserted), nothing left uncommitted, `.env` never staged at any point
(confirmed via `git status` before each of the three commits).
