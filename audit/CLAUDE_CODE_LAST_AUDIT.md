# Claude Code Session Audit

Timestamp: 2026-09-04 (session following the "authorship/versioning" session
recorded at commit `4138ec5`)
Requested task: Kenneth asked for pure reconnaissance (no fixes) into the
authentication/provider landscape for this Hermes install, for the primary
GPT to author onboarding guidance from: (1) enumerate every provider/API
this install can use, (2) determine free-tier vs paid-only for each, (3)
specifically trace whether `claude-fable-5` (the model that threw a
credits-required error) is a default/fallback a fresh user could land on
without deliberately choosing it, (4) check what the real first-run setup
flow requires before Hermes will launch at all, (5) report back as a table.
No commits or fixes were requested for this task itself; this audit report
is written/committed only because CLAUDE.md's audit-report requirement is
unconditional every session, not because the recon task asked for it.

## Files inspected

- `CLAUDE.md` (re-read per Session Start Protocol, no changes since last
  session)
- `audit/CLAUDE_CODE_LAST_AUDIT.md` (prior report, full read - carried
  forward: primary GPT had not yet signed off on the "live approval of
  drafted Zone B text" pattern from the previous session; not re-litigated
  this session since this session did no Zone B work)
- `.gitignore`, `.env.example` (repo's own, Zone A - confirms the repo's
  onboarding narrows to a single documented variable, `ANTHROPIC_API_KEY`)
- `launch-north-forge.bat` (full read - this is where the real first-run
  gate lives)
- `FIRST_TIME_README.txt` (Zone B, read-only - confirms end-user-facing
  instructions say nothing about model/provider choice or credits)
- `skins/north-forge.yaml` (grepped for model/provider keys - none found;
  the skin does not set any model default)
