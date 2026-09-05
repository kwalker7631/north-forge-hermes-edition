#!/usr/bin/env bash
# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: launch-north-forge.sh | Script version: 1.1.0 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
set -e
cd "$(dirname "$0")"
SCRIPT_PATH="$(pwd)/launch-north-forge.sh"

# --- first run on this drive: pop open the styled quickstart once ---
if [ ! -f ".readme-shown" ]; then
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "WELCOME.html" && WELOPEN=ok || WELOPEN=failed
    elif command -v open >/dev/null 2>&1; then
        open "WELCOME.html" && WELOPEN=ok || WELOPEN=failed
    else
        WELOPEN="no opener available"
    fi
    touch .readme-shown
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$([ "$WELOPEN" = "ok" ] && echo INFO || echo WARNING)] [welcome]: first-run WELCOME.html auto-open: $WELOPEN" >> "forge-events.log"
fi

# --- user tier: who-has-this-drive record (accountability only, never blocks) ---
log_event() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] [$1]: $2" >> "forge-events.log"; }
if [ ! -f ".drive-record.txt" ]; then
    DRIVENAME=""
    read -p "First launch: your name for this drive's record: " DRIVENAME || DRIVENAME=""
    [ -z "$DRIVENAME" ] && DRIVENAME="Unregistered"
    printf '%s\n%s\n' "$DRIVENAME" "$(date '+%Y-%m-%d %H:%M:%S')" > ".drive-record.txt"
    log_event "drive-record" "CREATE: registered to $DRIVENAME"
else
    CURNAME="$(sed -n 1p ".drive-record.txt")"
    NEWNAME=""
    read -p "Still $CURNAME? [Enter to continue / type a new name to re-register]: " NEWNAME || NEWNAME=""
    if [ -n "$NEWNAME" ]; then
        printf '%s\n%s\n' "$NEWNAME" "$(date '+%Y-%m-%d %H:%M:%S')" > ".drive-record.txt"
        log_event "drive-record" "RE-REGISTER: $CURNAME -> $NEWNAME"
    fi
fi

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

rm -rf .hermes/skills
mkdir -p .hermes/skills
cp -r skills-source/shared/. .hermes/skills/ 2>/dev/null || true
if [ "$MODE" = "full" ]; then
    cp -r skills-source/tsc-only/. .hermes/skills/ 2>/dev/null || true
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required for this launcher and wasn't found on this machine."
    echo "Install it (e.g. 'brew install python3' on Mac, or your distro's package manager on Linux), then run this script again."
    exit 1
fi

if [ ! -f ".agent-name" ]; then
    echo ""
    echo "First launch on this drive: you can give your assistant a personal"
    echo "name if you'd like - it still runs as North Forge underneath, this"
    echo "just changes what it calls itself when talking to you."
    echo ""
    read -p "Name your assistant (press Enter to keep 'North Forge'): " CUSTOMNAME || CUSTOMNAME=""
    if [ -z "$CUSTOMNAME" ]; then
        echo "North Forge" > ".agent-name"
    else
        echo "$CUSTOMNAME" > ".agent-name"
    fi
    echo ""
fi

python3 - "$MODE" << 'PYEOF'
import sys, os
mode = sys.argv[1]
with open(".hermes.template.md", "r", encoding="utf-8") as f:
    tmpl = f.read()
with open(f"mode-blocks/{mode}-banner.md", "r", encoding="utf-8") as f:
    banner = f.read()
with open(f"mode-blocks/{mode}-menu.md", "r", encoding="utf-8") as f:
    menu = f.read()
agent_name = "North Forge"
if os.path.exists(".agent-name"):
    with open(".agent-name", "r", encoding="utf-8") as f:
        n = f.read().strip()
        if n:
            agent_name = n
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

# --- install Hermes FIRST if missing - nothing below this works without it ---
if ! command -v hermes >/dev/null 2>&1; then
    echo "Hermes not found on this machine - installing now..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    echo ""
    echo "Install finished. Open a new terminal and run this script again:"
    echo "  bash launch-north-forge.sh"
    exit 0
fi

# --- provider choice: default to zero-config OpenCode Free (no key, no
# account, no block); using your own Anthropic API key is opt-in, not the
# hard gate this used to be. Asked once, remembered in .provider-choice,
# same pattern as .agent-name/.drive-record.txt. ---
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
        echo "free" > ".provider-choice"
        hermes config set model.provider opencode-free >/dev/null 2>&1 || true
        hermes config unset model.default >/dev/null 2>&1 || true
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
HERMES_SKIN_DIR="${HERMES_HOME:-$HOME/.hermes}/skins"
mkdir -p "$HERMES_SKIN_DIR"
cp -f "skins/north-forge.yaml" "$HERMES_SKIN_DIR/north-forge.yaml"

echo "Activating North Forge skin..."
hermes skin use north-forge
echo "Skin list after activation (look for * next to north-forge):"
hermes skin list

# Project-local skills require an explicit trust decision before Hermes will
# load them (security gate against a git pull silently injecting a skill).
# Auto-approved here since this repo is Blacksmith-reviewed before it ever
# reaches a drive - see README for the tradeoff this makes.
hermes skills trust .

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
if ! hermes cron list 2>/dev/null | grep -q "nightly-kyocera-research"; then
    echo "Scheduling the nightly Kyocera research job..."
    if CRON_DIAGNOSTIC="$(hermes cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research 2>&1)"; then
        log_event "cron" "re-registered nightly-kyocera-research (0 6 * * *)"
    else
        report_cron_failure "nightly-kyocera-research" "automated nightly research" "$?" "$CRON_DIAGNOSTIC"
    fi
fi
if ! hermes cron list 2>/dev/null | grep -q "daily-kyocera-brief"; then
    echo "Scheduling the daily Kyocera brief job..."
    if CRON_DIAGNOSTIC="$(hermes cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief 2>&1)"; then
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
hermes || HERMES_EXIT=$?
if [ "$HERMES_EXIT" -eq 0 ]; then
    log_event "hermes" "session ended normally (exit 0)"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] [hermes]: session ended with exit $HERMES_EXIT" >> "forge-events.log"
fi
exit $HERMES_EXIT
