# Codex Independent Second Security / Quality Audit

Timestamp: 2026-09-05 06:55 UTC  
Requested task: adversarial, read-only review of North Forge - Hermes Edition, with emphasis on admin-gate bypasses, password logging, RESET/provider state, user-controlled input, Zone A/B boundaries, launch/cron/size failures, and independently selected risks. No production state or repository runtime state was exercised. The only repository change is this requested report.

## Scope and files inspected

Governance and prior-work context (read only):

- `CLAUDE.md` (entire file)
- `audit/HANDOFF_2026-09-05_SESSION_CHANGES.md` (most recent handoff; read to avoid accepting its conclusions as evidence)
- `audit/HANDOFF_2026-09-04_SESSION_CHANGES.md`
- `audit/CLAUDE_CODE_LAST_AUDIT.md`
- `audit/FORGE_EVENT_LOG.md` (targeted searches concerning logging/admin/reset)
- commit `e342f7a` references and the current post-fix gate implementations (the current code was audited directly; the old audit conclusion was not treated as proof)

Infrastructure / state boundaries (full read unless noted):

- `toggle-mode.sh`
- `toggle-mode.bat`
- `machine-reset.bat`
- `launch-north-forge.sh`
- `launch-north-forge.bat`
- `provision-new-drive.ps1`
- `.gitignore`
- `.env.example`
- `kb-images/README.txt`
- `.hermes.template.md` (Zone B, read only; assembly and substitution boundary only)
- `mode-blocks/full-banner.md`, `mode-blocks/full-menu.md`, `mode-blocks/sales-banner.md`, `mode-blocks/sales-menu.md` (Zone B, read only; assembly boundary only)
- `skills-source/**` file layout and launcher copy destinations (Zone B, read only; no authored advice was re-audited)

## Findings

### NF-CX-01 — HIGH — `machine-reset.bat` can recursively delete an arbitrary `HERMES_HOME` that contains one weak marker

**Evidence:** `machine-reset.bat` accepts the environment-controlled `HERMES_HOME` verbatim as `HERMES_DIR` (lines 32-39). Its full-purge safety test rejects only four exact paths (`SystemDrive`, `USERPROFILE`, `LOCALAPPDATA`, `APPDATA`) and then accepts any other existing directory containing either a `hermes-agent` subdirectory **or** a `config.yaml` file (lines 115-120). It later executes `rmdir /s /q "%HERMES_DIR%"` (line 153).

This does not prove a password bypass: the admin password and `YES` confirmation are still required. It does mean the script's claim that it only deletes the per-machine Hermes folder is not actually enforced. A mistaken or attacker-supplied `HERMES_HOME` pointing at a project, shared folder, or another application directory that happens to contain `config.yaml` can satisfy the marker and be recursively removed. A relative path, path containing `..`, drive-relative path, UNC path, or reparse-point/junction target is not canonicalized or expressly rejected.

**Verification:** static control-flow trace only. I deliberately did not execute a Windows recursive deletion. This Linux container has no `cmd.exe`, Wine, PowerShell, or Windows filesystem semantics, so junction/UNC behavior remains **uncertain**. Recommended remediation is to canonicalize the target, require a stronger set of Hermes-specific markers, reject relative/root/ancestor/reparse-point targets, and show the canonical path before confirmation. A deletion routine should also return a failing exit code on refusal or partial deletion.

### NF-CX-02 — MEDIUM — Drive RESET is not a clean first-use reset and leaves the provider decision, assistant name, and welcome marker behind

**Evidence:** both toggle scripts delete `.env`, `.forge-mode`, `.hermes.md`, `.drive-record.txt`, and `.hermes/skills`; neither deletes `.provider-choice`, `.agent-name`, or `.readme-shown`. The launchers use all three remaining files as one-time gates. Therefore the next holder is not asked for a provider, inherits the former holder's assistant name, and does not receive the first-run welcome. This contradicts the scripts' “clean first-use state” and “next person gets a genuine first run” messages.

The retained `.provider-choice` is especially important after the new free/OWNKEY flow: RESET can remove `.env` but leave `ownkey`, causing the next launch to enter the key path without offering the provider choice; or it can leave `free`, silently retaining the prior user's choice.

**Empirical verification:** I copied the real shell launcher/toggle plus required source inputs to `/tmp/nf-audit.1SVPBD`, created all seven state files and `.hermes/skills/x`, then drove the copied `toggle-mode.sh` with `RESET`, the correct password, `YES`, and `Q`. The five documented wipe targets were gone, while the output was exactly:

