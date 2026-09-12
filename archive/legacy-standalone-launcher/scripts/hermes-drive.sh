#!/usr/bin/env bash
# Stable entry point for unattended Hermes work. A scheduler may start this
# with an empty environment, so never fall back to the operator's shared home.
set -eu
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
REPO_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)"
HERMES_HOME="$REPO_DIR/.hermes-home"
LOG_FILE="$HERMES_HOME/logs/north-forge-gateway.log"

fail() {
    message="North Forge unattended job stopped: $1"
    printf '%s\n' "$message" >&2
    if [ -d "$HERMES_HOME/logs" ]; then
        printf '[%s] [ERROR] [gateway-wrapper]: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" >> "$LOG_FILE"
    fi
    exit 72
}

[ -f "$REPO_DIR/.hermes.template.md" ] || fail "the removable repository is unavailable"
[ -d "$HERMES_HOME" ] || fail "the drive-local .hermes-home is unavailable"
HERMES_EXE=""
# Same ordered list as scripts/ensure-hermes.sh hermes_executable() - the install
# guard and this runtime wrapper MUST agree. Grounded in the upstream install.sh
# layout (venv console script; $HERMES_HOME/bin for --no-venv / test fixtures;
# checked-in ./hermes launcher). Speculative .venv/ and flat venv/ paths were
# removed - the installer only ever creates $INSTALL_DIR/venv.
for candidate in \
    "$HERMES_HOME/hermes-agent/venv/bin/hermes" \
    "$HERMES_HOME/bin/hermes" \
    "$HERMES_HOME/hermes-agent/hermes"; do
    if [ -x "$candidate" ]; then HERMES_EXE="$candidate"; break; fi
done
[ -n "$HERMES_EXE" ] || fail "the drive-local Hermes executable is unavailable"
export HERMES_HOME
cd "$REPO_DIR"
exec "$HERMES_EXE" "$@"
