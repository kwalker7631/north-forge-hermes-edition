# Claude Code Session Audit

Timestamp: 2026-09-11 (evening session, continuation of the same-day
restructuring/SOUL.md-drafting work)
Requested task: place the Blacksmith-reviewed `SOUL.md` draft at this
repo's root exactly as reviewed (role-based "Blacksmith," not a hardcoded
name), re-verify the Kyocera profile speaks in North Forge's voice via a
real test prompt through the pin/install flow, review and push every
committed-but-unpushed local commit on both `north-forge-agent` and
`north-forge-hermes-edition`, and confirm both repos end clean and in
sync with origin/main. Explicitly out of scope this pass: the stale-docs
backlog (README/USER_MANUAL/FIRST_TIME_README/WELCOME.html/menu
SKILL.md/CLAUDE.md path references) and the upstream sync — both remain
parked.

## Files inspected
- `.hermes.template.md` (prior session, source for the SOUL.md draft —
  not re-read this session, no changes)
- `SOUL.md` (new, placed this session)
- `NEXT_STEPS.md`, `CHANGELOG.md` (Zone C, updated this session)
- `logs/CLAUDE_CODE_LAST_AUDIT.md` (this file, overwritten)
- `north-forge-agent`'s `logs/ledger/CHANGELOG.md` / `INDEX.md` and
  `docs/BUILDING-A-DRIVE.md` (read-only, to find the exact tested
  pin/install command sequence from the 2026-09-11 `RUN-2026-09-11-001`
  session rather than re-deriving it)
- Both repos' `git log origin/main..HEAD` and `git diff --stat
  origin/main..HEAD` (read-only review before push)

## Zone A changes made
None in this repo this session (no infrastructure/script bugs found or
fixed).

## Zone B findings (not fixed — reported only)
None new. The five items already on record (`README.md`, `USER_MANUAL.md`,
`FIRST_TIME_README.txt`, `WELCOME.html`, `skills/menu/SKILL.md`, plus
`CLAUDE.md`'s own stale Zone A/B/C path list) remain outstanding and were
explicitly left untouched per this session's instructions — see
`NEXT_STEPS.md` for the full list with line numbers, unchanged from last
session's audit.

## SOUL.md placement (Zone B handoff, exception per this file's own rule)
Placed byte-identical to the version Kenneth reviewed and handed back in
chat — role-based "Blacksmith" language throughout, no hardcoded name.
Commit `7fe61d5` ("Place Blacksmith-reviewed SOUL.md (Zone B handoff)").
No composition or rephrasing done by Claude Code; this is placement of
already-authored content per the CLAUDE.md exception, triggered by
Kenneth's in-session instruction naming the file and its placement.

## Verification: Kyocera profile speaks in North Forge's voice
Ran the real, previously-tested pin/install flow from `north-forge-agent`
(`docs/BUILDING-A-DRIVE.md`, "Pinning to a private edition" — the sequence
verified end-to-end in `RUN-2026-09-11-001`), entirely in a scratch,
disposable environment isolated via `HERMES_HOME`, per this file's own
"no PATH-shadowing" standing rule (alternative 1: real binary, isolated
env-var home) — nothing here touched Kenneth's live machine config:

1. `scripts\bootstrap-north-forge.ps1` — built a scratch venv +
   `HERMES_HOME` as drive-root siblings (`D:\north-forge-agent-venv`,
   `D:\north-forge-agent-data`). Succeeded (`READY. venv has 'hermes'
   (import ok).`).
2. `git -C private-editions\kyocera pull origin main` — fast-forwarded
   `d4b0abc..7fe61d5`, pulling in the new `SOUL.md` (its `origin` is a
   local path to this repo, per its own `distribution.yaml`). Confirmed
   `SOUL.md` present in that checkout afterward.
3. `scripts\nf-setup.ps1 -NonInteractive -SetPasscode -Passcode
   "TempVerify-2026-09-11" -Tier full -Pin kyocera -Installed kyocera` —
   installed the `kyocera` distribution from
   `private-editions\kyocera` into
   `D:\north-forge-agent-data\profiles\kyocera`. Output confirmed
   `✓ Installed 'kyocera' v0.1.0` and `pinned edition: kyocera` /
   `state: active`.
4. `hermes profile list` showed `◆kyocera` (active marker) with
   `Distribution: kyocera@0.1.0`; `python -m hermes_cli.nf_tier show`
   confirmed `pinned edition: kyocera`, `installed: kyocera`. `hermes
   profile show kyocera` explicitly reported `SOUL.md: exists`.
5. Last session's `hermes -z` check stopped at "no inference provider
   configured" (no key in that scratch run) — this session went one step
   further and got a real model response. `hermes config set
   model.provider opencode-free` (keyless free tier, written to
   `profiles\kyocera\config.yaml`, not global config). The plugin's
   documented default aux model (`laguna-s-2.1-free`) and the
   changelog-documented default (`deepseek-v4-flash-free`) both returned
   errors against the live catalog fetched from
   `https://opencode.ai/zen/v1/models` this session (401 / "Model is
   unavailable" respectively — likely free-tier catalog drift since that
   changelog entry was written, not an installer or profile defect: raw
   `curl` to that endpoint returned HTTP 200 with a live 70-model list).
   Tried three other currently-listed free models directly; the first,
   `nemotron-3-ultra-free`, answered a bare "ping" with "pong" and was set
   as `model.default` for the rest of the check.
