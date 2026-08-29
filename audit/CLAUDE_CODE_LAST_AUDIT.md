# Claude Code Session Audit

Timestamp: 2026-08-28 (seventh task this session - end-to-end QA session)

Requested task: Deliberate end-to-end QA - first real run of the 8 built
skills + the mode-toggle system. Five parts: (1) launch FULL, confirm
`.hermes/skills/` assembles all 8 tsc-only + shared, `hermes doctor` clean,
`hermes skills list --source local` shows all enabled; (2) exercise each mode
live with real inputs; (3) spot-check 5-6 web-navigator URLs; (4) observe
`decisive_assistant_rule`'s next-step line live; (5) toggle SALES, relaunch,
confirm reject-list + `/web`. Full detailed report - exact commands, exact
output.

## STATUS: PARTIAL. Deterministic QA (parts 1, 3, 5) DONE and mostly PASS.
## Parts 2 and 4 (live mode-exercise) BLOCKED - no working model credential.
## Two findings below; nothing committed to the repo except this report.

---

## Part 1 - FULL launch + assembly + doctor + skills list

### Commands run (Windows, PowerShell / cmd)
- `.\launch-north-forge.bat` (via a PowerShell background job, 120 s cap;
  `.forge-mode` was already `full`). It ran the full assembly, `hermes skin
  use north-forge`, `hermes skin list`, `hermes skills trust .`, then the
  final interactive `hermes` - which fails headless with
  `prompt_toolkit ... NoConsoleScreenBufferError: No Windows console found`.
  That is expected: the TUI cannot start without a real console. Everything
  before that line completed.
- `hermes doctor`
- `hermes skills list --source local`  and  `hermes skills list`
- `hermes prompt-size`  (offline)

### Assembly - PASS
`.hermes/skills/` after the FULL launch contains exactly 10 dirs, each with a
`SKILL.md`:
```
sales-assist  web-navigator            (shared)
kb-builder  draft-writer  hotline-ticket  assist-intake
escalation-packet  audit  fault-logging  training-guide   (tsc-only)
```
Launcher output: "North Forge running in full mode." and
"10 project skill(s) will load in sessions started inside this repo" /
"10 project skill(s) loaded from this repo". Session tool/skill banner lists
`general: assist-intake, +8 more`.

`.hermes.md` assembled: 16,168 chars (launcher's PowerShell
`Set-Content -NoNewline`; my earlier offline Python calc was 16,164 - a
4-char newline-handling difference, immaterial). Contains "MODE: FULL",
contains "/web or /links", no unreplaced `{{...}}` markers. Well under 20,000.

`git status --porcelain` after all launches: empty. `.hermes/`, `.hermes.md`,
`.forge-mode` are all gitignored - no repo pollution.

### `hermes skills list --source local` - PASS with one caveat (FINDING 1)
9 rows, all `local` / `enabled`: assist-intake, draft-writer,
escalation-packet, fault-logging, hotline-ticket, kb-builder, sales-assist,
training-guide, web-navigator.
The `audit` skill is MISSING from this list even though its folder assembled
and the session says "10 loaded". See FINDING 1.

### `hermes doctor` - NOT clean (FINDING 2 + known items)
"Found 2 issue(s) to address":
1. `✗ model.provider 'anthropic' is set but no API key is configured (check
   ~/.hermes/.env or run 'hermes setup')`
2. `Run 'hermes setup' to configure missing API keys for full tool access`
Also: `⚠ Anthropic API (couldn't verify)`. Plus the long-known
`⚠ SQLite 3.45.1 (WAL-reset bug)` (off-path, flagged in prior audits) and a
batch of optional-integration warnings (telegram, discord, Playwright
Chromium, web-search provider, Nous Portal / Codex / xAI not logged in) that
are not relevant to North Forge's core function. The blocking item is #1 -
see FINDING 2.

### `hermes prompt-size` (offline, informational)
System prompt total 38,178 B; skills index 7,697 B; tool schemas 60,918 B
(21 tools). This is Hermes's own fixed session budget, separate from the
16 KB North Forge `.hermes.md` - just recorded for reference.

---

## Part 2 - exercise each mode live - BLOCKED

Could not be performed. Two independent reasons:
- **No working model credential (FINDING 2).** `hermes doctor` shows the
  `anthropic` provider has no key and the Anthropic API can't be verified;
  Nous Portal (the configured `claude-fable-5 · Nous Research` path) shows
  "not logged in". Nothing is wired up for North Forge to call a model, so
  `/assist`, `/kb`, `/hl`, `/esc`, `/audit`, `/log`, `/train`, `/draft`,
  `/web` cannot be run for real by anyone right now.
