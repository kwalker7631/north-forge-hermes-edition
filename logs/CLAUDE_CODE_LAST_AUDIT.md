# Claude Code Session Audit

Timestamp: 2026-09-14, local
Requested task: three linked requests, in order: (1) `/simplify` - review the
diff on `Advanced/deploy-console/Zero-Touch-Deploy.ps1`'s capacity-gate
commit for reuse/simplification/efficiency/altitude issues and apply safe
fixes; (2) run two Claude-Code task files dropped in `Downloads\` - a
retry-limited "fix everything confirmed" list (of which 2 of 4 items land in
this repo: kb-builder's draft location, and a dashboard-branding
attribution caption) and a fact-finding pass on per-user-passcode reality
and skill-list ordering (both land in this repo's own content/history); (3)
gather the report/ledger/handoff-bundle artifacts for this pass, matching
the established cross-repo convention.

## Files inspected

`Advanced/deploy-console/Zero-Touch-Deploy.ps1`, `.gitignore`,
`skills/kb-builder/SKILL.md` (Zone B, read-only), `skills/flush/SKILL.md`
and `skills/switch/SKILL.md` (Zone B, read-only - root cause of the `/clr`
`/fl` alias bug lives in `north-forge-agent`, not here), `ALIASES.md`,
`skills/menu/SKILL.md`, `SOUL.md`, `.hermes.template.md`, `NEXT_STEPS.md`,
`CHANGELOG.md`, `archive/legacy-standalone-launcher/launch-north-forge.bat`
(and its `.sh` twin), `WELCOME.html`, `distribution.yaml`, and (cross-repo,
to understand mechanisms this repo's content depends on)
`north-forge-agent`'s `agent/skill_commands.py`, `hermes_cli/commands.py`,
`hermes_cli/commands_completion.py`, `cli.py`'s slash-dispatch chain,
`scripts/nf_sync_cron.py`, `hermes_cli/profiles.py`,
`hermes_cli/web_server_dashboard.py`, `web/src/App.tsx`, and
`website/docs/user-guide/features/extending-the-dashboard.md`.

## Zone A changes made

1. **`Advanced/deploy-console/Zero-Touch-Deploy.ps1`** - simplified the
   capacity-gate `if` structure (two sequential type-guarded `if`s ->
   one `if`/`elseif`) and inlined message-building to match the file's
   own `Write-Fail`/`Write-WarnLine` convention. No behavior change.
   Commit `6376858`.
2. **`.gitignore`** - added `/kb-drafts/`. `kb-builder` (Zone B, no
   script) writes drafts there on real use with no documented redirect
   available at the code level; the folder was never tracked, so
   ignoring it fully resolves the `git status` pollution this was
   flagged for. Commit `56b43be`.
3. **`CHANGELOG.md`** - new entry documenting all three fixes below plus
   this one, cross-referencing `north-forge-agent`'s ledger for the
   alias-routing fix. Commit `7fb12aa`.

New content added, not matching any existing Zone A/B path (same
"added with no zone assignment" situation `Advanced/deploy-console/`
itself was in before the 2026-09-12 extension - flagging per that
precedent rather than assuming):

4. **`plugins/north-forge-attribution/dashboard/{manifest.json,dist/index.js}`**
   (new top-level `plugins/` folder) - a minimal Hermes dashboard plugin
   registering a small "In association with Hermes Agent" caption into
   the documented `header-left` slot, beside the dashboard's hardcoded
   "Hermes / Agent" wordmark (`north-forge-agent/web/src/App.tsx:612-618`
   - not an image asset, so nothing here touches a "logo"). Mechanical
   glue code, same reasoning Zone A already uses elsewhere (JS/JSON, no
   field-support content). Verified for real: called
   `hermes_cli.web_server_dashboard._discover_dashboard_plugins()`
   against the live kyocera profile and confirmed the plugin is
   discovered, parsed, and registered (`source: user`,
   `slots: [header-left]`). **Not visually confirmed in a running
   browser** - no Node/prebuilt dashboard dist was available to actually
   load a browser session this pass. Also copied into the live profile
   at `D:\north-forge-agent-data\profiles\kyocera\plugins\` for
   immediate effect (will also arrive via the normal `plugins/`
   top-level payload on any future `hermes profile install`/update,
   since `distribution.yaml` declares no `distribution_owned`
   allowlist). Commit `966708b`. **Recommend Kenneth extend this file's
   own Zone A list to explicitly include `plugins/**`, same as the
   2026-09-12 deploy-console precedent.**

## Zone B findings (not fixed - reported only)

- **`skills/flush/SKILL.md` / `skills/switch/SKILL.md`** need an
  `aliases:` frontmatter field (`aliases: [clr]` / `aliases: [fl]`) to
  actually register `/clr` and `/fl` as slash commands. Root cause (no
  alias mechanism existed at all for skill commands) is fixed at the
  engine level in `north-forge-agent`'s `agent/skill_commands.py`
  (`CHG-2026-09-14-005` there) and tested, but doing nothing until these
  two files get the one-line frontmatter addition. Both files carry
  their own "never rewrite... flag it to the Blacksmith" instruction, so
  this is a flag, not a fix.
- **`skills/menu/SKILL.md`** and **`.hermes.template.md`**'s
  `{{COMMAND_MENU_BLOCK}}`/`{{AGENT_NAME}}` templating - both already
  flagged stale in this repo's own `CHANGELOG.md` (2026-09-11 entry);
  confirmed again this pass while answering the skill-ordering question
  (see session report) - `{{COMMAND_MENU_BLOCK}}` is genuinely orphaned
  (nothing has generated `.hermes.md` from it since the launcher that
  did was retired), and `menu/SKILL.md`'s table still only lists the 11
  Kyocera shortcuts with no native-Hermes-command ordering applied. Not
  re-fixed here (already an open item), just re-confirmed with current
  evidence.
- No new Zone B content issues found beyond what was already on record.

## Commits made this session

- `56b43be` - kb-builder: gitignore the drafts folder it writes into the working tree
- `6376858` - Zero-Touch-Deploy.ps1: simplify the capacity gate (no behavior change)
- `966708b` - Add a dashboard plugin crediting Hermes Agent beside its own brand mark
- `7fb12aa` - CHANGELOG: document the kb-drafts, dashboard-attribution, and Zero-Touch-Deploy fixes

## Uncertain / flagged for primary GPT review

- The new `plugins/` top-level folder has no explicit zone assignment in
  this file (see Zone A section above) - treating it as Zone-A-equivalent
  by the same "mechanical glue, no field-support content" reasoning
  already used for `Advanced/deploy-console/`, but flagging rather than
  quietly assuming.
- The dashboard-attribution plugin is verified at the discovery/
  registration layer only (real backend call against the live profile),
  not visually in a rendered browser session - no Node.js/prebuilt
  `web_dist` was available in this environment to actually launch the
  dashboard. Recommend a quick visual check before considering this
  fully closed.
- A related, more root-level dashboard bug was already on record from
  `SANDBOX_TEST_ARCHIVE_RESYNC_2026-09-14.md` (Kyocera's dashboard theme
  file lives at `profiles/kyocera/dashboard-themes/`, one level deeper
  than the top-level `HERMES_HOME` the dashboard's theme discovery
  actually reads, so the Kyocera-branded palette/logo asset likely still
  never applies on a real launch). Not addressed this pass - the two
  task files handed to this session asked only for the attribution
  caption, framed explicitly as "not to re-theme." The attribution
  plugin works regardless of that separate bug (it doesn't depend on the
  Kyocera theme being active), but the theme-scoping bug itself is still
  open and not this session's fix.

## Status

Needs primary GPT review - the new `plugins/` top-level path and the
unconfirmed-live dashboard plugin both warrant a second look before
calling this fully closed.
