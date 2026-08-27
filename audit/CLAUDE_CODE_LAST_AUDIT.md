# Claude Code Session Audit

Timestamp: 2026-08-26 (drive-root audit)
Requested task: Kenneth pointed Claude Code at the root of the North Forge
thumb drive (`E:\`) and asked it to check/audit the contents and flag whether
any updates are needed. Broader than a normal in-repo session - this covers
the drive root and the `north-forge-agent-main` engine snapshot as well as
the `north-forge-hermes-edition` content repo.

## Files inspected
- Drive root `E:\` - contents: `north-forge-agent-main/`,
  `north-forge-hermes-edition/`, `System Volume Information/`. 232 GB drive,
  1.5 GB used, 230 GB free.
- `north-forge-hermes-edition/`: `git pull` (already up to date), `git status`
  / `git diff` (clean at start), `git log --oneline -15`, `git ls-files`
  (23 tracked files, all present).
- `.gitignore` - present, correctly ignores `.env`, `.forge-mode`,
  `.hermes.md`, `.hermes/` (verified with `git check-ignore -v`). Also
  ignores `skills/`. OK, no fix needed.
- `.env` - exists on the drive, contains a live `ANTHROPIC_API_KEY` (`sk-a...`).
  Not tracked (`git ls-files` confirms), correctly gitignored.
- `.env.example`, `launch-north-forge.bat`, `launch-north-forge.sh`,
  `provision-new-drive.ps1`, `setup-thumbdrive.ps1`, `toggle-mode.*` - read
  in full. None reference `north-forge-agent-main`; all install the engine
  from `hermes-agent.nousresearch.com`.
- `.hermes.template.md` markers (`{{MODE_BANNER_BLOCK}}`,
  `{{COMMAND_MENU_BLOCK}}`) vs generated `.hermes.md` - markers fully
  replaced, FULL-mode banner present, consistent with `.forge-mode` = `full`.
- `.hermes/skills/` (generated) - contains `sales-assist` + `kb-builder`,
  correct for FULL mode.
- `skills-source/` - two real files (`shared/sales-assist/SKILL.md`,
  `tsc-only/kb-builder/SKILL.md`); the six placeholders from NEXT_STEPS are
  not physically present yet, as expected.
- `README.md`, `CLAUDE.md`, `NEXT_STEPS.md`, `DEMO_PREP_BACKLOG.md`,
  `audit/CLAUDE_CODE_LAST_AUDIT.md` (previous audit - clean/routine
  session-start check) - all read.
- `hermes --version` / `hermes doctor` / `hermes skills list` - see below.
- Git history secret scan (`git log -p` on provision script + pattern grep
  over all revs for `sk-ant-`, `ghp_`, `github_pat_`, `AKIA...`) - clean, no
  secrets ever committed.
- `gh repo view` on both `kwalker7631/north-forge-hermes-edition` and
  `kwalker7631/north-forge-agent`.
- `north-forge-agent-main/` - top-level listing, size (1.4 GB), checked for
  `.git` (none), `node_modules` (none), real `.env`/`*.key` (none - only
  source files with "secret" in the name), `package.json` (name
  `hermes-agent`, upstream `NousResearch/Hermes-Agent`).

## Zone A changes made
None. No Zone A file (`launch-north-forge.*`, `toggle-mode.*`,
`setup-thumbdrive.ps1`, `.gitignore`) had a reproduced bug. All read as
correct.

## Zone C changes made
- `NEXT_STEPS.md` - marked two "Also outstanding" items DONE, each with a
  verified basis from this session:
  1. `KYO_KB_TITAN_v12_11_CONTACT_BLOCK_LOCKED.html` upload - the file is
     present at the repo root and tracked (commit `e7beb1f`); a later bullet
     in the same file already assumed it was added, so the "still to upload"
     bullet was stale.
  2. `kwalker7631/north-forge-agent` fork confirmation - `gh repo view`
     returns `isFork: true`, parent `NousResearch/hermes-agent`, so the
     `gh repo sync` engine-update path is valid.
- `DEMO_PREP_BACKLOG.md` - added item 7 recording the repo-visibility
  finding below (real finding this session; the backlog is the right home
  for a flagged-pending-decision item).

## Zone B findings (not fixed - reported only)
- **`README.md` line 20 vs reality: "This repo is private and not published"
  is FALSE.** `gh repo view` reports `visibility: PUBLIC` and an
  unauthenticated fetch of the repo URL returns HTTP 200 -
  `kwalker7631/north-forge-hermes-edition` is world-readable on GitHub right
  now. No credential is exposed by this (`.env` never committed; history
  scan clean), but all field-support content, the KYO_KB_TITAN locked
  template, Kyocera branding, the governance docs, and Kenneth's authorship
  are public. `README.md` is Zone B - not edited. The provisioning design
  (read-only PAT baked into `provision-new-drive.ps1`, the `gh auth` +
  token-generation ceremony in the README prerequisites) only makes sense
  for a private repo and is dead weight if public is intentional. Needs a
  Kenneth decision: flip to Private to match the docs, or accept public and
  strip the token step. Logged as DEMO_PREP_BACKLOG item 7.
- **`README.md` documents two overlapping entry points** without saying
  which is canonical: "Windows drive provisioning (recommended way)" points
  to `provision-new-drive.ps1` (clone/pull + launch), while "First-time
  setup" points to `setup-thumbdrive.ps1` (install engine + `.env` + doctor).
  They partly overlap (both handle Hermes install / `.env`). Not
  contradictory, but a first-time reader can't tell from the README whether
  to run one, the other, or both in sequence. Minor - flagging for a wording
  pass by the Blacksmith / Claude Project chat, not urgent.

## Drive-level findings (outside all zones - `E:\` root and engine snapshot)
- **`E:\north-forge-agent-main\` (1.4 GB) is an orphaned engine snapshot.**
  It is a "Download ZIP of main" copy of `NousResearch/hermes-agent`, not a
  git clone (no `.git`), so it can't be updated with `git pull` or
  `gh repo sync` the way the two-repo architecture describes. Nothing on the
  drive references it - every launcher/provision/setup path installs Hermes
  from `hermes-agent.nousresearch.com`. It also contradicts the documented
  architecture: `README.md` says "the Hermes engine itself is NOT in here"
  and `setup-thumbdrive.ps1`'s header explains the engine "installs locally
  rather than living on the drive itself" (exFAT can't hold venv symlinks; a
  Windows runtime won't run on Mac/Linux). It is 64x the size of the actual
  content repo (1.4 GB vs 22 MB) and, being a static snapshot, will silently
  go stale - the installed `hermes` CLI is already 117 commits ahead of
  upstream. Not deleted - Claude Code will not remove a folder off the drive
  root on its own. Kenneth's call: if it's a deliberate offline reference,
  fine (but date/label it and know it's frozen); if it's leftover from a
  manual download, it can be removed with no functional impact.
- **`.env` with a live Anthropic key sits in plaintext on the drive.**
  Correctly gitignored and never committed, so this is not a repo leak - but
  an audit of "the drive" should surface a working credential physically on
  it. The file's own header comment and `setup-thumbdrive.ps1` already warn
  about exactly this ("anyone holding the drive holds this key"). Fine if
  this is Kenneth's personal master/build drive; needs scrubbing (or a
  confirmed spend cap on the key) before this specific drive is handed to
  anyone. No backlog item exists for "scrub `.env` per physical drive before
  distribution" - candidate to add, left to Kenneth.

## Commits made this session
- (Zone C) `NEXT_STEPS.md` + `DEMO_PREP_BACKLOG.md` - see "Zone C changes
  made" above.
- (Zone A operational record) this audit report.
- Commit hash(es) recorded in the session-ending chat response.

## Hermes environment (informational - not this repo's content)
- `hermes` v0.20.5 (2026.8.19), install method git, install dir
  `C:\Users\kwalk\AppData\Local\hermes\hermes-agent`. "Update available: 117
  commits behind - run `hermes update`". Unchanged from the previous audit.
- `hermes doctor` - "All checks passed!" Warnings are all environment notes
  outside this repo's zones: SQLite 3.45.1 WAL-reset bug (`hermes update`
  recommended; `state.db` in rollback-journal mode, not exposed), Playwright
  Chromium not installed (`browser_*` tools hidden), various optional
  providers not logged in, no `GITHUB_TOKEN` in the hermes `.env` (60 req/hr
  hub rate limit).
- `hermes skills list --source local` - `kb-builder` + `sales-assist`, both
  `local` / `enabled`. Unchanged from the previous audit.

## Uncertain / flagged for primary GPT review
- **Repo visibility (top priority).** Confirm whether
  `north-forge-hermes-edition` being PUBLIC on GitHub is intended. The docs
  say private; if that's still the intent this needs a settings change by
  Kenneth, and the README/provision-script token ceremony should be
  reconciled either way. This is the one finding that looks like it needs
  action soon rather than eventually.
- **`north-forge-agent-main` on the drive** - is it meant to be there? If
  yes, what keeps it current, and does anything actually consume it? If no,
  confirm it's safe to delete so the next audit doesn't keep re-flagging it.
- The two Zone C "DONE" marks in `NEXT_STEPS.md` were judgment calls based on
  repo state + `gh` output - worth a glance to confirm the primary GPT
  agrees those items are genuinely closed and not just partially done.
- README dual-entry-point wording (minor) - noted above, no urgency.

## Status
Needs primary GPT review. Working tree was clean at start; Zone C docs
updated and committed per standing authorization; the PUBLIC-repo finding
and the orphaned 1.4 GB engine snapshot both need a Kenneth/Blacksmith
decision and were deliberately left unactioned.