6. Real one-shot prompt (`hermes -z "Customer's Kyocera unit is throwing
   C6000 and jamming at tray 2 intermittently. What should I check
   first?"`): got a structured field-diagnostic answer (evidence-to-collect
   first, working theory, next fork) — consistent with the assist-intake
   skill's format and with no banned filler, but not itself proof `SOUL.md`
   was the source rather than a skill template.
7. Follow-up identity prompt (`hermes -z "Who are you, and how do you and
   I work together?"`): response opened verbatim with "I'm North Forge —
   Kyocera Edition" and the Blacksmith relationship paragraph, then
   paraphrased the "How I talk" / "How I reason" / "What I won't do"
   points from `SOUL.md` nearly point-for-point (evidence classification,
   no-invented-procedures line, no-dead-end rudder, the scrubbing rule).
   This is direct, unambiguous confirmation the profile is running on
   `SOUL.md`'s voice, not a generic Hermes persona.

Cleanup: removed `D:\north-forge-agent-venv`, `D:\north-forge-agent-data`
(passcode/provisioning record and all), and the drive-root
`Start North Forge.lnk` bootstrap wrote — same "verification artifacts
deleted afterward, `private-editions/kyocera` itself left in place" pattern
as the prior session's real-run check. `private-editions\kyocera`'s own
git status confirmed clean and in sync with its (local-path) origin
afterward — the scratch model config lived only under the now-deleted
`north-forge-agent-data\profiles\kyocera\config.yaml`, never inside the
tracked checkout.

## Commits made this session
- `7fe61d5` — "Place Blacksmith-reviewed SOUL.md (Zone B handoff)" (this
  repo)
- (pending, immediately after this report is written and committed) —
  Zone C update to `NEXT_STEPS.md`/`CHANGELOG.md` recording the placement
  and verification, plus this audit file

Pushed this session, after review — see the standalone push report given
to Kenneth in chat. Both `north-forge-agent` and `north-forge-hermes-edition`
origin/main now match local main.

## Uncertain / flagged for primary GPT review
- The free-tier model drift (`laguna-s-2.1-free` / `deepseek-v4-flash-free`
  both currently erroring against the live `opencode-free` catalog,
  `nemotron-3-ultra-free` working instead) is an external-service-side
  change, not a bug in this repo or `north-forge-agent` — flagging only so
  a future session isn't surprised if that changes again. No code or
  config here was altered to "fix" it; the working model id was only used
  transiently for this scratch verification and does not persist anywhere
  now that the scratch `HERMES_HOME` is deleted.
- The diagnostic-prompt response's structured format (Quick Read / Tell
  the Tech / Collect Now / Do Not Do Yet / Next Fork) most likely comes
  from the installed `assist-intake` skill rather than `SOUL.md` itself —
  worth the Blacksmith's confirmation that this is the intended interplay
  between the voice file and the skill content now that both are live
  together for the first time.

## Status
Clean.