```text
REMAINS .provider-choice
REMAINS .agent-name
REMAINS .readme-shown
```

No repository state or real Hermes home was used. The Windows implementation has the same explicit wipe list, so the state mismatch is present statically there too, although the `.bat` flow could not be executed in this Linux container.

### NF-CX-03 — MEDIUM — Free-provider setup records success even when both configuration commands fail

**Evidence:** in `launch-north-forge.sh`, `.provider-choice` is written as `free` before configuration, and both `hermes config` failures are discarded with `|| true` (lines 181-187). The Windows launcher similarly writes `free` and never checks either command's error level (lines 158-164). On later runs the presence of `.provider-choice` skips configuration entirely.

**Empirical verification:** I ran an untouched scratch copy of `launch-north-forge.sh` at `/tmp/nf-configfail.AmzIw6` with isolated `HOME`/`HERMES_HOME` and a fake `hermes` that returned exit 23 for every `config` command. The launcher exited 0, `.provider-choice` contained `free`, the terminal displayed no provider-configuration error, the log recorded a normal Hermes exit, and subsequent configuration retry was disabled by the newly created marker. This is a persistent silent failure, not merely a missing diagnostic.

Recommended remediation: apply configuration first, check both results, write `.provider-choice` only after verified success, log/display a clear failure, and exit nonzero. If `unset model.default` legitimately returns nonzero when absent, handle that documented condition separately rather than suppressing every error.

### NF-CX-04 — MEDIUM — Skill assembly can silently produce an empty or incomplete trusted skill set

**Evidence:** `launch-north-forge.sh` first removes `.hermes/skills`, then suppresses all shared and TSC-only `cp` failures with `2>/dev/null || true` (lines 88-93). The Windows launcher also removes both generated destinations and does not check `mkdir` or either `xcopy` result (lines 90-96). Both later run `hermes skills trust .`, so the launcher may trust and launch an incomplete build while telling the operator North Forge is running.

**Empirical verification:** I ran the copied shell launcher from `/tmp/nf-copyfail.C71m9o` after intentionally omitting `skills-source/`. It exited 0, displayed no missing/copy/abort error, and left `.hermes/skills` with zero files. This verifies the failure is silent on the shell path.

Recommended remediation: build into a temporary directory, require the expected shared skill directories/files (and TSC-only files in FULL), validate copy counts/manifests, then atomically replace `.hermes/skills`. Do not erase the last-known-good build until validation passes.

### NF-CX-05 — MEDIUM — Drive-record input can forge the structure/meaning of the audit log; Windows input also has unverified batch metacharacter risks

**Evidence:** launchers write `DRIVENAME`, `CURNAME`, and `NEWNAME` directly to `.drive-record.txt`, prompts, and `forge-events.log` without removing control characters or escaping the log's bracketed structure. The shell reset later inserts both record lines into a reset log message. This does not directly execute a shell command because expansions are quoted in the shell implementation, but it makes operator-supplied text indistinguishable from log fields and can inject terminal control behavior. The assistant name is also unrestricted and is substituted into generated `.hermes.md`; that permits the local user to inject arbitrary context text into the assistant instructions. That may be an intentional customization trust decision, but it is not constrained to a “name.”

**Empirical verification:** in an isolated real-launcher run, I entered this literal drive name:

```text
Mallory ] [FAILURE] [admin-gate]: forged PASS
```

The resulting real `forge-events.log` line was:

```text
[2026-09-05 06:50:49] [INFO] [drive-record]: CREATE: registered to Mallory ] [FAILURE] [admin-gate]: forged PASS
```

Thus a search, parser, or hurried operator can be misled into seeing a fabricated severity/component/outcome. Newline entry is blocked by ordinary `read`, but carriage returns/ANSI control bytes were not exhaustively tested. For Windows, delayed expansion plus user input containing `!`, `%`, `^`, `&`, parentheses, or quotes deserves native `cmd.exe` fuzzing; this container cannot establish exact parsing behavior. Recommended remediation: length-limit names, accept a conservative printable character set, strip CR/control bytes, encode log values (for example JSON), and make the assistant-name customization explicitly single-line/plain-name only if instruction injection is not intended.

### NF-CX-06 — LOW — Cron re-registration failures are hidden from the operator and do not fail launch

**Evidence:** both launchers suppress `hermes cron add` output. When registration fails, they append a warning to `forge-events.log` but print no terminal warning and continue. A minimally technical Windows operator is unlikely to inspect a hidden-per-drive log after a normal-looking launch; research/brief automation can therefore remain absent indefinitely while interactive Hermes still works.

