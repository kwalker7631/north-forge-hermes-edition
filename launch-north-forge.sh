#!/usr/bin/env bash
# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: launch-north-forge.sh | Script version: 1.2.1 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
set -e
cd "$(dirname "$0")"
SCRIPT_PATH="$(pwd)/launch-north-forge.sh"
# Hermes' official installers create this checkout, virtual environment, and
# wrapper beneath HERMES_HOME.  Keep all three on this drive so a system-wide
# `hermes` command can never take over a North Forge session.
HERMES_HOME="$(pwd)/.hermes-home"
HERMES_EXE="$HERMES_HOME/bin/hermes"
export HERMES_HOME

hermes_ready() {
    [ -d "$HERMES_HOME/hermes-agent" ] &&
        [ -d "$HERMES_HOME/venv" ] &&
        [ -x "$HERMES_EXE" ]
}

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required for this launcher and wasn't found on this machine."
    echo "Install it, then run this script again."
    exit 1
fi

# --- first run on this drive: pop open the styled quickstart once ---
if [ ! -f ".readme-shown" ]; then
    if [ ! -f "WELCOME.html" ]; then
        WELOPEN="failed: WELCOME.html is missing"
    elif command -v xdg-open >/dev/null 2>&1 && xdg-open "WELCOME.html"; then
        WELOPEN=ok
    elif command -v open >/dev/null 2>&1 && open "WELCOME.html"; then
        WELOPEN=ok
    else
        WELOPEN="failed: no working opener available"
    fi
    # Only marked done when it actually worked (WELOPEN=ok, checked above),
    # so a failed open (no opener, opener crashed, file missing) retries on
    # the next launch instead of silently never showing the welcome page
    # again.
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$([ "$WELOPEN" = "ok" ] && echo INFO || echo WARNING)] [welcome]: first-run WELCOME.html auto-open: $WELOPEN" >> "forge-events.log"
fi

# Names are capped at 64 characters and allow letters, numbers, spaces, and
# apostrophe, hyphen, period, comma, and parentheses. The shared helper strips
# ASCII controls and rejects parsing/log metacharacters before anything is used.
# Help: Enter a normal person's name; press Enter to keep the shown default.
# --- user tier: who-has-this-drive record (accountability only, never blocks) ---
log_event() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] [$1]: $2" >> "forge-events.log"; }
python3 scripts/name_validation.py drive

# --- log repo state at launch (no git pull happens here by design - drives
# update manually; this records what code the session ran on) ---
if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
    log_event "git" "launch at commit $(git rev-parse --short HEAD 2>/dev/null || echo unknown), status: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') modified file(s)"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] [git]: git or .git missing - repo state unknown at launch" >> "forge-events.log"
fi

# exFAT (needed for a drive that works on Windows/Mac/Linux) can't store the
# executable permission bit, so this file can't be made double-clickable
# directly off the drive. First run creates a real, permanent, double-clickable
# icon on the Mac's own internal disk instead - every run after this one,
# use that icon, not this file.
DESKTOP_LAUNCHER="$HOME/Desktop/North Forge.command"
mkdir -p "$HOME/Desktop"
if [ ! -f "$DESKTOP_LAUNCHER" ]; then
    cat > "$DESKTOP_LAUNCHER" << SHORTCUT
#!/bin/bash
bash "$SCRIPT_PATH"
SHORTCUT
    chmod +x "$DESKTOP_LAUNCHER"
    if [ -f "$DESKTOP_LAUNCHER" ]; then
        log_event "shortcut" "Desktop launcher created: $DESKTOP_LAUNCHER"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] [shortcut]: Desktop launcher creation FAILED: $DESKTOP_LAUNCHER" >> "forge-events.log"
    fi
    echo ""
    echo "==================================================================="
    echo "Created a 'North Forge' icon on your Desktop."
    echo "From now on: double-click that icon. You will not need to do"
    echo "this Terminal step again on this Mac."
    echo "==================================================================="
    echo ""
fi

# --- assemble live .hermes/skills/ and .hermes.md from source, based on the mode toggle ---
MODE="sales"
if [ -f ".forge-mode" ]; then
    MODE="$(tr '[:upper:]' '[:lower:]' < .forge-mode | tr -d '[:space:]')"
fi
if [ "$MODE" != "full" ] && [ "$MODE" != "sales" ]; then
    echo "Unrecognized .forge-mode value '$MODE' - defaulting to sales for safety."
    MODE="sales"
