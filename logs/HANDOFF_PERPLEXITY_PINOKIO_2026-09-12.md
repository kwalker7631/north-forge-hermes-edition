# Handoff — Perplexity Computer session, Pinokio lab-install work

**When:** 12 September 2026, evening EDT
**From:** Perplexity Computer session with Kenneth C. Walker Jr.
**Repo:** `kwalker7631/north-forge-hermes-edition`
**Read this before touching `Advanced/PINOKIO.md`, `scripts/pinokio_lab_target.py`,
or `Advanced/deploy-console/Install-Pinokio-Lab.ps1` / `Remove-Pinokio-Lab.ps1`.**

---

## Short version

I built an admin-only Pinokio installer/uninstaller for a **fully separate**
lab disk, aligned to the PINOKIO.md/EXCALIBUR.md rules as they read at the
start of this session. I pushed it as `905ed8f`. **Three minutes later**, a
parallel Grok session with Kenneth pushed two more commits (`5040bee`,
`067e173`) that rewrote `Advanced/PINOKIO.md` around a *different* design —
Pinokio living on the **same drive** as North Forge, on a distinct
"256 GB NTFS learning stick" tier. That rewrite did not know my scripts
existed, and my scripts do not know that design exists. **They now
contradict each other and need one owner to reconcile them before anyone
ships a stick with Pinokio on it.**

---

## What I built (commit `905ed8f`)

- `scripts/pinokio_lab_target.py` — pure validator. Hard-refuses any target
  directory on a drive carrying a North Forge marker file
  (`north-forge.cmd`, `HOW_TO_START.txt`, `Start North Forge.lnk`, etc.,
  walked up to the drive root) — **no override flag**. Separately refuses
  anything under 200 GB free, warns under 500 GB. 10 tests, all passing.
- `Advanced/deploy-console/Install-Pinokio-Lab.ps1` — runs that check, then
  (if Pinokio is already installed) offers to point its `config.json` Home
  field at the validated target, backing the file up first. If not
  installed, just prints the path to paste into Pinokio's own first-run
  Home prompt.
- `Advanced/deploy-console/Remove-Pinokio-Lab.ps1` — runs Pinokio's
  registered Windows uninstaller if found, clears AppData/program folders,
  only deletes the Home data folder with `-RemoveHomeData` + confirmation.
- Small cross-links added to `Advanced/PINOKIO.md` and
  `Advanced/deploy-console/README.md`, plus a CHANGELOG entry.
- Design basis at the time: the PINOKIO.md I read said "Same 32 GB
  Excalibur stick as North Forge: No" and treated a large drive as
  *separate* from the North Forge stick entirely — so the validator's
  hard rule was "refuse any drive that has North Forge on it, period."

None of this was wired into `north-forge.cmd`, `bootstrap-north-forge.ps1`,
or `nf-setup.ps1` — it's only reachable from the admin console folder
directly, matching what Kenneth asked for.

---

## What landed right after (commits `5040bee`, `067e173`, Grok session)

`5040bee` **rewrote `Advanced/PINOKIO.md` completely** (my cross-link
addition is gone from the file — still recoverable from git history at
`905ed8f`, nothing destroyed) around a new two-tier model:

| Class | Size | Format | Pinokio | Who |
|---|---|---|---|---|
| Excalibur | 32 GB+ | exFAT | **No** | Manager first look |
| Learning | 256 GB | **NTFS** | **Yes, same drive** | Admin / lab |

