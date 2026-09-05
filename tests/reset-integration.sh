#!/usr/bin/env bash
# Scratch-copy integration coverage for toggle-mode.sh RESET.
# toggle-mode.sh lives in Advanced/ and operates on the drive root one level
# up, so each fixture places the script at <fixture>/Advanced/toggle-mode.sh
# with the state files at <fixture>/.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGETS=(.env .forge-mode .hermes.md .drive-record.txt .provider-choice .agent-name .readme-shown .hermes/skills)
SCRATCH_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-reset.XXXXXX")"
trap 'rm -rf "$SCRATCH_ROOT"' EXIT

make_fixture() {
    local fixture="$1" target
    mkdir -p "$fixture/Advanced"
    cp "$REPO_ROOT/Advanced/toggle-mode.sh" "$fixture/Advanced/"
    for target in "${TARGETS[@]}"; do
        if [ "$target" = ".hermes/skills" ]; then
            mkdir -p "$fixture/$target"
            printf 'generated skill\n' > "$fixture/$target/test.md"
        else
            printf 'test state\n' > "$fixture/$target"
        fi
    done
    printf 'prior accountability event with Prior User name\n' > "$fixture/forge-events.log"
    printf 'keep me\n' > "$fixture/unrelated-file"
    mkdir -p "$fixture/.hermes-home/cron"
    printf 'secret and state\n' > "$fixture/.hermes-home/state.db"
    printf 'scheduled job\n' > "$fixture/.hermes-home/cron/job"
}

SUCCESS="$SCRATCH_ROOT/success"
make_fixture "$SUCCESS"
printf 'RESET\nRumpleStiltskin\nYES\n' | bash "$SUCCESS/Advanced/toggle-mode.sh" > "$SUCCESS/output.txt"
for target in "${TARGETS[@]}"; do
    [ ! -e "$SUCCESS/$target" ] || { echo "FAIL: RESET retained $target" >&2; exit 1; }
done
[ -f "$SUCCESS/forge-events.log" ] || { echo 'FAIL: RESET removed forge-events.log' >&2; exit 1; }
grep -q 'Prior User' "$SUCCESS/forge-events.log"
[ -f "$SUCCESS/unrelated-file" ]
grep -q 'secret and state' "$SUCCESS/.hermes-home/state.db"
grep -q 'scheduled job' "$SUCCESS/.hermes-home/cron/job"
grep -q 'credentials, memory, sessions, and cron state remain' "$SUCCESS/output.txt"
grep -q 'intentionally RETAINED as an accountability record' "$SUCCESS/output.txt"
grep -q 'can contain names entered by prior users' "$SUCCESS/output.txt"

REFUSAL="$SCRATCH_ROOT/refusal"
make_fixture "$REFUSAL"
if printf 'RESET\nRumpleStiltskin\nNO\n' | bash "$REFUSAL/Advanced/toggle-mode.sh" > "$REFUSAL/output.txt"; then
    echo 'FAIL: refused RESET returned success' >&2
    exit 1
fi
for target in "${TARGETS[@]}"; do
    [ -e "$REFUSAL/$target" ] || { echo "FAIL: refused RESET removed $target" >&2; exit 1; }
done
[ -f "$REFUSAL/forge-events.log" ]
[ -f "$REFUSAL/unrelated-file" ]

INCOMPLETE="$SCRATCH_ROOT/incomplete"
make_fixture "$INCOMPLETE"
rm "$INCOMPLETE/.env"
mkdir "$INCOMPLETE/.env"
printf 'cannot remove as a file\n' > "$INCOMPLETE/.env/blocker"
if printf 'RESET\nRumpleStiltskin\nYES\n' | bash "$INCOMPLETE/Advanced/toggle-mode.sh" > "$INCOMPLETE/output.txt" 2>&1; then
    echo 'FAIL: incomplete RESET returned success' >&2
    exit 1
fi
[ -d "$INCOMPLETE/.env" ]
grep -q 'ERROR: Could not remove .env' "$INCOMPLETE/output.txt"

echo 'PASS: RESET removes exactly eight state targets, retains the accountability log, rejects refusal, and reports incomplete deletion.'
