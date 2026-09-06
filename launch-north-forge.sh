#!/usr/bin/env bash
# =============================================================================
# North Forge - Hermes Edition (Kyocera Edition v21.8) - part of the North
# Forge project.
# File: launch-north-forge.sh | Script version: 1.2.1 | Updated: 2026-09-05
# Author: Kenneth C. Walker Jr. - Senior Technical Support Engineer, TSC
# =============================================================================
set -e
cd "$(dirname "$0")"
export HERMES_HOME="$(pwd -P)/.hermes-home"
# Keep the engine, configuration, credentials, memory, and setup choices on
# this physical drive. Deliberately overwrite any caller-supplied HERMES_HOME
# so two drives, or a shared host profile, can never be merged together. This
# must stay the first statement after cd, before any other operation -
# tests/test_launcher_hermes_home.py enforces that ordering.
# Fail fast if this drive is not writable at all, before asking the operator
# any questions. Probes the repo root directly - this must NOT create
# .hermes-home itself: ensure_drive_hermes (scripts/ensure-hermes.sh) treats
# any pre-existing .hermes-home as an install to validate or recover, not as
# "not yet installed," so creating it here as a side effect made every
# fresh-drive install fail with "partial or damaged .hermes-home" before the
# installer ever ran (reproduced empirically 2026-09-05; see audit).
if ! WRITE_PROBE="$(mktemp "$(pwd -P)/.north-forge-write-probe.XXXXXX" 2>/dev/null)"; then
    echo "ERROR: North Forge cannot write to this drive at '$(pwd -P)'. Check the drive's permissions or free space."
    printf '[%s] [FAILURE] [hermes-home]: drive is not writable at %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$(pwd -P)" >> "forge-events.log"
    exit 1
fi
rm -f "$WRITE_PROBE"
unset WRITE_PROBE
SCRIPT_PATH="$(pwd)/launch-north-forge.sh"

# --- launch-time dependency check: Python 3 -------------------------------
# The Hermes ENGINE installer (scripts/ensure-hermes.sh, run much later)
# bootstraps its own Python, Node and git via `uv`, so those are NOT launch
# prerequisites. But THIS launcher needs Python 3 before the engine is ever
# touched: scripts/name_validation.py and the .hermes.md assembly heredoc
# below both run under it. A machine with no Python 3 used to dead-end here
# with a bare "install it yourself." Now it offers to install it unattended
# and only stops if that fails or the operator declines.
# Node.js is deliberately NOT checked: nothing on the launch path invokes
# node/npm/npx (verified by grep of both launchers and scripts/); the engine
# ships its own managed Node, and `npx agent-browser install` is a manual
# post-install browser-research step, not a launch dependency.
# Fast path (Python already present): one `command -v`, one log line, no
# prompt - no measurable delay on a normal launch.
NF_PY_VERSION="3.13.15"   # pinned python.org release for the auto-install
                          # path; bump by editing this one line. Stays inside
                          # Hermes's own requires-python (>=3.11,<3.14).

nf_dep_log() {
    printf '[%s] [%s] [deps]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "forge-events.log"
}

nf_detect_python() {
    # Detection ONLY - never executes the interpreter. A test harness stubs
    # python3 with a sentinel that exits non-zero when RUN; executing it here
    # would break that test and misread a working install as broken.
    [ "${NORTH_FORGE_DEP_FORCE_PY_MISSING:-0}" = always ] && return 1
    local c
    for c in python3 python; do
        command -v "$c" >/dev/null 2>&1 && { printf '%s\n' "$c"; return 0; }
    done
    # An official install can land outside this already-started shell's PATH;
    # check the usual absolute spots directly (never by prepending a scratch
    # dir to PATH - see CLAUDE.md's PATH-shadowing rule).
    for c in /usr/local/bin/python3 /usr/bin/python3 \
             /Library/Frameworks/Python.framework/Versions/Current/bin/python3 \
             ${NORTH_FORGE_DEP_PY_EXTRA_DIR:+"${NORTH_FORGE_DEP_PY_EXTRA_DIR}/python3"}; do
        [ -x "$c" ] && { printf '%s\n' "$c"; return 0; }
    done
    return 1
}

