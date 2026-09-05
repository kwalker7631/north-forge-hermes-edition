# Codex Full Sandbox Re-Audit

Timestamp: 2026-09-05 19:10 UTC  
Requested task: Update Codex logging governance, investigate the real `partial or damaged .hermes-home` field failure, re-audit the end-to-end sandbox and setup flow, review simplification opportunities, and improve install-stage diagnostics.

## Scope and files inspected

Current root `AGENTS.md` was read before work began. The report location is `logs/`, not the retired `audit/` path. I also read `CLAUDE.md` to apply its authority zones.

Inspected implementation and tests: `launch-north-forge.bat`, `launch-north-forge.sh`, `provision-new-drive.ps1`, `scripts/ensure-hermes.ps1`, `scripts/ensure-hermes.sh`, `scripts/hermes-drive.ps1`, `scripts/hermes-drive.sh`, `scripts/assemble-skills.ps1`, `scripts/drive-reset-safety.py`, `scripts/machine-reset-safety.ps1`, `scripts/name_validation.py`, `toggle-mode.bat`, `toggle-mode.sh`, `machine-reset.bat`, `full-drive-reset.bat`, `full-drive-reset.sh`, all files under `tests/`, `.gitignore`, `.env.example`, `WELCOME.html`, `kb-images/README.txt`, and the relevant prior reports in `logs/`.

Zone assessment: all changes are Zone A infrastructure/tests, Codex governance, or this required operational report. No Zone B authored field-support content was changed.

## Executive findings

- **HIGH — current interruption recovery remains a real support gap.** The historical launcher write probe explains a genuinely fresh drive failing immediately in the old revision, but it is not the only route. Current code deliberately creates an incomplete marker and staging directory before invoking the installer. Power loss, unplugging the drive, terminating the terminal, installer crash, antivirus removal of `hermes.exe`, or cloning the drive during installation can leave state that the next launch rejects. The refusal is safe, but its manual hidden-folder cleanup instructions are not appropriate for a non-technical field operator.
- **MEDIUM — install logs previously covered only installer output.** They did not explicitly record setup start, staging, installer acquisition/invocation, validation, activation, completion, or the exact last completed stage before an abrupt stop. Both platform guards now write those stage records.
- **MEDIUM — the old error always pointed at `install-logs`, even when no install log existed.** Both guards now say plainly when no Hermes install log exists and explain what that means.
- **LOW — setup has several first-run actions but only three ordinary user decisions.** Drive owner, assistant name, and provider are reasonable decisions, but the owner and assistant-name prompts could be presented as one setup screen. OWNKEY intentionally requires a save-and-relaunch cycle. Changing that UX should be reviewed with Kenneth before implementation.
- **CLEAN — drive isolation, mode assembly, cron self-healing, RESET safety boundaries, provider persistence, welcome retry behavior, and generated-skill atomic replacement remain sound in the tested code paths.**

## Part 1 — exact safety-gate states and real failure analysis

### State enumeration from the actual guards

The Windows and POSIX guards implement the same three-way gate, with platform-specific executable locations.

1. **Valid:** `.hermes-home` contains both:
   - a Hermes executable in an accepted location; and
   - `.hermes-home/hermes-agent/pyproject.toml`.
   Windows accepts `Scripts/hermes.exe`, `bin/hermes.exe`, or root `hermes.exe`. POSIX accepts executable `bin/hermes`, root `hermes`, or `hermes-agent/hermes`. A valid home wins even if a stale marker/staging path also exists; the guard returns success immediately.
2. **Partial or damaged:** the valid check fails and **any one** of these exists: `.hermes-home`, `.hermes-install-staging`, or `.hermes-install-incomplete`. This includes an empty home, a home missing its executable, a quarantined executable, a home missing `pyproject.toml`, a staging directory left at any stage, or a lone marker.
3. **Genuinely fresh:** the valid check fails and none of those three paths exists. Only this state enters installation.

The launcher-level write probes now create a random file in the repository root and remove it. They no longer create `.hermes-home`, so current fresh-drive launch does not self-trigger the damaged-state gate.

### Was the E: failure only stale pre-fix state?

**No.** If the real `E:\north-forge-hermes-edition` contained only an empty `.hermes-home` created before the root-level probe fix, stale pre-fix state is the most likely explanation for that specific incident. The exact contents and timestamps of that field drive were not available in this Linux environment, so that attribution cannot be proved here.

