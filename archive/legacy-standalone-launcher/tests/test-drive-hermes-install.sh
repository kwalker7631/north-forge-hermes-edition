#!/usr/bin/env bash
set -u
repo=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/north forge hermes.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
pass=0
make_installer() {
    cat > "$1" <<'EOF'
#!/usr/bin/env bash
set -eu
mkdir -p "$HERMES_HOME/bin" "$HERMES_HOME/hermes-agent"
: > "$HERMES_HOME/hermes-agent/pyproject.toml"
cat > "$HERMES_HOME/bin/hermes" <<'INNER'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${HERMES_TEST_CALLS:?}"
exit 0
INNER
chmod +x "$HERMES_HOME/bin/hermes"
EOF
    chmod +x "$1"
}
run_case() { mkdir -p "$1/scripts"; cp "$repo/scripts/ensure-hermes.sh" "$1/scripts/"; }

fresh="$tmp/drive with spaces"; run_case "$fresh"; make_installer "$tmp/good installer.sh"
export NORTH_FORGE_INSTALLER_SH="$tmp/good installer.sh" HERMES_TEST_CALLS="$tmp/calls"
(cd "$fresh" && . scripts/ensure-hermes.sh && ensure_drive_hermes "$PWD" &&
  hermes config set model.provider opencode-free && hermes config unset model.default && hermes --version)
[ -x "$fresh/.hermes-home/bin/hermes" ] && [ ! -e "$fresh/.hermes-install-incomplete" ] && [ "$(wc -l < "$tmp/calls")" -eq 3 ] || exit 1
fresh_log=$(find "$fresh/install-logs" -name 'hermes-install-*.log' -type f | head -1)
grep -q '\[START\].*setup started' "$fresh_log" && grep -q '\[PASS\] Validation passed' "$fresh_log" && grep -q '\[COMPLETE\]' "$fresh_log" || exit 1
pass=$((pass+1))

failed="$tmp/failure"; run_case "$failed"; printf '#!/bin/sh\necho deliberate failure\nexit 17\n' > "$tmp/bad.sh"; chmod +x "$tmp/bad.sh"
NORTH_FORGE_INSTALLER_SH="$tmp/bad.sh" bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$failed" && exit 1
[ -f "$failed/.hermes-install-incomplete" ] && find "$failed/install-logs" -name 'hermes-install-*.log' -type f | grep -q . || exit 1
failed_log=$(find "$failed/install-logs" -name 'hermes-install-*.log' -type f | head -1)
grep -q '\[PASS\] Installer acquired; installer invocation started' "$failed_log" && grep -q '\[FAIL\] Installer/validation failed' "$failed_log" || exit 1
pass=$((pass+1))

# A hard interruption while the installer is running must leave a durable last
# known stage in install-logs, plus the safety marker that blocks blind reuse.
interrupted="$tmp/interrupted"; run_case "$interrupted"
cat > "$tmp/slow.sh" <<'EOF'
#!/usr/bin/env bash
sleep 30
EOF
chmod +x "$tmp/slow.sh"
(NORTH_FORGE_INSTALLER_SH="$tmp/slow.sh" bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$interrupted") &
install_pid=$!
for _ in $(seq 1 100); do
    interrupted_log=$(find "$interrupted/install-logs" -name 'hermes-install-*.log' -type f 2>/dev/null | head -1)
    [ -n "$interrupted_log" ] && grep -q 'installer invocation started' "$interrupted_log" && break
    sleep 0.05
done
kill -KILL "$install_pid" 2>/dev/null || true
wait "$install_pid" 2>/dev/null || true
[ -f "$interrupted/.hermes-install-incomplete" ] && grep -q '\[STAGE\] Installation staging folder created' "$interrupted_log" && grep -q 'installer invocation started' "$interrupted_log" || exit 1
relaunch_output=$(bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$interrupted" 2>&1) && exit 1
printf '%s' "$relaunch_output" | grep -q 'Recovery:' || exit 1
pass=$((pass+1))

partial="$tmp/partial"; run_case "$partial"; mkdir "$partial/.hermes-home"
bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$partial" && exit 1
pass=$((pass+1))

locked="$tmp/unwritable"; run_case "$locked"
NORTH_FORGE_TEST_UNWRITABLE=1 bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$locked" && exit 1
[ ! -e "$locked/.hermes-home" ] || exit 1
pass=$((pass+1))

existing="$tmp/existing"; run_case "$existing"; HERMES_HOME="$existing/.hermes-home" bash "$tmp/good installer.sh"
bash -c 'cd "$1"; . scripts/ensure-hermes.sh; ensure_drive_hermes "$PWD"' _ "$existing"
pass=$((pass+1))
echo "PASS: $pass drive-local Hermes scratch scenarios, including durable stage logs after a killed installer"