fi

assemble_skills() {
    local skills_parent=".hermes" live
    live="$skills_parent/skills"
    local stage backup source_count stage_count skill
    local shared_skills="daily-brief flush kyocera-research manual menu sales-assist switch web-navigator"
    local tsc_skills="assist-intake draft-writer escalation-packet fault-logging forge-audit hotline-ticket kb-builder training-guide"

    if [ ! -d "skills-source/shared" ] || { [ "$MODE" = "full" ] && [ ! -d "skills-source/tsc-only" ]; }; then
        log_event "skills" "FAILURE: required skills-source directory is missing; current build preserved"
        echo "ERROR: A required skills-source folder is missing. Your existing skills were left untouched."
        return 1
    fi
    if ! mkdir -p "$skills_parent"; then
        echo "ERROR: Could not create .hermes. Check drive permissions; existing skills were not changed."
        return 1
    fi
    stage="$skills_parent/.skills-staging-$$-${RANDOM:-0}"
    backup="$skills_parent/.skills-backup-$$-${RANDOM:-0}"
    rm -rf -- "$stage" "$backup"
    if ! mkdir "$stage"; then
        echo "ERROR: Could not create the temporary skills folder. Existing skills were not changed."
        return 1
    fi
    # Always clean abandoned staging. A backup is only removed after a verified
    # success, or after it has restored the last-known-good build.
    trap "rm -rf -- $(printf '%q' "$stage"); if [ -d $(printf '%q' "$backup") ] && [ ! -e $(printf '%q' "$live") ]; then mv -- $(printf '%q' "$backup") $(printf '%q' "$live") || true; fi" EXIT

    if [ "${NORTH_FORGE_TEST_FAIL_COPY:-0}" = 1 ] || ! cp -R "skills-source/shared/." "$stage/"; then
        log_event "skills" "FAILURE: shared skill copy failed; current build preserved"
        echo "ERROR: Could not copy shared skills. Your existing skills were left untouched."
        return 1
    fi
    if [ "$MODE" = "full" ]; then
        if ! cp -R "skills-source/tsc-only/." "$stage/"; then
            log_event "skills" "FAILURE: TSC-only skill copy failed; current build preserved"
            echo "ERROR: Could not copy FULL-mode skills. Your existing skills were left untouched."
            return 1
        fi
    fi
    for skill in $shared_skills; do
        if [ ! -d "$stage/$skill" ] || [ ! -f "$stage/$skill/SKILL.md" ]; then
            log_event "skills" "FAILURE: staged shared skill '$skill' is incomplete; current build preserved"
            echo "ERROR: Shared skill '$skill' is incomplete (folder or SKILL.md missing). Existing skills were left untouched."
            return 1
        fi
    done
    if [ "$MODE" = "full" ]; then
        for skill in $tsc_skills; do
            if [ ! -d "$stage/$skill" ] || [ ! -f "$stage/$skill/SKILL.md" ]; then
                log_event "skills" "FAILURE: staged FULL skill '$skill' is incomplete; current build preserved"
                echo "ERROR: FULL-mode skill '$skill' is incomplete (folder or SKILL.md missing). Existing skills were left untouched."
                return 1
            fi
        done
    fi
    source_count=$(find skills-source/shared -type f | wc -l | tr -d ' ')
    [ "$MODE" = "full" ] && source_count=$((source_count + $(find skills-source/tsc-only -type f | wc -l | tr -d ' ')))
    stage_count=$(find "$stage" -type f | wc -l | tr -d ' ')
    if [ "$source_count" -eq 0 ] || [ "$stage_count" -ne "$source_count" ]; then
        log_event "skills" "FAILURE: partial staged build ($stage_count of $source_count files); current build preserved"
        echo "ERROR: Skill validation found a zero-file or partial build ($stage_count of $source_count files). Existing skills were left untouched."
        return 1
    fi

    if [ -e "$live" ] && ! mv -- "$live" "$backup"; then
        echo "ERROR: Could not back up the current skills. Nothing was changed."
        return 1
    fi
    if [ "${NORTH_FORGE_TEST_FAIL_SWAP:-0}" = 1 ] || ! mv -- "$stage" "$live"; then
        [ ! -e "$live" ] && [ -e "$backup" ] && mv -- "$backup" "$live"
        log_event "skills" "FAILURE: final skill swap failed; previous build restored"
        echo "ERROR: Could not activate the staged skills. The previous build was restored."
        return 1
    fi
    if [ -e "$backup" ] && ! rm -rf -- "$backup"; then
        echo "WARNING: Skills activated, but the temporary backup could not be removed: $backup"
        log_event "skills" "WARNING: activated skills but could not remove backup $backup"
    fi
    trap - EXIT
    log_event "skills" "SUCCESS: activated validated $MODE build ($stage_count files)"
}