The same visible failure is reachable in current code:

- after the marker or staging directory is created and before activation completes, a power loss, drive removal, terminal kill, or installer crash leaves the marker/stage;
- antivirus quarantine of the only accepted executable turns a formerly valid home into an invalid existing home;
- a filesystem-level clone taken during installation can capture marker/stage or an incomplete home;
- a normal `git pull` does **not** create this condition because the runtime paths are ignored/untracked, but an interrupted repository provisioning operation can leave a repository with missing launcher/support files before the Hermes gate is reached.

### Specific recovery fix recommended for review

Do not blindly delete an existing `.hermes-home`. Add a plain-language recovery dialog when invalid state is detected:

```text
North Forge setup did not finish last time.

[R] Try setup again (recommended)
[K] Keep the unfinished files for support
[C] Cancel

Help: “Try setup again” moves the unfinished files into
install-logs/recovery-YYYYMMDD-HHMMSS before starting over.
```

Implementation should quarantine, not destroy: atomically rename invalid `.hermes-home` and `.hermes-install-staging` into a timestamped recovery folder, retain existing logs, remove the marker only after quarantine succeeds, record every move, then restart the fresh-state path. If `.hermes-home` is valid, never offer cleanup. If any move fails, stop without overwriting. This makes the common choice one key while preserving evidence and avoiding unsafe deletion. This onboarding-flow change was **recommended, not implemented**, per the request to flag UX changes for review.

Help tooltip text proposed: **“Try setup again safely moves unfinished setup files aside; it does not touch Hermes installed on this computer.”** Shortcut: press **R** for recommended recovery, **K** to preserve files, or **C** to cancel.

## Part 2 — full sandbox end-to-end pass

### Empirical coverage performed

- **Cold fresh install:** `tests/test-drive-hermes-install.sh` installed a fixture engine into a path containing spaces, validated it, activated `.hermes-home`, removed the marker, and ran three commands through that home. The new log contained START, validation PASS, and COMPLETE.
- **Hard interruption:** the same test launched a deliberately sleeping installer, waited until the invocation-stage record was durable, sent `SIGKILL` to the setup process, and relaunched. The marker and stage remained, the log identified installer invocation as the last completed stage, and relaunch refused with recovery guidance. This proves the current-code reachability described above.
- **Installer failure / invalid download:** failure exit 17 and a successful download with non-runnable content both retained the marker and a diagnostic log rather than activating a partial home.
- **Provider choice:** `tests/test-free-provider.sh` exercised free-provider success, provider-set failure, unexpected default-unset failure with credential redaction, and the benign already-absent default. Static launcher review confirmed OWNKEY writes `.provider-choice`, creates `.env` from the template, checks for a plausible key, and requires relaunch after editing.
- **Drive record create/re-register:** name-validation tests cover creation, allowed input, defaults, and unsafe input; launcher inspection confirms it runs on every launch so the record can be updated rather than silently fixed forever.
- **Admin gate pass/fail/hint:** static inspection and the existing PowerShell/reset tests cover the exact password gate, failed-attempt logging without secret values, and the hint after three failures. Native Windows execution was unavailable here, so `.bat` UI behavior was not claimed as runtime-verified.
- **All three reset scopes:** Python/POSIX integration tests cover onboarding/content RESET preservation boundaries, drive-local full reset path safety, and machine-reset target safety. Static review confirmed the Windows equivalents separate content reset, drive Hermes purge, and host-machine Hermes purge.
- **Mode switch and skill assembly:** the assembly test ran sales/full builds, missing source, missing skill file, copy failure, and final-swap failure. It proved validated replacement and restoration of the prior build. The fixture was repaired to include the launcher’s required `name_validation.py` helper.
- **Cron registration and later relaunch:** Python cron tests cover each missing job, individual and combined registration failures, visible degraded-mode warnings, and clean-environment later job execution through the original drive wrapper.
- **WELCOME.html:** static asset tests and launcher tests confirm the file exists. POSIX onboarding in the two-drive test uses a successful opener. Inspection found Windows writes `.readme-shown` only after successful `start`; this patch brings POSIX into parity by writing it only after a successful opener.
- **Desktop shortcut:** POSIX onboarding creates a Desktop command in scratch HOME. Windows shortcut logic was statically checked for redirected Desktop resolution and success logging; no Windows runtime was available.
- **`kb-images/` intake:** repository/static tests confirm the intake directory and `_pending/.gitkeep` structure. The authored intake skill was inspected read-only; its field behavior was not invoked against real image/OCR services.
- **Two-drive isolation:** `tests/two-drive-hermes-isolation.sh` completed onboarding on two scratch drives, created separate configuration and cron stores, simulated later scheduler launches with a clean environment, and proved the shared host sentinels were byte-for-byte and timestamp unchanged.
- **Provisioning:** existing dependency-free PowerShell tests cover clone/pull refusal and two-drive target homes. They could not run in this Linux container because neither Windows PowerShell nor PowerShell Core is installed.

