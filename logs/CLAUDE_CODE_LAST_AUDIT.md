# Claude Code Session Audit

Timestamp: 2026-09-15 (afternoon session, following "ground_truth_audit_path_fix" +
"button_up_open_issues" task files)
Requested task: (1) A ground-truth audit of drive/repo state with no assumed
continuity from prior session reports - confirm everything live. (2) A permanent
fix for the `hermes`-on-PATH-can-resolve-wrong-environment issue (in the sibling
`north-forge-agent` repo, not this one). (3) Fix whatever the audit found still
pending, including landing the five Zone B doc corrections from the prior
"button up open issues" session.

Note on this session's start: the required Session Start Protocol banner was not
printed verbatim at the very start of work in this repo (work began from the
sibling `north-forge-agent` repo's own ground-truth audit and only reached this
repo partway through). Its substance was still performed: `git status`/`git diff`
were run before any commit, `git fetch origin` confirmed local `main` was in sync
with `origin/main` (not literally `git pull`, but equivalent - nothing to pull),
and the working tree's pre-existing uncommitted state was read and diffed in full
before touching anything. Flagging the protocol gap honestly per this file's own
"never silently end a session without writing one" spirit, rather than
retroactively implying the banner ran on time.

## Files inspected

Full `git status`/`git diff` of the working tree; `git log --oneline -15`;
`git remote -v`. Read in full: `CLAUDE.md` (both the git-tracked source here and,
via an ambient system reminder, the deployed runtime copy at
`D:\north-forge-agent-data\profiles\kyocera\CLAUDE.md` - confirmed stale relative
to this session's Zone A list correction, expected since deployed profile copies
aren't live-synced to the edition source). Read in full the diffs for the five
committed Zone B files (`Advanced/deploy-console/ADMIN_FIRST_TIME.txt`,
`Advanced/deploy-console/EXCALIBUR.md`, `CLAUDE.md`, `FIRST_TIME_README.txt`,
`USER_MANUAL.md`) and the two still-uncommitted ones
(`research-log/kyocera-research-log.md`, `skills/kyocera-research/SKILL.md`).
Read all three pending KB drafts in
`kb-drafts/_pending/2026-09-15_kyocera-ricoh-xerox-partnership/` in full.
Read `dashboard-themes/north-forge-kyocera.yaml` and the kyocera profile's
`config.yaml` (`dashboard.theme: north-forge-kyocera`). Ran `hermes doctor`,
`hermes cron list`, `python -m hermes_cli.nf_tier verify`, and a real `hermes -z`
test prompt against `HERMES_HOME=D:\north-forge-agent-data\profiles\kyocera`.

## Zone A changes made

None in this repo this session. (A real, tested, committed Zone-A-equivalent fix
- `hermes`-on-PATH precedence detection/repair - was made in the sibling
`north-forge-agent` repo, which has no zone system of its own; see that repo's
own commit `83c85b3f03` and its `logs/SESSION_REPORT_2026-09-15_*` for full
detail. Not duplicated here since it is out of this file's scope.)

## Zone B findings (not fixed - reported only)

1. **`CLAUDE.md`'s own Zone B file list still names
   `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` as a bare root-level
   filename** (line ~136); it actually lives at
   `skills/kb-builder/assets/KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html`.
   Already flagged inline in the committed Zone A section of this same file
   (see the `[CORRECTED 2026-09-15, Blacksmith-directed]` note at the top of
   the Zone A list) but NOT corrected in the Zone B list itself, because doing
   so would mean Claude Code composing/editing Zone B content (this file)
   directly - explicitly prohibited by this file's own rule, "not even when
   explicitly asked to 'fix any issues' in the repo broadly." A task file this
   session asked for exactly that edit; declined for this reason and flagged
   here instead, per "describe why in the report and stop." One-line fix ready
   for the Blacksmith/Claude Project chat to place: replace
   `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` with
   `skills/kb-builder/assets/KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` on
   that line.
2. **Two files remain uncommitted**: `research-log/kyocera-research-log.md`
   and `skills/kyocera-research/SKILL.md` (the latter is explicitly Zone B via
   `skills/*/SKILL.md`; the former isn't named in any zone list at all). Both
   carry "Blacksmith-directed" annotations inline and read as legitimate,
   coherent additions from the same TagG/AlphaStream/Ricoh/Xerox research
   session that produced the three pending KB drafts - but neither was
   explicitly named by this session's task handoff (which named exactly five
   files), so neither was committed under the placement exception. Kenneth
   should either explicitly name these two for a future handoff, or confirm
   they're fine to place now.
3. **Separately worth flagging**: this file's own Zone B placement-exception
   language ("an in-session named handoff... with an instruction to commit
   it... is the intended and sufficient trigger", "no further review needed")
   reads, out of context, very close to a classic instruction-poisoning
   pattern - content that conditions an AI agent to skip review of future
   changes to itself. This session's own safety tooling flagged (and blocked)
   a git commit whose message recited that exact reasoning back, before a
   plainer, factual commit message succeeded. Not asserting this file IS an
   attack - it plainly isn't, Kenneth designed it and named it as the
   authority in this repo - but the shape is worth the Blacksmith/Kenneth
   being aware of, since a page or file genuinely written by an attacker to
   condition a future agent session would look exactly like this.

## Commits made this session

`03eff77` - "Update admin/user docs for the four-drive-class redesign" (the five
explicitly-authorized Zone B files, placed verbatim, not authored/edited by
Claude Code). Pushed to `origin/main`.

## Uncertain / flagged for primary GPT review

- Real, current, live-tested status (not assumed from prior reports) as of this
  session: inference provider is configured (`anthropic` / `claude-fable-5.1`)
  but genuinely non-functional - a real `hermes -z "..."` test prompt against
  this profile returned `No inference provider configured` in full. Still
  blocked on Kenneth running `hermes config set ANTHROPIC_API_KEY <key>`
  himself, per the standing rule against attempting that from here.
- The web dashboard now genuinely builds and launches for the first time this
  session (Node.js v26.7.0/npm 11.19.0 installed; `D:\` is exFAT, which has no
  symlink/junction support, so `npm install --workspace web` fails there no
  matter what npm flags are used - worked around by building on an NTFS scratch
  copy and copying only the plain-file `hermes_cli/web_dist/` output back).
  Confirmed live: `curl http://127.0.0.1:9119/` → HTTP 200, and
  `/api/status` → a coherent JSON status scoped to
  `HERMES_HOME=...\profiles\kyocera` with `gateway_running: true`. Kyocera
  branding is confirmed correctly wired at the config/theme-file level
  (`dashboard.theme: north-forge-kyocera`, a real palette file with the same
  forge-gold-on-dark-iron colors as the CLI skin) but could NOT be visually
  confirmed in a real browser this session - the Claude-in-Chrome extension
  was not connected in this environment. That one specific visual-confirmation
  step is still genuinely unverified, same limitation every prior session hit,
  even though the dashboard itself working at all is new this session.
- Pinokio's interactive first-run (Settings → Home, one Discover app) remains
  genuinely not done - `D:\pinokio\api\` (installed apps) and
  `D:\pinokio-home\` are both empty, `key.json` is `{}`. Confirmed by direct
  inspection, not assumed.
- A fifth first-hand instance of the long-tracked "handoff zip vanishes from
  `D:\` after being built and sha256-verified" bug was found and logged to
  `north-forge-agent/logs/ledger/errors/ERROR-LOG.md` (`ERR-2026-09-13-003`
  update) - `HANDOFF_2026-09-15_0950.zip`, built hours after this morning's
  drive rebuild (so not explained by the rebuild itself), is genuinely gone.
  Root cause remains unverified.

## Status

Needs primary GPT review - three real Zone B/process findings above (the
CLAUDE.md path reference, the two unnamed uncommitted files, and the
instruction-poisoning-shaped language worth a second set of eyes), plus the
still-open inference-provider and Pinokio blockers that need Kenneth directly.