- `.hermes.template.md` (Zone B, read-only - grepped for model/provider
  references; confirms model choice is explicitly left to "this instance's
  `hermes model` config," not hardcoded by North Forge content)
- `~/AppData/Local/hermes/.env` (machine-local, not repo content - the
  generic Hermes install's full provider template; read with values
  redacted to enumerate which providers exist and which env vars, if any,
  are actually uncommented/active)
- `~/AppData/Local/hermes/config.yaml` (current) and
  `config.yaml.bak.20260904_221401` (pristine pre-setup snapshot from this
  machine's install, ~14 minutes before the recon session started) -
  compared to determine whether `claude-fable-5` was ever the true
  out-of-box default
- `~/AppData/Local/hermes/logs/agent.log` and `logs/errors.log` (grepped for
  `credit|claude-fable|payment` - this is what surfaced the exact
  `credits_required` API error body and the "auto" fallback chain behavior)
- `~/AppData/Local/hermes/provider_models_cache.json` and
  `models_dev_cache.json` (read-only - to get the catalog metadata Hermes
  itself has cached for `claude-fable-5` and to confirm which providers
  publish genuinely keyless/free model lists)
- `hermes doctor`, `hermes skills list --source local`, `hermes model
  --help`, `hermes auth --help`, `hermes setup --help` (read-only CLI
  introspection)
- Attempted but blocked by the Claude Code auto-mode classifier (treated as
  sensitive-credential reads, not retried or worked around): `cat
  ~/AppData/Local/hermes/auth.json`, `hermes auth list`, `hermes auth
  status anthropic`. No auth secrets were read this session by any method.
- git: `git pull`, `git status`, `git diff`, `git log --oneline -5`

## Zone A changes made

None. This was a pure read-only reconnaissance session; no Zone A file was
modified.

## Zone B findings (not fixed - reported only)

None flagged this session beyond what's already on record from prior
sessions (see prior audit's open items 2 and 4, not re-investigated here).
One observation worth flagging for awareness rather than as a "finding":
`.hermes.template.md`'s line 5 ("Model provider per this instance's `hermes
model` config") is accurate but, combined with this session's discovery
that `hermes model`/setup can land a user on a credits-gated model with no
visible warning, means the template's silence on model choice is a gap a
Blacksmith may want to close with an explicit warning line - not a
correctness bug in the file as written, so not treated as something
requiring a fix, just flagged for awareness.

## Commits made this session

- (this audit report only, committed after this report was written - see
  git log for hash; Zone A / operational-record action, standing
  authorization, no separate go-ahead required)

## Reconnaissance findings (delivered to Kenneth/primary GPT in chat, full detail)

### 1. `claude-fable-5` default-model finding (the specific item flagged as
   worth its own priority regardless of the rest of the task)

- The **pristine, pre-setup** config snapshot for this machine
  (`config.yaml.bak.20260904_221401`, timestamped ~14 minutes before any
  interactive setup ran) shows Hermes's own generic out-of-box default is:
  `model.default: "anthropic/claude-opus-4.6"`. This is NOT claude-fable-5.
- The **current** `config.yaml` on this machine shows `model.default:
  claude-fable-5`, `model.provider: anthropic`. This change happened
  between the 22:14:01 backup and 22:18:55 (first log line referencing
  claude-fable-5 as the active model) - i.e., during this machine's initial
  interactive `hermes setup`/`hermes model` run, not as a silent/automatic
  fallback Hermes chose on its own without any interactive step.
- However, once selected, `claude-fable-5` behaves unlike a normal metered
  Anthropic model. Live error from `logs/errors.log` /
  `logs/agent.log` (request e.g. `req_011CejWCL9g3SfgqZEGP2E97`):
  `HTTP 429 rate_limit_error`, body includes `"error_code":
  "credits_required"`, `"model_display_name": "Fable"`,
  `"disabled_reason": "out_of_credits"`,
  `"exhausted_included_allowance": false`,
  `"has_chargeable_saved_payment_method": true`,
  `"can_user_purchase_credits": true`, and a user-facing notice: "You're
  out of usage credits" / "Buy more to keep using Fable or switch models to
  continue this chat."
- Critically, `models_dev_cache.json`'s catalog entry for `claude-fable-5`
  shows completely ordinary-looking metadata (`"cost": {"input": 10,
  "output": 50}`) in the exact same shape as every other Anthropic model in
  that cache (claude-opus-4.6, claude-sonnet-5, etc.). **Nothing in the
  catalog data a model picker would show distinguishes Fable as
  credit-gated rather than standard pay-per-token** - a user (or an
  automated picker UI) has no way to tell these apart before hitting the
  429 mid-conversation.
- Also notable: this install's "auto" auxiliary fallback chain (used for
  background tasks like title generation) automatically tries `anthropic`
  -> `openrouter` -> `nous` -> `local/custom` -> `api-key` with **no user
  key configured for openrouter or nous on this machine** (`.env` has no
  `OPENROUTER_API_KEY` set; `hermes doctor` lists Nous Portal as "not
  logged in"), and BOTH of those also failed with their own
  "payment / credit error" (`logs/errors.log`, 22:26:07 and 22:28:46).
  This means Hermes ships some kind of built-in/shared default route to
  OpenRouter and Nous that requires no user credential at all, and on this
  install that shared route is also currently exhausted. This is a
  separate, real finding from the Fable default-model issue: even the
  automatic multi-provider fallback path had no working option on this
  specific machine at the time of this session.
- **Open question, not resolved this session** (flagged for
  Blacksmith/primary-GPT follow-up, not asserted as fact): this machine's
  `anthropic` provider is authenticated via *something* other than a plain
  `ANTHROPIC_API_KEY` env var - grep of the active (uncommented) lines in
  `~/AppData/Local/hermes/.env` found no `ANTHROPIC_API_KEY` set at all,
  yet `hermes doctor` reports "API key or custom endpoint configured" and
  requests are actually reaching `https://api.anthropic.com`. The most
  likely explanation is OAuth-style credentials stored in `auth.json`
  (blocked from direct read this session, see below) rather than the
  plain console API key that North Forge's own `.env.example` instructs
  field technicians to obtain and paste in. **It is not confirmed whether
  a plain pay-per-token console API key (the kind North Forge's own
  onboarding asks for) would hit the same `credits_required` wall on
  Fable, or whether that wall is specific to whatever OAuth/subscription
  auth this particular dev machine happens to have.** This distinction
  matters a lot for onboarding guidance and should be verified directly
  (e.g. by testing Fable against a real freshly-created console API key)
  before the primary GPT asserts either way in field-facing guidance.

### 2. First-run setup flow (what a new user is actually required to do)

- `launch-north-forge.bat` hard-gates on exactly one thing:
  `ANTHROPIC_API_KEY` present in `.env` and at least 30 characters long
  (a length heuristic to catch the placeholder/a short paste). If missing
  or too short, it copies `.env.example` to `.env`, opens Notepad, and
  exits - it will not launch Hermes at all without this.
- No other provider is ever offered, mentioned, or checked by the launch
  script - even though the generic Hermes `.env` template (not part of
  this repo) lists ~25 other providers including a genuinely free, keyless
  one (`OpenCode Free`, see below). A field user following only this
  repo's own `.env.example` and `FIRST_TIME_README.txt` would never learn
  any alternative to a paid Anthropic API key exists.
- `FIRST_TIME_README.txt`'s only guidance for any error at all is "tell
  your team lead exactly what it said" - there is no in-repo explanation
  of what a `credits_required` error means or how it differs from a
  regular key problem, so a field tech who gets a working key past the
  launch-script gate could still hit the Fable wall on their first real
  question with zero actionable guidance in front of them.
- Net effect: yes, an Anthropic API key is currently a **hard requirement**
  to launch this repo's onboarding path at all, regardless of provider
  choice - the repo's own onboarding does not expose the
  provider-choice flexibility Hermes itself supports.

### 3. Provider/API landscape table

Free tier = can a brand-new user use it with zero payment method on file,
not just "has a free trial that will ask for a card." Status is specific
to *this* machine's install, not a claim about the repo's intended design.

| Provider | Free tier available | Setup complexity (non-technical user) | Status in this install |
|---|---|---|---|
| Anthropic (native `anthropic` provider) | N for ordinary use (pay-per-token console key); the currently-selected `claude-fable-5` model specifically needs a separate purchased "usage credits" allowance on top of that | Low - this repo's launch script fully automates the `.env` copy + Notepad prompt + key-length validation; it's the *only* provider this repo's onboarding ever asks about | Already configured (auth reaches api.anthropic.com), but current default model is out of usage credits and every request fails |
| OpenRouter | Partial - OpenRouter's own free-tagged (":free") models need only a free account, no card; NOT the same as the shared/default route this Hermes install auto-tries | Low-moderate - free signup + copy one key | Not configured via `.env` (`OPENROUTER_API_KEY` unset; `hermes doctor`: "not configured"); also auto-tried as a fallback with no user key and failing on a payment/credit error from whatever default route Hermes uses |
| Nous Portal (Nous Research's own OAuth, `hermes setup --portal`) | Unverified from repo alone - no pricing info found locally | Low - browser OAuth, no key to copy/paste | Not logged in on this machine; also auto-tried as a fallback and failing on a payment/credit error |
| xAI (OAuth) | N - `hermes doctor`'s own text says to "Select xAI Grok OAuth (SuperGrok / Premium+)," i.e. requires a paid X subscription tier | Moderate (OAuth login, but gated behind a paid X plan) | Optional, not logged in, unused |
| MiniMax (env key or OAuth) | Unverified from repo alone | Moderate (account + key, or OAuth) | Optional, not configured, unused |
| OpenAI Codex auth (OAuth via `hermes auth`) | N in practice - Codex access normally requires a ChatGPT/OpenAI account with a paid plan | Moderate (OAuth login) | Optional, not logged in, unused |
| Discord (bot token) | N/A - this is a messaging channel/integration, not an LLM backend | Moderate (create a Discord bot, get a token) | Optional, `DISCORD_BOT_TOKEN` unset, unused |
| OpenCode Free | **Y - confirmed genuinely free and keyless.** No account, no API key; requests sent anonymously; confirmed live in `provider_models_cache.json` (`"opencode-free": {"fp": "keyless:opencode-free", "models": [...several "-free" ids...]}`) | **Lowest of all options** - zero configuration, just run `hermes model` and pick "free" | Available, not selected/used on this install |
| Google AI Studio / Gemini | Y (Google AI Studio's published free tier - general knowledge, not confirmed from local files) | Low-moderate (free Google account + AI Studio key) | Optional, not configured |
| Hugging Face Inference Providers | Y - repo's own `.env` comment: "Free tier included ($0.10/month), no markup on provider rates" | Low-moderate (free HF account + token with the "Make calls to Inference Providers" permission) | Optional, not configured |
| Groq | Y for what it's used for here - repo's own comment: "free tier — used for Whisper STT" | Low | Optional, not configured; only wired for voice transcription in this install, not text chat |
| Qwen (OAuth, reuses local Qwen CLI login) | Unverified from repo; Qwen has a public API free quota historically but that's general knowledge, not confirmed here | Moderate-high - requires a separate `qwen auth qwen-oauth` step outside Hermes entirely | Optional, not configured |
| Fireworks, NovitaAI, z.ai/GLM, Kimi/Moonshot, Arcee AI, DeepInfra, Xiaomi MiMo, Upstage, Ramp Router, Nebius, Tencent TokenHub/TokenPlan, OpenCode Zen, OpenCode Go | N for all - each is explicitly documented in its own `.env` comment as pay-per-use or subscription (e.g. OpenCode Go: "$10/month subscription") | Moderate (account + API key each) | Optional, none configured, unused |

## Uncertain / flagged for primary GPT review

1. **Whether a plain console `ANTHROPIC_API_KEY` (the credential North
   Forge's own onboarding asks a field tech to get) is subject to the same
   `credits_required` wall on `claude-fable-5`, or whether that wall is
   specific to this dev machine's actual (unconfirmed) OAuth-style auth.**
   This is the single most important open question before writing
   field-facing guidance - if a real console key also hits this wall on
   Fable, the guidance needs to say "don't pick Fable"; if it doesn't, the
   guidance only needs to cover what happens on machines set up the way
   this one was.
2. `auth.json` and `hermes auth list` / `hermes auth status anthropic`
   were blocked by the Claude Code auto-mode classifier as sensitive-
   credential reads. I did not attempt to work around this - flagging it
   here in case the primary GPT or Kenneth wants to inspect auth method
   directly themselves (e.g. via `hermes auth status anthropic` run by a
   human, or asking Kenneth what auth flow he actually used when setting
   this machine up around 22:14-22:18 today).
3. Whether `hermes setup`'s interactive model-selection step presents
   `claude-fable-5` in a way that makes it an easy accidental pick (e.g.
   listed first, marked "recommended," etc.) was **not** tested this
   session - doing so would require driving the interactive wizard, which
   risks mutating this machine's real config for a recon-only task. If
   this matters for the onboarding guidance, it should be tested
   deliberately (ideally on a disposable profile) rather than inferred.
4. Everything flagged as open in the prior (`4138ec5`) audit was not
   re-investigated this session (Zone B live-approval-pattern sign-off
   still outstanding) - this session did no Zone B work, so nothing new to
   add there.

## Status
Clean - reconnaissance-only session, no Zone A or Zone B changes, findings
delivered to Kenneth in chat for relay to the primary GPT. One real
onboarding hazard confirmed (`claude-fable-5` default-model credits trap)
with one important open question (item 1 above) that should be resolved
before the primary GPT writes prescriptive field guidance around it.