- **The launcher's `hermes` is an interactive TUI** that will not start
  without a real console (confirmed: `NoConsoleScreenBufferError` when run
  headless). A non-interactive path exists - `hermes chat -q "<query>" -Q
  --max-turns N` - but running each of the 9 modes that way would spend real
  API credits on the account's key and run an autonomous agent with tools
  enabled. That needs the credential fixed first AND an explicit go-ahead on
  spend; it was not done.

Recommendation: once a real key is in place, either Kenneth runs the modes
interactively and pastes the transcripts, or (with an explicit spend
go-ahead) a follow-up session drives them with `hermes chat -q ... -Q
--max-turns 3 --run-budget 120` per mode and captures each.

---

## Part 3 - web-navigator URL spot-check - PASS

`curl -sIL -A "Mozilla/5.0" --max-time 25` against 7 of the ~40 URLs in
`skills-source/shared/web-navigator/SKILL.md`:

| URL (from the skill) | HTTP | note |
|---|---|---|
| /en/support/downloads.html | 200 | Download Center |
| /en/support.html | 200 | Support & Download hub |
| /en/solutions-services.html | 200 | Products & Services overview |
| /en/solutions-services/printing-solutions/product-configurator.html | 200 | 200-redirects to `https://kyoceraconfigurator.com/` - the configurator is a separate subsite; the skill's label still describes where you land |
| /en/request-a-proposal.html | 200 | Request a Proposal |
| /en/about-us/contact-us/dealer-locator.html | 200 | Dealer Locator |
| /en/insights/departments-and-industries/healthcare.html | 200 | Healthcare vertical |

All 7 resolve and land where the skill says. The other ~33 were not checked
this pass; the sample covers each of the skill's section groups.

---

## Part 4 - observe `decisive_assistant_rule` live - BLOCKED