nf_python_ok() {
    # As nf_detect_python, but the test flag value "1" forces only the INITIAL
    # gate to see "missing" while the post-install re-check still finds a real
    # interpreter; "always" forces both.
    case "${NORTH_FORGE_DEP_FORCE_PY_MISSING:-0}" in 1|always) return 1;; esac
    nf_detect_python
}

nf_python_manual_help() {
    echo ""
    echo "North Forge can't start without Python 3. Install it by hand, then run"
    echo "this launcher again:"
    case "$(uname -s 2>/dev/null || echo unknown)" in
        Darwin) echo "  Get the latest macOS 64-bit universal2 installer from"
                echo "  https://www.python.org/downloads/macos/ and run it." ;;
        Linux)  echo "  Debian/Ubuntu:  sudo apt-get install -y python3"
                echo "  Fedora/RHEL:    sudo dnf install -y python3"
                echo "  Arch:           sudo pacman -S python" ;;
        *)      echo "  https://www.python.org/downloads/" ;;
    esac
    echo ""
}

nf_run_python_installer() {
    # Mockable seam: a test points NORTH_FORGE_DEP_INSTALLER at a script that
    # stands in for the whole download-and-install; its exit code is the
    # result. Real runs go per-OS below.
    if [ -n "${NORTH_FORGE_DEP_INSTALLER:-}" ]; then
        "$NORTH_FORGE_DEP_INSTALLER"
        return $?
    fi
    local sys dl pkg rc
    sys="$(uname -s 2>/dev/null || echo unknown)"
    case "$sys" in
        Darwin)
            command -v curl >/dev/null 2>&1 || {
                echo "curl is needed to download the Python installer and isn't available."
                return 90
            }
            dl="$(mktemp -d "${TMPDIR:-/tmp}/nf-python.XXXXXX")" || return 91
            pkg="$dl/python-${NF_PY_VERSION}-macos11.pkg"
            echo "Downloading the official Python ${NF_PY_VERSION} installer from python.org ..."
            if ! curl -fsSL -o "$pkg" \
                 "https://www.python.org/ftp/python/${NF_PY_VERSION}/python-${NF_PY_VERSION}-macos11.pkg"; then
                echo "Download failed."
                rm -rf "$dl"
                return 92
            fi
            echo "Installing Python ${NF_PY_VERSION} ... this may take a minute."
            echo "macOS will ask for your administrator password - the .pkg installer"
            echo "needs admin rights (it has no per-user mode)."
            sudo installer -pkg "$pkg" -target /
            rc=$?
            rm -rf "$dl"
            return $rc
            ;;
        Linux)
            echo "Installing Python 3 ... this may take a minute."
            echo "This uses your system package manager and will ask for your password (sudo)."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update -qq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3
                return $?
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y python3
                return $?
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -Sy --noconfirm python
                return $?
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper --non-interactive install python3
                return $?
            elif command -v apk >/dev/null 2>&1; then
                sudo apk add python3
                return $?
            fi
            echo "No supported package manager (apt-get / dnf / pacman / zypper / apk) found."
            return 93
            ;;
        *)
            echo "Automatic Python install isn't supported on this system ($sys)."
            return 94
            ;;
    esac
}

if NF_PYCMD="$(nf_python_ok)"; then
    nf_dep_log INFO "Python 3 present ($NF_PYCMD) - launch dependency check passed"
