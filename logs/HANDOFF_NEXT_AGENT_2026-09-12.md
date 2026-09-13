# Handoff — next agent heading North Forge

**When:** 12 September 2026, evening EDT  
**From:** Grok session with Kenneth C. Walker Jr.  
**Repos:**  
- Public chassis: `kwalker7631/north-forge-agent`  
- Private pack: `kwalker7631/north-forge-hermes-edition`  

You are taking the chair. Read this before you edit a README or a launcher.

---

## What this is

North Forge is a **portable technical-support assistant** for a service desk.
Public repo = chassis (Hermes fork, launchers, portable venv).  
Private repo = Kyocera TSC pack (skills, deploy console, philosophy).  
Teammate path = plug in stick → **Start North Forge** → talk like a coworker.

It is **not** a chatbot reskin. It is **not** stock Hermes with a banner.
Hermes Agent (Nous Research, MIT) is the runtime and is thanked **last**.

Audience: people who read Kyocera Blue Book I / II every week. Voice is
earnest, shop-floor, customer-first. Do not paste the pocketbooks into Git.
Do not lead with “AI.” Do not put live fault codes (F248, etc.) on the
public front door — those live in skills.

---

## Owner intent (do not lose this)

1. **The sale is use.** If they do not understand why it matters, they
   will not use it. No use → no feedback → the side project dies.
2. **Glory is a cleaner call**, not GitHub stars.
3. Close to **manager first-viewer handoff** (Excalibur drive).
4. Programming is on the side of the job. Docs cannot be flat.
5. Pinokio belongs on the **same 256 GB learning stick** as a lab, not
   on the 32 GB manager stick, not locked in AppData.

---

## Architecture (current)

Since 2026-09-11 the private repo is a **Hermes profile pack**, not a
standalone FULL/SALES product. Retired launchers: `archive/`.

```
USB
  Start North Forge.lnk
  HOW_TO_START.txt
  north-forge-agent/              public checkout
    private-editions/kyocera/     this private repo
  north-forge-agent-venv/
  north-forge-agent-data/         HERMES_HOME + admin hash
```

Admin builds sticks from `Advanced/deploy-console/` after one `gh auth login`.
Volume label: `FIRSTL-NORTH` (Greg Warhol → `GREGW-NORTH`).
Tiers: locked (basic) vs open (full). Pin: kyocera / penny / etc.

---

## Two stick classes

| Class | Size | Format | Pinokio | Who |
|---|---|---|---|---|
| Excalibur | 32 GB+ | exFAT ok | **No** | Manager first look |
| Learning | 256 GB | **NTFS** | **Yes** | Admin / lab |

Pinokio layout on the learning stick:

```
pinokio-home\     PINOKIO_HOME (no spaces)
pinokio-app\      Pinokio.exe
Start Pinokio Lab.cmd
```

A tiny AppData pointer may exist on the host. Product stays on the stick.
GPU stays on the host. 256 GB = NF + Pinokio + one or two apps, not a zoo.

---

## Docs map (do not flatten these)

Public: `README.md`, `START_HERE.md`, `WHY_THIS_MATTERS.md`,
`CAPABILITIES.md`, `PRODUCT.md`, `DOCS.md`, `LEARNING.md`, `editions/OEM.md`

Private: `README.md`, `CURRENT.md`, `PHILOSOPHY.md`, `WHY_THIS_MATTERS.md`,
`Advanced/deploy-console/DEPLOY.md`, `ADMIN_FIRST_TIME.txt`, `EXCALIBUR.md`,
`Advanced/PINOKIO.md`

In session: `/readme`, `/readme north-forge-agent`, `/readme kyocera`,
`/menu`, `/pinokio`

`/readme` skill must exist in **both** `skills-source/shared/readme/` and
`skills/readme/` (installable tree). Same pattern for `pinokio`.

---

## Zone rules (private repo)

`CLAUDE.md` / `AGENTS.md`: README and authored user-facing pages are
Zone B. Codex already refused to rewrite README without a handoff.
If you change voice, match WHY_THIS_MATTERS + PHILOSOPHY, not a fork pitch.

---

## Still open (do these, in order, unless Kenneth redirects)

1. **Excalibur build on his admin PC** — follow ADMIN_FIRST_TIME → DEPLOY
   → locked Kyocera → manager's `FIRSTL-NORTH` → smoke-test on a second PC.
   Script: `Advanced/deploy-console/EXCALIBUR.md`
2. **Deploy console scripts** with owner field + `GREGW-NORTH` may still
   be ahead of or behind GitHub. Diff before you invent a third launcher.
3. **SCOPE-05** — nine unittest cases still look for retired
   `launch-north-forge.bat/.sh` and `scripts/hermes-drive.sh`. Park or
   rewrite them.
4. **Cron / research agents** — documented; not auto-scheduled by deploy.
5. **Pinokio on-stick** — documented + skill + `Start Pinokio Lab.cmd`.
   Not wired into the format-and-clone PowerShell as a checkbox yet.
6. **F248 shop procedure** (KX / V4 / spooler / U917 then U021/U024) lives
   in chat history, not necessarily as a skill page. Do not put it on README.
7. Public README link-test: `tests/docs/test_readme_links.py`

---

## Do not

- Lead with Hermes or “AI agent you can make your own.”
- Quote Blue Book pocketbooks into the repo.
- Put Pinokio or model zoos on the manager Excalibur stick.
- Format C: or treat AppData as the product home.
- Ask a teammate to run `git` / `gh`.
- Claim offline / GPU / booklet-print / database as shipped.
- Rewrite the whole README for churn (Codex SCOPE-01).

---

## Handoff line for Kenneth to paste

> Next agent: you own North Forge. Public chassis + private Kyocera pack.
> First job is the Excalibur drive for my manager unless I say otherwise.
> Read `logs/HANDOFF_NEXT_AGENT_2026-09-12.md` in the private repo.
> Then we keep walking.

Handoff zip from earlier tonight (hashes verified in session):  
`HANDOFF_2026-09-12_1939.zip` sha256 `7576f76c02fff08e2502216c1dbfec01efc1d043f72bd45be2fddccf96d537fe`