assemble_skills || exit 1
[ "${NORTH_FORGE_ASSEMBLE_ONLY:-0}" = 1 ] && exit 0

python3 scripts/name_validation.py agent

python3 - "$MODE" << 'PYEOF'
import sys, os
mode = sys.argv[1]
with open(".hermes.template.md", "r", encoding="utf-8") as f:
    tmpl = f.read()
with open(f"mode-blocks/{mode}-banner.md", "r", encoding="utf-8") as f:
    banner = f.read()
with open(f"mode-blocks/{mode}-menu.md", "r", encoding="utf-8") as f:
    menu = f.read()
from scripts.name_validation import read_validated
from pathlib import Path
agent_name, _ = read_validated(Path(".agent-name"), "North Forge")
tmpl = tmpl.replace("{{MODE_BANNER_BLOCK}}", banner).replace("{{COMMAND_MENU_BLOCK}}", menu).replace("{{AGENT_NAME}}", agent_name)
size = len(tmpl)
if size >= 20000:
    print(f"FATAL: assembled .hermes.md is {size} chars - at or over the 20,000-char context-file ceiling.")
    print("Hermes would silently drop the middle of the file. Trim the template/banner/menu before launching.")
    import datetime
    with open("forge-events.log", "a", encoding="utf-8") as lg:
        lg.write(f"[{datetime.datetime.now():%Y-%m-%d %H:%M:%S}] [FAILURE] [size-guard]: assembled .hermes.md {size} chars >= 20000 ceiling - launch aborted\n")
    sys.exit(1)
if size >= 19800:
    print(f"WARNING: assembled .hermes.md is {size} chars - within 200 of the 20,000-char ceiling. Trim soon.")
    import datetime
    with open("forge-events.log", "a", encoding="utf-8") as lg:
        lg.write(f"[{datetime.datetime.now():%Y-%m-%d %H:%M:%S}] [WARNING] [size-guard]: assembled .hermes.md {size} chars - within 200 of the 20000 ceiling\n")
with open(".hermes.md", "w", encoding="utf-8") as f:
    f.write(tmpl)
PYEOF
if [ $? -ne 0 ]; then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi

echo "North Forge running in $MODE mode."
echo "Want a different AI model or provider? Run 'hermes model' any time - it remembers your choice, doesn't ask again until you change it."

# --- install Hermes on THIS drive if its complete local runtime is absent ---
if ! hermes_ready; then
    echo "North Forge's drive-local Hermes is not ready - installing it now..."
    if curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash; then
        :
    else
        status=$?
        echo "ERROR: Hermes installation did not finish successfully (exit $status)."
        echo "Please check your internet connection and forge-events.log, then try again."
        log_event "hermes-install" "FAILURE: official installer exited $status"
        exit "$status"
    fi
    if ! hermes_ready; then
        echo "ERROR: The installer reported success, but North Forge could not find its"
        echo "engine, virtual environment, and launcher under .hermes-home."
        echo "Nothing else was started. See forge-events.log for the paths checked."
        log_event "hermes-install" "FAILURE: installer exited 0 but required markers were absent (checkout=$HERMES_HOME/hermes-agent, venv=$HERMES_HOME/venv, executable=$HERMES_EXE)"
        exit 1
    fi
    log_event "hermes-install" "SUCCESS: verified drive-local checkout, venv, and executable"
fi
[ "${NORTH_FORGE_HERMES_READY_ONLY:-0}" = 1 ] && exit 0

# --- provider choice: default to zero-config OpenCode Free (no key, no
# account, no block); using your own Anthropic API key is opt-in, not the
# hard gate this used to be. Asked once, remembered in .provider-choice,
# same pattern as .agent-name/.drive-record.txt. ---
log_provider_detail() {
    # Mirrors the .bat launcher's LOG_PROVIDER_DETAIL: redact anything that
    # looks like a credential before it reaches forge-events.log.
    local safe
    safe="$(printf '%s' "$1" | sed -E 's/(api[_-]?key|token|secret|password)([[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1\2[REDACTED]/Ig')"
    printf '[provider-config detail] %s\n' "$safe" >> "forge-events.log"
}