### Additional gaps and recommendations

- **MEDIUM — fixed:** POSIX welcome success did not create `.readme-shown`, despite its comment saying success was marked, so WELCOME reopened every launch on Mac/Linux. The launcher now creates the marker only after a successful opener, with a regression test.
- **LOW:** provider selection accepts every response other than `OWNKEY` as free. This is simple, but a typo such as `OWNKE` silently selects free. Recommend accepting only blank or OWNKEY and reprompting otherwise.
- **LOW:** skill intake can be structurally verified, but meaningful image/OCR results require service-level testing with representative field images. Add a fixture-based intake test or a documented manual acceptance matrix after the authored skill owner approves expected outputs.

## Part 3 — setup-process simplification review

### Brand-new user decision points, in order

If Kenneth runs `provision-new-drive.ps1`, preliminary decisions are: select the drive only when multiple non-system drives exist; stop and reformat if FAT/FAT32; then clone/update and launch. On a prepared drive double-click, the normal launcher sequence is:

1. **WELCOME auto-open** — automatic, no decision.
2. **Drive owner/name** — enter a name or accept the default.
3. **Desktop shortcut creation** — automatic, no decision.
4. **Mode** — defaults to SALES; no first-run prompt unless an administrator separately runs the toggle tool.
5. **Assistant name** — enter a name or accept North Forge.
6. **Drive-local engine install** — informational only; Ctrl+C can cancel.
7. **Provider** — Enter for free or type OWNKEY.
8. **OWNKEY only:** edit `.env`, save, close, relaunch, then choose a normal model later.
9. **Skin, trust, and two cron jobs** — automatic; failures are logged and cron failure permits interactive degraded mode.
10. **Working Hermes session.**

### Message quality

Most launcher errors provide an action in plain English. The damaged-home message is the clear exception: `.hermes-home`, `staging`, and `incomplete marker` are implementation terms, and “rename/remove” assumes comfort with hidden files. Kenneth’s field incident demonstrates that the safe refusal is not an actionable recovery experience for the intended operator. The enhanced missing-log message is now plain: it explicitly says no install log exists and why.

### Concrete simplifications recommended (not implemented)

1. Add the **R/K/C recovery screen** above. This is the highest-priority support simplification.
2. Combine drive-owner and assistant-name entry into one “First-time setup” screen with defaults and a short explanation; keep separate stored values internally.
3. Move drive-local engine installation before assistant naming. A failed engine install would then avoid asking personalization questions during a run that cannot finish. Keep drive owner first for accountability.
4. Keep SALES as the safe automatic default; do not add another first-run mode prompt.
5. Keep provider choice after engine validation because provider configuration requires the drive-local executable.
6. Validate provider input rather than treating typos as Enter/free.
7. After OWNKEY Notepad closes, validate the key and continue in the same launcher run instead of requiring a second double-click. Preserve an explicit Cancel option.

No onboarding prompts were combined, reordered, or removed in this patch because those are product/field-flow decisions requiring Kenneth’s review.

### Workflow preview

```text
North Forge first-time setup
----------------------------
Drive assigned to: [Kenneth________________]
Assistant name:    [North Forge____________]
Provider:          (*) Free   ( ) Own key

[Continue]  [Cancel]
Help: These names stay on this drive. You can reset them later.
```

Suggested shortcut: **Alt+C** to continue, **Esc** to cancel. Tip: in the OWNKEY editor, press **Ctrl+S** to save and **Alt+F4** to close it.

## Part 4 — enhanced setup/install logging