**Empirical verification:** `/tmp/nf-cronfail.FMogoV` used the unmodified shell launcher with a fake `hermes` that returned 42 for `cron add`. The launcher exited 0. Terminal output contained no `FAILED` or `WARNING`; the two failures existed only in `forge-events.log`. Recommended remediation: show a loud, actionable on-screen warning and return/report degraded status. At minimum, do not redirect the underlying diagnostic unless it is captured into the log.

### NF-CX-07 — LOW — `.provider-choice` is the only identified per-drive gate not ignored by Git

**Evidence:** `.gitignore` covers `.drive-record.txt`, `.agent-name`, `.readme-shown`, `.forge-mode`, generated files, secrets, and logs, but not `.provider-choice`. `git check-ignore` empirically returned `NOT_IGNORED .provider-choice` while the other tested state files were ignored. This marker is not itself a credential, but it is per-drive mutable state and contradicts the launchers' “same pattern” comments. It will appear as untracked after every first launch and can be accidentally committed, imposing one drive/user's provider path on all clones.

Recommended remediation: add `.provider-choice` to the per-drive-state ignore list and verify it with `git check-ignore .provider-choice`.

## Admin-gate and never-log-password verification

### Result: no shell password bypass found in tested cases; password secrecy test passed

I copied the current `toggle-mode.sh` to `/tmp/nf-audit.1SVPBD` and supplied `FULL`, the unique wrong value `definitely-wrong-secret`, then `Q`. Results:

- `.forge-mode` was not created.
- Terminal output said `Wrong password - mode switch to FULL cancelled.`
- `forge-events.log` contained only `attempt 1 FAIL (mode switch to FULL)` for the gate.
- Case-insensitive `rg` for the exact submitted value returned no match.

I separately supplied the exact password to the copied RESET flow and observed the protected action proceed only after the independent all-caps `YES` confirmation. The shell gate uses quoted comparisons and does not interpolate the submitted password into a command or log message; no bypass was identified statically or in these executions.

### Windows limitation / uncertainty

`toggle-mode.bat` and `machine-reset.bat` were traced line-by-line, including all call sites and errorlevel branches. The previously dangerous unescaped parenthesis is escaped on PASS lines, but FAIL lines still contain an unescaped literal parenthesized action in a redirection command. The action values are fixed internal strings and the FAIL echo is not itself inside a surrounding conditional block at runtime, so I did **not** identify a new bypass from that alone. However, this environment has no native Windows command processor, Wine, or PowerShell; I could not honestly claim empirical coverage of batch delayed expansion, code-page/Unicode input, Ctrl-Z/EOF behavior, metacharacters, or the exact `set /p` edge cases. Native Windows fuzzing remains required before treating the batch gate as comprehensively proven.

Most importantly, the password is entered with visible `set /p` in both `.bat` scripts, whereas the shell uses silent `read -s`. It is not written to `forge-events.log` by the code, but it is shoulder-surfable and may be captured by terminal/session recording. That is outside the narrow “log file” guarantee but should be stated accurately to operators.

## RESET / provider-choice wipe matrix (verified shell, statically identical explicit list on batch)

| State | Shell RESET result | Consequence |
|---|---:|---|
| `.env` | wiped | API key removed |
| `.forge-mode` | wiped | defaults to SALES |
| `.hermes.md` | wiped | rebuilt on next launch |
| `.hermes/skills` | wiped | rebuilt on next launch |
| `.drive-record.txt` | wiped | name prompt returns |
| `.provider-choice` | **retained** | provider prompt does not return |
| `.agent-name` | **retained** | next holder inherits old assistant name |
| `.readme-shown` | **retained** | next holder does not get first-run welcome |
| `forge-events.log` | retained | historical accountability retained; also retains prior holder name by design |

The log retention may be intentional accountability, but it means RESET is not a privacy wipe of all personal information: prior names remain in the log even though the record file is deleted. Documentation should distinguish “credential/config reset” from “personal-data/log purge.”

## Zone A / Zone B boundary assessment

