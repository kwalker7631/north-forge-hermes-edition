#!/usr/bin/env bash
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-test.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

run_case() {
    name="$1" set_status="$2" unset_status="$3" unset_message="$4" expected_status="$5" expected_marker="$6"
    work="$TMP_ROOT/$name"
    mkdir -p "$work/bin"
    cp "$ROOT/launch-north-forge.sh" "$work/"
    cat > "$work/bin/hermes" <<'FAKE'
#!/usr/bin/env bash
if [ "$1 $2 $3" = "config set model.provider" ]; then
    echo "${FAKE_SET_MESSAGE:-provider set}"
    exit "${FAKE_SET_STATUS:-0}"
fi
if [ "$1 $2 $3" = "config unset model.default" ]; then
    [ -z "${FAKE_UNSET_MESSAGE:-}" ] || echo "$FAKE_UNSET_MESSAGE" >&2
    exit "${FAKE_UNSET_STATUS:-0}"
fi
exit 99
FAKE
    chmod +x "$work/bin/hermes"

    status=0
    (cd "$work" && PATH="$work/bin:$PATH" FAKE_SET_STATUS="$set_status" \
        FAKE_UNSET_STATUS="$unset_status" FAKE_UNSET_MESSAGE="$unset_message" \
        bash ./launch-north-forge.sh --configure-free-provider) >"$work/terminal.txt" 2>&1 || status=$?

    [ "$status" -eq "$expected_status" ] || fail "$name returned $status, expected $expected_status"
    if [ "$expected_marker" = "free" ]; then
        [ "$(cat "$work/.provider-choice" 2>/dev/null)" = "free" ] || fail "$name did not write the free marker"
    else
        [ ! -e "$work/.provider-choice" ] || fail "$name left a provider marker after failure"
        grep -q "\[FAILURE\] \[provider-config\]" "$work/forge-events.log" || fail "$name did not log a diagnostic"
        ! grep -q "supersecret" "$work/forge-events.log" || fail "$name wrote a credential to the log"
    fi
}

run_case success        0  0  "default removed"                    0  free
run_case failed-set     23 0  ""                                  23 absent
run_case failed-unset   0  37 "unexpected failure api_key=supersecret" 37 absent
run_case already-absent 0  1  "Config key not set: model.default"  0  free

echo "PASS: all four isolated fake-Hermes provider cases"