### Before this change

`install-logs` was created only on the genuinely-fresh install path after the launcher and guard’s initial validity/partial-state checks. The installer script was saved there, and installer stdout/stderr was redirected into `hermes-install-<timestamp>.log`. Existing valid homes produced no install log (correct: no install occurred). Partial-state refusal produced no new log. Failures before directory/log creation had no install log. There were no explicit records for staging start, installer invocation, validation result, activation, or successful completion. Therefore an abrupt-stop log could be empty or end in opaque installer output.

### Implemented coverage

Both `ensure-hermes` guards now record:

- setup START;
- write-check PASS;
- incomplete-marker and staging creation;
- installer download/copy start;
- installer invocation start;
- validation PASS or FAIL with checks identified;
- activation ABORT;
- completion after activation and marker removal.

The partial-state error now checks whether any install log exists. If none does, it says so plainly instead of directing Kenneth to an absent/empty diagnostic source.

### Interruption verification

Empirical POSIX cases now cover:

1. failure after installer invocation — log ends with explicit FAIL;
2. hard kill during installer execution — log’s last durable record says installer invocation started;
3. successful install — log includes validation PASS and COMPLETE;
4. pre-logging partial home — relaunch says no install log exists.

A literal power cut cannot write an “I was killed” line after power disappears. Recording each stage **before** beginning it is the reliable design: the last line says what had started when the interruption occurred. Windows has equivalent stage calls and static contract coverage, but needs a native Windows acceptance run for kill-at-download, kill-during-installer, and kill-before-activation.

## Verification performed

Passed:

- `pytest -q` — 19 tests plus 3 subtests passed.
- `bash tests/repository-hygiene.sh`
- `bash tests/test-drive-hermes-install.sh` — 6 scratch scenarios including SIGKILL during installer.
- `bash tests/test-drive-local-hermes.sh`
- `bash tests/test-free-provider.sh`
- `bash tests/test-launcher-hermes-home.sh`
- `bash tests/test-skill-assembly.sh` — 6 scenarios.
- `bash tests/reset-integration.sh`
- `bash tests/two-drive-hermes-isolation.sh`
- `bash -n launch-north-forge.sh scripts/*.sh tests/*.sh`
- `python -m compileall -q scripts tests`
- `git diff --check`

Environment limitation: no `powershell.exe`, `pwsh`, or `shellcheck` executable is installed, so native Windows/Pester execution and ShellCheck were unavailable. PowerShell behavior was reviewed statically and covered by Python contract assertions where practical.

## Changed files and rationale

- `AGENTS.md`: added the required append-only per-pushed-commit quick log rule and exact format.
- `scripts/ensure-hermes.ps1`, `scripts/ensure-hermes.sh`: added stage-level install logging and explicit missing-log diagnostics.
- `launch-north-forge.sh`: persist the one-time WELCOME marker only after a successful open.
- `tests/test-drive-hermes-install.sh`: added success/failure log assertions and a real killed-installer/relaunch case.
- `tests/test_drive_hermes_contract.py`: requires equivalent Windows stage messages.
- `tests/test_launcher_hermes_home.py`: verifies the POSIX one-time WELCOME success marker.
- `tests/test-free-provider.sh`: repaired the fake valid Hermes home to include the pyproject validity sentinel required by current production code.
- `tests/test-skill-assembly.sh`: repaired the isolated launcher fixture to include its required name-validation helper.
- `logs/CODEX_PUSH_LOG.md`: created as the append-only quick index required by the new governance rule.

## Diff summary

The patch does not weaken the damaged-install safety gate and does not automatically delete operator data. It makes install progress diagnosable at every meaningful boundary, makes absent logs an explicit finding, adds hard-interruption regression coverage, and fixes two stale test fixtures so the complete suite exercises current validity requirements. Watch-outs: the PowerShell log calls still require a native Windows interruption acceptance pass, and the safest user-friendly automatic recovery design remains intentionally unimplemented pending onboarding approval.

## Status

**NEEDS KENNETH REVIEW for onboarding UX; code fixes complete and all runnable checks pass.** Approve/design the quarantine-based R/K/C recovery prompt before implementation. Also schedule a native Windows acceptance pass for PowerShell interruption points and the POSIX `.readme-shown` gap was fixed in this patch.