else
    nf_dep_log WARNING "Python 3 not found - launch-time dependency missing"
    echo ""
    echo "North Forge needs Python 3 to run, and it's not installed on this computer."
    if [ ! -t 0 ] && [ -z "${NORTH_FORGE_DEP_INSTALLER:-}" ]; then
        nf_dep_log FAILURE "no interactive terminal to confirm the install - stopping"
        echo "(No interactive terminal here, so nothing was installed automatically.)"
        nf_python_manual_help
        exit 1
    fi
    printf "Install it now? [Y/n] (recommended: Y): "
    NF_ANS=""
    read NF_ANS || NF_ANS=""
    case "$(printf '%s' "$NF_ANS" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
        n|no)
            nf_dep_log INFO "operator declined the Python 3 install - exiting cleanly"
            nf_python_manual_help
            exit 1
            ;;
    esac
    nf_dep_log INFO "operator approved the Python 3 install - starting"
    if nf_run_python_installer; then
        NF_IRC=0
    else
        NF_IRC=$?
    fi
    if [ "$NF_IRC" -ne 0 ]; then
        nf_dep_log FAILURE "Python 3 installer exited $NF_IRC - not continuing"
        echo "The Python installer did not finish successfully (exit $NF_IRC)."
        nf_python_manual_help
        exit 1
    fi
    # Never assume success from the installer's exit code alone - re-detect.
    if NF_PYCMD="$(nf_detect_python)"; then
        case "$NF_PYCMD" in
            /*) PATH="$(dirname "$NF_PYCMD"):$PATH"; export PATH ;;
        esac
        nf_dep_log INFO "Python 3 installed and verified ($NF_PYCMD) - continuing"
        echo "Python 3 is installed. Continuing ..."
    else
        nf_dep_log FAILURE "installer reported success but Python 3 is still not detectable"
        echo "Python 3 was installed but this launcher still can't see it."
        echo "Close this window and run the launcher again - a fresh shell usually picks it up."
        nf_python_manual_help
        exit 1
    fi
fi
# --- end launch-time dependency check -----------------------------------

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
    [ "$WELOPEN" != "ok" ] || : > ".readme-shown"
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

# Heredoc is the `if` condition itself: under `set -e` a bare `python3 <<EOF`
# that exits non-zero aborts the script before any following `if [ $? -ne 0 ]`
# can run, so the "Launch aborted" message below was previously unreachable on
# the failure path. `if ! ...` both suppresses errexit for this command and
# reaches the message. (.bat side already handles this; cmd.exe has no errexit.)
if ! python3 - "$MODE" << 'PYEOF'
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
then
    echo "Launch aborted: .hermes.md was not written."
    exit 1
fi

echo "North Forge running in $MODE mode."
echo "Want a different AI model or provider? Run 'hermes model' any time - it remembers your choice, doesn't ask again until you change it."

# --- require the drive's own validated engine; never fall back to host Hermes ---
. scripts/ensure-hermes.sh
ensure_drive_hermes "$PWD" || exit $?

# Every interactive command uses the same explicit drive-local entry point as
# cron/gateway registration; PATH can no longer redirect one operation to a
# machine-wide Hermes installation.
hermes() { scripts/hermes-drive.sh "$@"; }

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
    if set_out="$(hermes config set model.provider opencode-free 2>&1)"; then
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

    if unset_out="$(hermes config unset model.default 2>&1)"; then
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
if ! scripts/hermes-drive.sh cron list 2>/dev/null | grep -q "nightly-kyocera-research"; then
    echo "Scheduling the nightly Kyocera research job..."
    if CRON_DIAGNOSTIC="$(scripts/hermes-drive.sh cron add "0 6 * * *" "Run the kyocera-research pass" --skill kyocera-research --name nightly-kyocera-research 2>&1)"; then
        log_event "cron" "re-registered nightly-kyocera-research (0 6 * * *)"
    else
        report_cron_failure "nightly-kyocera-research" "automated nightly research" "$?" "$CRON_DIAGNOSTIC"
    fi
fi
if ! scripts/hermes-drive.sh cron list 2>/dev/null | grep -q "daily-kyocera-brief"; then
    echo "Scheduling the daily Kyocera brief job..."
    if CRON_DIAGNOSTIC="$(scripts/hermes-drive.sh cron add "0 8 * * *" "Run the daily-brief pass" --skill daily-brief --name daily-kyocera-brief 2>&1)"; then
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
