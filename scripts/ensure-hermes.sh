#!/usr/bin/env bash
# Drive-local Hermes installation guard. This file is sourced by the launcher.

hermes_executable() {
    local root="$1" candidate
    for candidate in "$root/bin/hermes" "$root/hermes" "$root/hermes-agent/hermes"; do
        [ -f "$candidate" ] && [ -x "$candidate" ] && { printf '%s\n' "$candidate"; return 0; }
    done
    return 1
}

hermes_home_valid() {
    [ -d "$1/hermes-agent" ] && [ -f "$1/hermes-agent/pyproject.toml" ] && hermes_executable "$1" >/dev/null
}

ensure_drive_hermes() {
    local root="${1:-$PWD}" home stage marker logs stamp log installer exit_code available
    home="$root/.hermes-home"; stage="$root/.hermes-install-staging"
    marker="$root/.hermes-install-incomplete"; logs="$root/install-logs"
    export HERMES_HOME="$home"

    if hermes_home_valid "$home"; then
        export PATH="$home/bin:$home:$PATH"
        return 0
    fi
    if [ -e "$home" ] || [ -e "$marker" ] || [ -e "$stage" ]; then
        echo "ERROR: This drive has a partial or damaged .hermes-home; North Forge will not use or overwrite it."
        echo "Shared Hermes setup on this computer was not touched."
        echo "Recovery: rename .hermes-home and .hermes-install-staging for inspection (or remove them), remove .hermes-install-incomplete, then launch again."
        echo "Diagnostic logs: $logs"
        return 20
    fi

    echo "This drive will receive its own independent Hermes engine and dependencies."
    echo "Installation may take several minutes. Required space varies with browser components."
    if available=$(df -Pk "$root" 2>/dev/null | awk 'NR==2 {print int($4/1024) " MB"}'); then
        echo "Space check: about $available is currently free. No hard minimum is assumed; confirm the drive has room before continuing."
    else
        echo "WARNING: Free space could not be checked reliably. Review the drive's available space before continuing."
    fi
    echo "Help: press Ctrl+C now to cancel safely; launch again when the drive is ready."

    if [ "${NORTH_FORGE_TEST_UNWRITABLE:-0}" = 1 ] || ! mkdir -p "$logs" || ! : > "$root/.hermes-write-test"; then
        echo "ERROR: The drive is not writable. Nothing was installed; unlock it or choose writable media and retry."
        return 21
    fi
    rm -f "$root/.hermes-write-test"
    stamp=$(date '+%Y%m%d-%H%M%S')
    log="$logs/hermes-install-$stamp.log"
    : > "$marker"
    if ! mkdir "$stage"; then
        echo "ERROR: Could not create the installation staging folder. See $log"
        return 21
    fi
    installer="$logs/hermes-installer-$stamp.sh"
    if [ -n "${NORTH_FORGE_INSTALLER_SH:-}" ]; then
        cp -- "$NORTH_FORGE_INSTALLER_SH" "$installer" 2>>"$log"
        exit_code=$?
    else
        curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o "$installer" >>"$log" 2>&1
        exit_code=$?
    fi
    if [ "$exit_code" -eq 0 ]; then
        if HERMES_HOME="$stage" bash "$installer" >>"$log" 2>&1; then exit_code=0; else exit_code=$?; fi
    fi
    if [ "$exit_code" -ne 0 ] || ! hermes_home_valid "$stage"; then
        echo "ERROR: Hermes installation failed or did not pass validation (installer exit $exit_code)."
        echo "Shared Hermes setup on this computer was not touched. Diagnostic log: $log"
        echo "Recovery: remove .hermes-install-staging and .hermes-install-incomplete, then launch again. Keep $log when asking for help."
        return 22
    fi
    if ! mv -- "$stage" "$home"; then
        echo "ERROR: Hermes was validated but could not be activated. See $log; shared host setup was not touched."
        return 23
    fi
    rm -f "$marker"
    export HERMES_HOME="$home"
    export PATH="$home/bin:$home:$PATH"
    echo "Hermes was installed and validated on this drive."
}
