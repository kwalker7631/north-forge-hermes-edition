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
# The write-probe step (ahead of this python3 sentinel) must only prove the
# drive is writable - it must NOT create .hermes-home itself. Doing so used to
# make ensure_drive_hermes (scripts/ensure-hermes.sh) treat every fresh drive
# as a "partial or damaged" install before the real installer ever ran
# (reproduced empirically 2026-09-05). Actual creation happens later, only
# inside ensure_drive_hermes, once install/validation succeeds.
[ ! -e "$expected" ] || \
    fail "REGRESSION: .hermes-home was created before ensure_drive_hermes ran (write-probe side effect reintroduced)"
[ -z "$(find "$SCRATCH/repository with spaces" -maxdepth 1 -name '.north-forge-write-probe.*' -print -quit)" ] || \
    fail "temporary write probe was retained"

# A pre-existing, non-empty-but-invalid .hermes-home (a plain file here) must
# be refused by ensure_drive_hermes, not silently overwritten - proves the
# create/type failure is both explained on screen and recorded before any
# later helper can run. Needs the full repo (not just the launcher script)
# so the launcher actually reaches ensure_drive_hermes instead of failing
# earlier on a missing scripts/skills-source dependency.
mkdir -p "$SCRATCH/broken case"
(cd "$ROOT" && tar --exclude=.git --exclude=.hermes --exclude=.hermes-home \
    --exclude=install-logs --exclude=.drive-record.txt --exclude=.agent-name \
    --exclude=.provider-choice --exclude=.readme-shown --exclude=.forge-mode \
    --exclude=.env --exclude=forge-events.log -cf - .) |
    (cd "$SCRATCH/broken case" && tar -xf -)
: > "$SCRATCH/broken case/.hermes-home"
status=0
(cd "$SCRATCH/broken case" && bash ./launch-north-forge.sh </dev/null) >"$SCRATCH/broken-output.txt" 2>&1 || status=$?
[ "$status" -eq 20 ] || fail "invalid Hermes home returned $status instead of ensure_drive_hermes's exit 20"
grep -q "partial or damaged .hermes-home" "$SCRATCH/broken-output.txt" || \
    fail "terminal error did not explain the partial/damaged .hermes-home"

echo "PASS: drive-local Hermes home works in spaced paths and rejects caller overrides"
