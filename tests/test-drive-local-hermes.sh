#!/usr/bin/env bash
# Scratch regression: a shared Hermes sentinel is deliberately first on PATH.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-drive-local.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
cp -R "$ROOT/." "$WORK/repo"
mkdir -p "$WORK/shared-bin"
cat > "$WORK/shared-bin/hermes" <<'SHARED'
#!/usr/bin/env bash
echo shared >> "$SENTINEL_LOG"
exit 88
SHARED
cat > "$WORK/shared-bin/curl" <<'INSTALLER'
#!/usr/bin/env bash
cat <<'SCRIPT'
mkdir -p "$HERMES_HOME/hermes-agent" "$HERMES_HOME/venv" "$HERMES_HOME/bin"
cat > "$HERMES_HOME/bin/hermes" <<'LOCAL'
#!/usr/bin/env bash
echo local >> "$LOCAL_LOG"
exit 0
LOCAL
chmod +x "$HERMES_HOME/bin/hermes"
SCRIPT
INSTALLER
chmod +x "$WORK/shared-bin/hermes" "$WORK/shared-bin/curl"
: > "$WORK/shared.log"; : > "$WORK/local.log"
(
  cd "$WORK/repo"
  PATH="$WORK/shared-bin:$PATH" SENTINEL_LOG="$WORK/shared.log" LOCAL_LOG="$WORK/local.log" \
    NORTH_FORGE_HERMES_READY_ONLY=1 bash ./launch-north-forge.sh </dev/null
)
[ -d "$WORK/repo/.hermes-home/hermes-agent" ]
[ -d "$WORK/repo/.hermes-home/venv" ]
[ -x "$WORK/repo/.hermes-home/bin/hermes" ]
[ ! -s "$WORK/shared.log" ] || { echo "FAIL: shared Hermes was called" >&2; exit 1; }
grep -q 'verified drive-local checkout' "$WORK/repo/forge-events.log"
echo "PASS: fresh drive installed its local Hermes and ignored the shared PATH sentinel"

# A zero exit without the documented installer artifacts must stop clearly.
BROKEN="$WORK/broken"
cp -R "$ROOT/." "$BROKEN"
mkdir -p "$WORK/broken-bin"
cat > "$WORK/broken-bin/curl" <<'EMPTY'
#!/usr/bin/env bash
printf ':\n'
EMPTY
chmod +x "$WORK/broken-bin/curl"
status=0
(cd "$BROKEN" && PATH="$WORK/broken-bin:$PATH" NORTH_FORGE_HERMES_READY_ONLY=1 bash ./launch-north-forge.sh </dev/null) >"$WORK/broken-terminal.log" 2>&1 || status=$?
[ "$status" -ne 0 ] || { echo "FAIL: incomplete successful install was accepted" >&2; exit 1; }
grep -q "installer reported success" "$WORK/broken-terminal.log"
grep -q "installer exited 0 but required markers were absent" "$BROKEN/forge-events.log"
echo "PASS: successful installer exit without runtime markers fails once and is logged"
