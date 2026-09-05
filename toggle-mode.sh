#!/usr/bin/env bash
# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: toggle-mode.sh | Script version: 1.1.0 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
cd "$(dirname "$0")"

# --- admin gate (Phase 4): required before mode switches and RESET ---
# Failed-attempt count lives in this variable only - session-scoped, never
# written to any file. The log records PASS/FAIL + attempt number, never
# the entered value.
ADMIN_ATTEMPTS=0
log_event() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] [$1]: $2" >> "forge-events.log"; }
admin_gate() {
    local PW=""
    read -r -s -p "Admin password required for $1: " PW
    echo ""
    ADMIN_ATTEMPTS=$((ADMIN_ATTEMPTS+1))
    if [ "$PW" = "RumpleStiltskin" ]; then
        log_event "admin-gate" "attempt $ADMIN_ATTEMPTS PASS ($1)"
        return 0
    fi
    log_event "admin-gate" "attempt $ADMIN_ATTEMPTS FAIL ($1)"
    echo "Wrong password - $1 cancelled."
    if [ "$ADMIN_ATTEMPTS" -ge 3 ]; then
        echo "Hint: Brothers Grimm"
    fi
    return 1
}

while true; do
    echo ""
    echo "Current mode file:"
    if [ -f ".forge-mode" ]; then cat ".forge-mode"; else echo "(none set - defaults to SALES)"; fi
    echo ""
    read -p "Type FULL, SALES, RESET, EXIT, or Q (blank = quit): " MODE

    case "$(echo "$MODE" | tr '[:upper:]' '[:lower:]')" in
        ""|exit|quit|q)
            break
            ;;
        full)
            admin_gate "mode switch to FULL" || continue
            echo "full" > ".forge-mode"
            echo "Set to FULL. Run launch-north-forge.sh to rebuild this drive's live skills/context with everything."
            ;;
        sales)
            admin_gate "mode switch to SALES" || continue
            echo "sales" > ".forge-mode"
            echo "Set to SALES. Run launch-north-forge.sh to rebuild this drive's live skills/context with Sales Assist only."
            ;;
        reset)
            admin_gate "RESET" || continue
            echo ""
            echo "RESET performs a fast onboarding/content reset:"
            echo "  .env, .forge-mode, .hermes.md, .drive-record.txt"
            echo "  .provider-choice, .agent-name, .readme-shown, .hermes/skills/"
            echo ""
            echo "The tracked repo content is NOT touched - skills-source/, mode-blocks/, the scripts."
            echo ".hermes-home is PRESERVED. Hermes credentials, memory, sessions, and cron state remain."
            echo "forge-events.log is intentionally RETAINED as an accountability record."
            echo "It can contain names entered by prior users; RESET is not a privacy/log purge."
            echo "Use this before handing the drive to someone else so credentials and settings"
            echo "do not travel with it and the next person gets a genuine first run."
            echo ""
            read -p "Type YES (all caps) to confirm: " CONFIRM
            if [ "$CONFIRM" = "YES" ]; then
                if [ -f ".drive-record.txt" ]; then
                    log_event "reset" "RESET executed by $(sed -n 1p .drive-record.txt) (registered $(sed -n 2p .drive-record.txt))"
                else
                    log_event "reset" "RESET executed (no drive record present)"
                fi
                rm -f ".env" ".forge-mode" ".hermes.md" ".drive-record.txt" \
                    ".provider-choice" ".agent-name" ".readme-shown"
                rm -rf ".hermes/skills"
                RESET_FAILED=0
                for TARGET in .env .forge-mode .hermes.md .drive-record.txt \
                    .provider-choice .agent-name .readme-shown .hermes/skills; do
                    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
                        echo "ERROR: Could not remove $TARGET. Check permissions, then try RESET again."
                        RESET_FAILED=1
                    fi
                done
                echo ""
                if [ "$RESET_FAILED" -ne 0 ]; then
                    echo "Credential/config reset was incomplete. forge-events.log was intentionally retained."
                    exit 1
                fi
                echo "Done. Onboarding/content reset completed; first-use setup will run next time."
                echo "Hermes credentials, memory, sessions, and cron state remain in .hermes-home."
                echo "forge-events.log was intentionally retained as the accountability record"
                echo "and can contain names entered by prior users."
                echo "Next person: run launch-north-forge.sh and follow the first-use prompts."
                exit 0
            else
                echo ""
                echo "Cancelled - nothing was deleted."
                exit 1
            fi
            ;;
        *)
            echo "Didn't recognize that - type exactly FULL, SALES, RESET, or EXIT."
            ;;
    esac
done
