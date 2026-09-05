#!/usr/bin/env bash
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/north forge hermes home.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# Stop at the launcher's first Python call after recording the exported value.
# This isolates the home bootstrap while still executing the real launcher.
mkdir -p "$SCRATCH/repository with spaces/bin"
cp "$ROOT/launch-north-forge.sh" "$SCRATCH/repository with spaces/"
: > "$SCRATCH/repository with spaces/.readme-shown"
cat > "$SCRATCH/repository with spaces/bin/python3" <<'PYTHON'
#!/usr/bin/env bash
printf '%s\n' "$HERMES_HOME" > observed-hermes-home.txt
exit 42
PYTHON
chmod +x "$SCRATCH/repository with spaces/bin/python3"

status=0
(cd "$SCRATCH/repository with spaces" && \
    PATH="$SCRATCH/repository with spaces/bin:$PATH" \
    HERMES_HOME="$SCRATCH/shared host state" \
    bash ./launch-north-forge.sh) >/dev/null 2>&1 || status=$?
[ "$status" -eq 42 ] || fail "launcher returned $status instead of the Python sentinel status"
expected="$SCRATCH/repository with spaces/.hermes-home"
[ "$(cat "$SCRATCH/repository with spaces/observed-hermes-home.txt")" = "$expected" ] || \
    fail "caller-supplied HERMES_HOME redirected the launcher"
[ -d "$expected" ] || fail "drive-local Hermes home was not created"
[ -z "$(find "$expected" -name '.north-forge-write-probe.*' -print -quit)" ] || \
    fail "temporary write probe was retained"

# A file at the required directory path proves the create/type failure is both
# explained on screen and recorded before any later helper can run.
mkdir -p "$SCRATCH/broken case"
cp "$ROOT/launch-north-forge.sh" "$SCRATCH/broken case/"
: > "$SCRATCH/broken case/.hermes-home"
status=0
(cd "$SCRATCH/broken case" && bash ./launch-north-forge.sh) >"$SCRATCH/broken-output.txt" 2>&1 || status=$?
[ "$status" -eq 1 ] || fail "invalid Hermes home returned $status"
grep -q "could not create its drive-local Hermes home" "$SCRATCH/broken-output.txt" || \
    fail "terminal error did not explain the create failure"
grep -q '\[FAILURE\] \[hermes-home\]' "$SCRATCH/broken case/forge-events.log" || \
    fail "create failure was not logged"

echo "PASS: drive-local Hermes home works in spaced paths and rejects caller overrides"