configure_free_provider() {
    # `hermes config set` must actually succeed for the free path to work -
    # do NOT write .provider-choice=free (which skips this block on every
    # future launch) unless it did. `unset model.default` returns nonzero
    # whenever the key was never set in the first place (the common,
    # expected case), so that alone isn't a failure - only treat it as one
    # when the output doesn't match that exact benign message. Each `if
    # VAR=$(...); then` assignment is the condition of its own `if` so a
    # nonzero exit doesn't trip `set -e` before it can be handled.
    rm -f ".provider-choice"
    local set_out set_status unset_out unset_status unset_absent
    if set_out="$("$HERMES_EXE" config set model.provider opencode-free 2>&1)"; then
        set_status=0
    else
        set_status=$?
    fi
    if [ "$set_status" -ne 0 ]; then
        echo "ERROR: Hermes could not select OpenCode Free (exit $set_status)."
        echo "Nothing was saved. Please review the details below, then run North Forge again."
        printf '%s\n' "$set_out"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FAILURE] [provider-config]: set model.provider failed (exit $set_status); .provider-choice not written" >> "forge-events.log"
        log_provider_detail "$set_out"
        return "$set_status"
    fi

    if unset_out="$("$HERMES_EXE" config unset model.default 2>&1)"; then
        unset_status=0
    else
        unset_status=$?
    fi
    unset_absent=0
    if [ "$unset_status" -eq 1 ] && [ "$unset_out" = "Config key not set: model.default" ]; then
        unset_absent=1
    fi
    if [ "$unset_status" -ne 0 ] && [ "$unset_absent" -ne 1 ]; then
        echo "ERROR: Hermes selected OpenCode Free, but could not clear the old default model (exit $unset_status)."
        echo "Nothing was saved. Please review the details below, then run North Forge again."
        printf '%s\n' "$unset_out"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FAILURE] [provider-config]: unset model.default failed (exit $unset_status); .provider-choice not written" >> "forge-events.log"
        log_provider_detail "$unset_out"
        return "$unset_status"
    fi

    echo "free" > ".provider-choice"
    return 0
}

if [ "${1:-}" = "--configure-free-provider" ]; then
    configure_free_provider
    exit $?
fi

if [ ! -f ".provider-choice" ]; then
    echo ""
    echo "North Forge needs an AI provider before it can answer questions."
    echo ""
    echo "  Press ENTER  - start now for free, no account or key needed"
    echo "                 (uses OpenCode Free - good for trying it out)"
    echo "  Type OWNKEY  - use your own Anthropic API key instead"
    echo "                 (paid, pay-per-token - pick this for real field/production use)"
    echo ""
    PROVIDERCHOICE=""
    read -p "Your choice [ENTER = free / OWNKEY = your own key]: " PROVIDERCHOICE || PROVIDERCHOICE=""
    if [ "$(printf '%s' "$PROVIDERCHOICE" | tr '[:lower:]' '[:upper:]')" = "OWNKEY" ]; then
        echo "ownkey" > ".provider-choice"
    else
        configure_free_provider || exit $?
    fi
fi

PROVIDERMODE="$(tr '[:upper:]' '[:lower:]' < .provider-choice | tr -d '[:space:]')"

if [ "$PROVIDERMODE" = "ownkey" ]; then
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp ".env.example" ".env"
            echo ""
            echo "First run: created .env from the template."
            echo "Add your Anthropic API key, save, then run this script again."
            echo "IMPORTANT: run 'hermes model' and pick a standard model (Sonnet or Opus) -"
            echo "avoid a premium/credits-gated model (Fable, Mythos) unless you specifically"
            echo "know it needs a separate purchased credits balance on top of this API key."
            "${EDITOR:-nano}" ".env"
            exit 0
        fi
    fi

    # --- catch a .env that EXISTS but still holds the placeholder/an
    # obviously-too-short value, instead of silently launching into a session
    # that can't call a model. Real Anthropic keys run ~100+ chars; the
    # template placeholder and any partial paste are much shorter, so a length
    # check below a safe threshold catches both without matching exact text.
    KEYVAL="$(grep '^ANTHROPIC_API_KEY=' .env 2>/dev/null | head -1 | cut -d'=' -f2- | tr -d '[:space:]')"
    if [ -z "$KEYVAL" ] || [ "${#KEYVAL}" -lt 30 ]; then
        echo ""
        echo "Your .env exists, but ANTHROPIC_API_KEY looks like a placeholder or"
        echo "is missing - not a real key. Launching anyway would just fail on"
        echo "the first real question instead of telling you clearly now."
        echo ""
        echo "Add your real Anthropic API key, save, then run this script again."
        "${EDITOR:-nano}" ".env"
        exit 0
    fi