On the 256 GB "learning" stick, Pinokio sits **on the same drive** as North
Forge: `pinokio-home\` and `pinokio-app\` live next to
`north-forge-agent\`, `north-forge-agent-venv\`, etc. It also added:

- `Advanced/deploy-console/Start Pinokio Lab.cmd` — a plain launcher that
  assumes Pinokio is already laid out under `pinokio-app\`/`pinokio-home\`
  at the drive root and just double-click-starts it.
- `skills/pinokio/SKILL.md` + `skills-source/shared/pinokio/SKILL.md` — an
  in-session `/pinokio` skill teaching the same-drive workflow.

`067e173` added `logs/HANDOFF_NEXT_AGENT_2026-09-12.md` — that session's
**own** handoff doc, written by a Grok session (not the "Claude AI on
BLACKSMITHFORGE" session referenced earlier in this project). Worth reading
in full; it lists its own open items (Excalibur build/smoke-test still
pending on Kenneth's admin PC, SCOPE-05 dead tests, F248 procedure not yet
a skill page, README link-test) that are independent of the Pinokio
conflict below.

---

## The concrete conflict — this is the part that needs a decision

`pinokio_lab_target.py`'s hard block (`blocked_north_forge_volume`) fires
on **any** drive that has a North Forge marker file anywhere from the
target up to the drive root, with no override. That is now exactly the
shape of the *intended* 256 GB learning stick — North Forge and Pinokio on
the same drive, on purpose. As written today:

- Running `Install-Pinokio-Lab.ps1` against the actual 256 GB learning
  stick the new PINOKIO.md describes will **hard-fail** with
  `blocked_north_forge_volume`, because North Forge's own launcher files
  are sitting right there at the drive root.
- Even without that, a 256 GB stick with North Forge (venv + data) and
  Pinokio's own footprint already on it will often have well under the
  200 GB free floor my script demands — a second, independent way it would
  refuse the exact target it's supposed to help set up.
- My cross-link in `Advanced/deploy-console/README.md` still reads
  "Pinokio on a *separate* lab disk (never this stick)" — that line is now
  stale against the current `Advanced/PINOKIO.md`, which describes
  same-drive as the primary design.

I did not silently patch this myself — which rule is correct (or whether
both are correct for two genuinely different disk sizes) is a real design
call, not a typo fix. Options, as suggestions only:

1. **Retire my scripts' scope down to a third tier**: a genuinely separate
   large admin/lab disk (not the 256 GB learning stick, not the 32 GB
   Excalibur stick) — rename/relabel clearly so nobody confuses it with
   `Start Pinokio Lab.cmd`'s same-drive flow, and drop the now-contradictory
   cross-link from README.md.
2. **Adapt the validator** to tell stick *classes* apart (e.g. by size or a
   marker specific to the 32 GB Excalibur build) instead of blanket-refusing
   any North-Forge-bearing volume, so it can also validate/patch
   `config.json` on a legitimate 256 GB learning stick.
3. **Keep both, documented as different paths**: `Start Pinokio Lab.cmd` +
   the `/pinokio` skill for the simple same-drive case; my scripts
   explicitly scoped to "you already have a big separate drive and want the
   safety check + config.json patch + clean uninstall" case.

Whoever picks this up should update `Advanced/PINOKIO.md` to state
whichever answer wins, then fix the README.md cross-link and (if option 1
or 2) adjust `pinokio_lab_target.py` and its 10 tests to match.

---

## Worth flagging on its own: three agents, same repo, no coordination

This is the second time this session that a parallel session (local Claude
Code earlier, now a separate Grok session) pushed work to `origin/main`
within minutes of mine, on the same feature area, with no shared lock or
claim mechanism. Nothing was lost — git history has everything — but it's
worth Kenneth deciding on some lightweight convention (a `WORKING_ON.md`,
a commit-message tag, or just checking `git log` immediately before
starting a named feature) if multiple agents keep working on this repo at
the same time.

---

## Still open from earlier this session (unrelated to Pinokio)

- `north-forge-agent/scripts/nf_sync_cron.py` (~line 125) still has the old
  buggy `"skills": entry.get("skills") or []` on `origin/main`
  (`123fd5f`, unchanged). The real fix exists only as 3 uncommitted-to-origin
  local commits on Kenneth's machine. Not touched this session — no exact
  diff available here, and touching it risks conflicting with those pending
  local commits. Kenneth should push those when back at his PC.

---

## Current state (for whoever reads this next)

- `north-forge-agent`: `origin/main` = `123fd5f` ("Add WHY_THIS_MATTERS").
- `north-forge-hermes-edition`: `origin/main` = `067e173` ("Handoff script
  for the next agent heading the project."), which includes my `905ed8f`
  plus the two Grok-session commits above. Full test suite: 21/21 passing.

## Recommended next action

Before anyone writes more Pinokio code: settle which of the three options
above is the real design, update `Advanced/PINOKIO.md` to say so plainly,
then reconcile `pinokio_lab_target.py` / `Install-Pinokio-Lab.ps1` /
`Remove-Pinokio-Lab.ps1` (or retire them) and fix the stale README.md
cross-link to match.