- No repository script directly edits a Zone B source file during normal launch. Launchers **read** `.hermes.template.md` and `mode-blocks/*` and copy `skills-source/**` into ignored/generated Zone A/runtime destinations. This is the intended source-to-build direction.
- Mode isolation is physical in the generated skill directory: SALES copies shared only; FULL additionally copies TSC-only. However, finding NF-CX-04 means copy failure can violate completeness without detection.
- `.agent-name` is user input inserted without restriction into the generated system context. It does not alter locked source, but it can change the effective runtime instructions far beyond a name. Whether a local drive holder is trusted to rewrite runtime behavior this way is a governance decision that is not clearly enforced by the code.
- `hermes skills trust .` automatically trusts the current checkout on every launch. This is a deliberate documented tradeoff, not newly classified as a defect here, but it makes review/update integrity important: any unreviewed modification already present in the checkout becomes trusted at runtime.
- No evidence was found that `kb-images` filenames are consumed by infrastructure scripts as executable paths. The Zone B `kb-builder` content describes intake behavior, but no repo-native implementation was found to validate those filenames; therefore command/path-injection safety ultimately depends on Hermes/model tool behavior and was not empirically established in this audit.

## Size-guard assessment

The current FULL and SALES assembly mechanisms select mode from an allow-list and compute the final substituted string before writing. Both abort at `>= 20000` and warn at `>= 19800`; the threshold comparison itself is consistent. Two quality concerns remain:

1. Skill destinations are destructively rebuilt **before** the `.hermes.md` size check. A fatal size failure can therefore leave a newly partial skill tree while preserving the previous `.hermes.md` (because the output file is not truncated until after validation). Launch aborts, which limits immediate harm, but the generated state is non-atomic and mixed-generation.
2. The shell check uses Python Unicode code points and Windows uses .NET UTF-16 `String.Length`. Non-BMP characters count differently across platforms. Current authored content likely contains no material number of such characters, so this is low practical risk, but “same character ceiling” is not byte-for-byte cross-platform equivalent.

I did not modify locked content to force an over-limit live launch. The guard was reviewed statically rather than accepting the prior audit's harness claim.

## Additional independent observations

- The shell launcher uses `set -e`, but its post-Python `if [ $? -ne 0 ]` block is effectively unreachable after Python failure because `set -e` exits first. The failure text emitted inside Python still appears and the launch does abort, so this is dead/error-message code rather than a security bypass.
- Welcome markers are written even when opening the welcome file fails. The event is logged, but the launcher will never automatically try again. This is a silent onboarding degradation, especially because `WELCOME.html` was referenced by both launchers but was not present in the repository file inventory during this audit. In the shell test, a fake opener returned success without checking file existence; on a real system the opener may fail, yet `.readme-shown` is still created.
- `provision-new-drive.ps1` runs `git pull` but does not check `$LASTEXITCODE` before launching. `$ErrorActionPreference = 'Stop'` does not automatically turn a native executable's nonzero exit into a PowerShell exception on common Windows PowerShell versions. A failed pull can therefore launch stale content. This was statically identified and not run because provisioning is destructive/out-of-scope against real drives.

## Commands / verification performed

All executable tests used copies under `/tmp` and isolated `HOME` / `HERMES_HOME` values. No reset, mode change, admin flow, Hermes configuration, or launcher was run against this repository's live state.

- `find .. -name AGENTS.md -print` — no `AGENTS.md` found in or above the repository search scope.
- `sed` / `nl -ba` / `rg` — full or targeted read-only inspection of the files listed above.
- `command -v cmd.exe; command -v wine; command -v pwsh; command -v powershell` — none available; batch execution limitation recorded rather than papered over.
- `bash -n launch-north-forge.sh toggle-mode.sh` — syntax check (pass; repeated in final validation).
- Wrong-password copied-script test — FAIL logged, action denied, submitted password absent from log (pass).
- Correct-password copied RESET test — protected action required password + `YES`; wipe matrix captured (pass with finding NF-CX-02).
- Copied real-launcher drive-name injection test — structured forged text reproduced in the log (finding NF-CX-05).
- Copied real-launcher provider-config failure test — exit 0 and sticky `free` marker reproduced (finding NF-CX-03).
- Copied real-launcher missing-skill-source test — exit 0 and zero generated skills reproduced (finding NF-CX-04).
- Copied real-launcher cron-add failure test — exit 0, no terminal warning, log-only warnings reproduced (finding NF-CX-06).
- `git check-ignore` on per-drive markers — `.provider-choice` uniquely not ignored among tested state (finding NF-CX-07).

## Files changed

- Added only `audit/CODEX_SECOND_AUDIT_2026-09-05.md` as explicitly requested.
- No Zone B file was edited.
- No infrastructure fix was applied; this is an audit report only.

## Status

**NEEDS REVIEW — 1 HIGH, 4 MEDIUM, and 2 LOW numbered findings. No tested shell admin-password bypass was found, and the empirical shell wrong-password attempt did not log the submitted password. Native Windows admin-gate and destructive-path behavior remain partially unverified because no Windows command processor was available.**