fi

# --- copy the skin into place and activate it - hermes is guaranteed installed by this point ---
HERMES_SKIN_DIR="$HERMES_HOME/skins"
mkdir -p "$HERMES_SKIN_DIR"
cp -f "skins/north-forge.yaml" "$HERMES_SKIN_DIR/north-forge.yaml"

echo "Activating North Forge skin..."
"$HERMES_EXE" skin use north-forge
echo "Skin list after activation (look for * next to north-forge):"
"$HERMES_EXE" skin list

# Project-local skills require an explicit trust decision before Hermes will
# load them (security gate against a git pull silently injecting a skill).
# Auto-approved here since this repo is Blacksmith-reviewed before it ever
# reaches a drive - see README for the tradeoff this makes.
"$HERMES_EXE" skills trust .

# Self-healing scheduled jobs - re-adds the research and daily-brief cron
# entries if either is missing (e.g. after an AppData flush wiped them).
# No manual /cron add ever needed again.
CRON_DEGRADED=""
report_cron_failure() {
    job_name="$1"
    automation="$2"
    exit_status="$3"
    raw_diagnostic="$4"
    diagnostic="$(printf '%s' "$raw_diagnostic" | tr '\r\n' '  ' | LC_ALL=C sed 's/[^[:print:]\t]/?/g' | cut -c1-500)"
    [ -n "$diagnostic" ] || diagnostic="no diagnostic output"
    warning="WARNING: Could not schedule $job_name (exit $exit_status; diagnostic: $diagnostic). Interactive North Forge can continue, but the $automation will not run. Check Hermes with 'hermes cron list', then relaunch North Forge to try again."
    printf '%s\n' "$warning"
    printf '[%s] [WARNING] [cron]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$warning" >> "forge-events.log"
    CRON_DEGRADED="${CRON_DEGRADED}${CRON_DEGRADED:+; }$job_name"
}
if ! "$HERMES_EXE" cron list 2>/dev/null | grep -q "nightly-kyocera-research"; then
    echo "Scheduling the nightly Kyocera research job..."
    if CRON_DIAGNOSTIC="$("$HERMES_EXE" cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research 2>&1)"; then
        log_event "cron" "re-registered nightly-kyocera-research (0 6 * * *)"
    else
        report_cron_failure "nightly-kyocera-research" "automated nightly research" "$?" "$CRON_DIAGNOSTIC"
    fi
fi
if ! "$HERMES_EXE" cron list 2>/dev/null | grep -q "daily-kyocera-brief"; then
    echo "Scheduling the daily Kyocera brief job..."
    if CRON_DIAGNOSTIC="$("$HERMES_EXE" cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief 2>&1)"; then
        log_event "cron" "re-registered daily-kyocera-brief (0 8 * * *)"
    else
        report_cron_failure "daily-kyocera-brief" "automated daily brief" "$?" "$CRON_DIAGNOSTIC"
    fi
fi

if [ -n "$CRON_DEGRADED" ]; then
    echo "WARNING SUMMARY: North Forge is starting in degraded mode. Unscheduled job(s): $CRON_DEGRADED. Interactive North Forge is still available; run 'hermes cron list' to check Hermes, then relaunch to retry."
fi

# Plain call instead of exec so the exit status can be logged after the
# session ends (exec would replace this process and nothing could run after).
# The || guard keeps set -e from aborting before the log line is written.
HERMES_EXIT=0
"$HERMES_EXE" || HERMES_EXIT=$?
if [ "$HERMES_EXIT" -eq 0 ]; then
    log_event "hermes" "session ended normally (exit 0)"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] [hermes]: session ended with exit $HERMES_EXIT" >> "forge-events.log"
fi
exit $HERMES_EXIT
