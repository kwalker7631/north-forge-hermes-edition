#!/usr/bin/env bash
# Scratch regression: a shared Hermes sentinel is deliberately first on PATH.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-drive-local.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/repo/scripts"
cp "$ROOT/scripts/ensure-hermes.sh" "$WORK/repo/scripts/"
mkdir -p "$WORK/shared-bin"
cat > "$WORK/shared-bin/hermes" <<'SHARED'
#!/usr/bin/env bash
echo shared >> "$SENTINEL_LOG"
exit 88
SHARED
# ensure_drive_hermes actually calls `curl -fsSL <url> -o "$installer"`, so a
# stub that ignores -o and just cats to stdout (the previous version of this
# fixture) never really exercises that hand-off - it silently degrades to
# "installer file never gets written," which happened to produce a plausible-
# looking but unrelated failure (installer exit 127, "command not found")
# instead of ever reaching real install logic. This stub honors -o.
cat > "$WORK/shared-bin/curl" <<'INSTALLER'
#!/usr/bin/env bash
out=""
prev=""
for arg in "$@"; do
    [ "$prev" = "-o" ] && out="$arg"
    prev="$arg"
done
[ -n "$out" ] || { echo "test curl stub: no -o argument given" >&2; exit 2; }
cat > "$out" <<'SCRIPT'
#!/usr/bin/env bash
set -eu
mkdir -p "$HERMES_HOME/hermes-agent" "$HERMES_HOME/bin"
: > "$HERMES_HOME/hermes-agent/pyproject.toml"
cat > "$HERMES_HOME/bin/hermes" <<'LOCAL'
#!/usr/bin/env bash
echo local >> "$LOCAL_LOG"
exit 0
LOCAL
chmod +x "$HERMES_HOME/bin/hermes"
SCRIPT
chmod +x "$out"
INSTALLER
chmod +x "$WORK/shared-bin/hermes" "$WORK/shared-bin/curl"
: > "$WORK/shared.log"; : > "$WORK/local.log"
(
  cd "$WORK/repo"
  PATH="$WORK/shared-bin:$PATH" SENTINEL_LOG="$WORK/shared.log" LOCAL_LOG="$WORK/local.log" \
    bash -c '. scripts/ensure-hermes.sh && ensure_drive_hermes "$PWD"'
)
[ -d "$WORK/repo/.hermes-home/hermes-agent" ]
[ -x "$WORK/repo/.hermes-home/bin/hermes" ]
[ ! -s "$WORK/shared.log" ] || { echo "FAIL: shared Hermes was called" >&2; exit 1; }
echo "PASS: fresh drive installed its local Hermes via the real curl -o hand-off and ignored the shared PATH sentinel"

# A curl that reports success (exit 0) but writes an empty/non-functional
# installer must still be refused, not silently accepted as a valid install.
BROKEN="$WORK/broken"
mkdir -p "$BROKEN/scripts"
cp "$ROOT/scripts/ensure-hermes.sh" "$BROKEN/scripts/"
mkdir -p "$WORK/broken-bin"
cat > "$WORK/broken-bin/curl" <<'EMPTY'
#!/usr/bin/env bash
out=""
prev=""
for arg in "$@"; do
    [ "$prev" = "-o" ] && out="$arg"
    prev="$arg"
done
[ -n "$out" ] && : > "$out"
exit 0
EMPTY
chmod +x "$WORK/broken-bin/curl"
status=0
(cd "$BROKEN" && PATH="$WORK/broken-bin:$PATH" bash -c '. scripts/ensure-hermes.sh && ensure_drive_hermes "$PWD"') \
    >"$WORK/broken-terminal.log" 2>&1 || status=$?
[ "$status" -ne 0 ] || { echo "FAIL: a curl exit 0 with an empty installer was accepted" >&2; exit 1; }
grep -q "installation failed or did not pass validation" "$WORK/broken-terminal.log"
[ -f "$BROKEN/.hermes-install-incomplete" ] || { echo "FAIL: incomplete marker was not left for recovery" >&2; exit 1; }
[ ! -e "$BROKEN/.hermes-home" ] || { echo "FAIL: an invalid install was activated as .hermes-home" >&2; exit 1; }
echo "PASS: a curl success with no runnable installer content fails clearly and leaves an incomplete marker, not an activated .hermes-home"