Same reason as Part 2 - requires live model output. The rule text itself was
re-read and is well-formed (one paragraph, explicit "not the same as showing
the full command menu", FULL+SALES scoped). Whether it produces a one-line
next-step pointer in practice and does not fight the "no giant menu" rule can
only be seen in a live session.

---

## Part 5 - SALES toggle + relaunch - PASS

Commands: `'sales' | Set-Content -NoNewline .forge-mode` (same effect as
`toggle-mode.bat`), then `.\launch-north-forge.bat` (job, 120 s), then
restore `'full'` and relaunch.

- Launcher: "North Forge running in sales mode." /
  "2 project skill(s) will load" / "2 project skill(s) loaded from this
  repo". Session banner: `general: sales-assist, web-navigator` - no
  tsc-only skills.
- `.hermes/skills/` after SALES launch: exactly `sales-assist`,
  `web-navigator` (2 dirs). The 8 tsc-only skills are physically absent, as
  designed.
- SALES `.hermes.md` (16,170 chars): contains "MODE: SALES ASSIST ONLY";
  does NOT contain "MODE: FULL"; contains the reject-list line ("...explain
  plainly that this drive doesn't have that capability..."); contains
  "/web or /links"; does NOT contain "/kb or /k" (a FULL-only command); no
  unreplaced markers.
- Restore: `.forge-mode` back to `full`, relaunch -> "10 project skill(s)",
  `.hermes/skills/` back to 10 dirs. Drive left in FULL state.

The reject-list *behavior* (North Forge actually declining `/kb` etc. on a
SALES drive) is a live-session check - blocked with Part 2. The assembly and
context side of SALES mode is correct.

---

## FINDING 1 - `audit` skill: assembles + loads but is not listed, likely a reserved-name collision

`skills-source/tsc-only/audit/` xcopies into `.hermes/skills/audit/SKILL.md`
fine, and the FULL session banner says "10 project skill(s) loaded". But
`hermes skills list` (and `--source local`) shows only 9 local skills -
`audit` is absent. `hermes skills <action>` has a built-in sub-action also
named `audit` (`{trust,untrust,...,check,update,audit,uninstall,...}`), so a
project skill named `audit` collides with that reserved word. The session
loader and the management CLI disagree: one counts it, the other drops it.

Impact: unknown until a live session - `/audit` *may* still trigger the
skill (the session says it loaded), or it may not. The `audit/SKILL.md`
content itself is fine (3953 B, no BOM, LF, opens with `# Audit Skill` +
Trigger + self-lock line, same shape as its siblings).

Recommendation (Blacksmith / Claude Project chat, Zone B - not changed
here): rename the skill to something non-reserved (e.g. `forge-audit` or
`kb-audit`) and update the `/audit` references in `.hermes.template.md`
(L72) and `mode-blocks/full-menu.md` (L6). OR confirm by live test that
`/audit` triggers despite the listing gap and document that the CLI listing
is cosmetically short.

## FINDING 2 - no working model credential; `hermes doctor` not clean; North Forge cannot run a model

- Repo `.env`: `ANTHROPIC_API_KEY` is present but only 13 characters - a
  placeholder, not a real `sk-ant-...` key (~108 chars). (This contradicts
  `DEMO_PREP_BACKLOG.md` item 9's note about a live key on the build drive -
  either this checkout is not that drive, or the key was scrubbed since.
  Worth reconciling.)
- Hermes's own `~/AppData/Local/hermes/.env`: `ANTHROPIC_API_KEY` length 1,
  `ANTHROPIC_TOKEN` length 0 - effectively empty.
- `hermes doctor`: `✗ model.provider 'anthropic' ... no API key`,
  `⚠ Anthropic API (couldn't verify)`, `⚠ Nous Portal auth (not logged in)`.
- The launcher never catches this: its only credential check is
  `if not exist ".env"` - a file that exists but contains a placeholder
  passes, and the user is dropped straight into a `hermes` session that
  can't call a model.

Impact: blocks Parts 2 and 4 of this QA entirely. Also a real
demo/onboarding risk - a freshly provisioned drive whose `.env` still has
the template value launches "successfully" and then fails on the first
actual prompt.

Recommendation:
- Put a real Anthropic key (with a console spend cap - see `DEMO_PREP` item
  9) into whichever `.env` Hermes actually reads on the target machine, or
  log in to the configured provider, then re-run `hermes doctor` to
  green-light.
- Consider (Zone A, `launch-north-forge.bat` / `.sh`) hardening the
  credential check: after copying `.env.example` -> `.env`, also refuse to
  proceed if `ANTHROPIC_API_KEY` is empty or still equals the template
  value, instead of only checking file existence. Flagged, not changed -
  wanted a decision first.

---

## Global-state changes made by running the launcher (expected, reversible)
- `hermes skin use north-forge` ran 3x (once per launch) -> set
  `display.skin = north-forge` in `~/AppData/Local/hermes/config.yaml` and
  activated the skin. This is what the launcher does every run. Revert with
  `hermes skin use default` if unwanted.
- `hermes skills trust .` ran 3x -> "Already trusted: E:\north-forge-hermes-edition"
  (this repo was already in the trust store; no change).
- `.hermes/skills/`, `.hermes.md` rebuilt 3x (FULL, SALES, FULL). All
  gitignored. Drive left in FULL.
- No repo files changed. `git status` clean.

## Zone A / B / C changes
- Zone A: this audit file only.
- Zone B: none.
- Zone C: none (`NEXT_STEPS.md` not touched - QA is not "done", parts 2/4
  are blocked).

## Commits made this session
- Tasks 1-6: `bd8969c`, `3f28184`, `7e4d55d`, `3a44994`, `cfa18a7`,
  `df6a328`, `187cd5e`, `0b179f0`, `d414f81`, `3c2b7f3`, `1898d33`,
  `07b1343`, `971ac01`.
- This report (task 7) - hash in `git log`.

## Uncertain / flagged for the North Forge GPT / Blacksmith
- FINDING 2 is the blocker to finishing QA. Nothing about the skills or the
  mode toggle is wrong - the assembly, the mode split, the menu/banner
  swap, the trust gate, the skin activation, and the web-navigator links all
  check out. What is missing is a working model credential.
- FINDING 1 (`audit` name collision) is a real Zone B issue - a rename is
  the clean fix. Needs a Claude Project chat handoff like the others.
- Parts 2 and 4 still owe a real result. Options: (a) Kenneth runs the 9
  modes interactively post-credential-fix and pastes transcripts for review;
  (b) a follow-up session runs `hermes chat -q` per mode with an explicit
  spend go-ahead and `--max-turns` / `--run-budget` caps.

## Status
Partial / blocked. Parts 1, 3, 5 done and passing (with FINDING 1 noted on
part 1). Parts 2, 4 blocked on FINDING 2 (no model credential). Repo
untouched apart from this report; working tree clean; drive left in FULL
mode.
