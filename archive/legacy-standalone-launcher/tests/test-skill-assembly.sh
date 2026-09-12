#!/usr/bin/env bash
set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
SCRATCH=$(mktemp -d "${TMPDIR:-/tmp}/north-forge-skills-test.XXXXXX")
trap 'rm -rf "$SCRATCH"' EXIT
passes=0

new_case() {
    CASE="$SCRATCH/$1"
    mkdir -p "$CASE/.hermes/skills" "$CASE/home/Desktop" "$CASE/scripts"
    cp "$REPO/launch-north-forge.sh" "$CASE/"
    cp "$REPO/scripts/name_validation.py" "$CASE/scripts/"
    cp -R "$REPO/skills-source" "$CASE/"
    : > "$CASE/.readme-shown"
    printf 'Tester\n' > "$CASE/.drive-record.txt"
    printf 'old build\n' > "$CASE/.hermes/skills/OLD_BUILD"
}

run_ok() {
    (cd "$CASE" && printf '\n' | HOME="$CASE/home" NORTH_FORGE_ASSEMBLE_ONLY=1 bash ./launch-north-forge.sh >/dev/null)
}

run_failure_preserves_old() {
    if (cd "$CASE" && printf '\n' | HOME="$CASE/home" NORTH_FORGE_ASSEMBLE_ONLY=1 "$@" bash ./launch-north-forge.sh >output.log 2>&1); then
        echo "FAIL: $CASE unexpectedly succeeded" >&2; exit 1
    fi
    test -f "$CASE/.hermes/skills/OLD_BUILD"
    test -z "$(find "$CASE/.hermes" -maxdepth 1 -type d \( -name '.skills-staging-*' -o -name '.skills-backup-*' \) -print -quit)"
    grep -q 'ERROR:' "$CASE/output.log"
    passes=$((passes + 1))
}

new_case sales-success
run_ok
test -f "$CASE/.hermes/skills/menu/SKILL.md"
test ! -e "$CASE/.hermes/skills/assist-intake"
test ! -e "$CASE/.hermes/skills/OLD_BUILD"
passes=$((passes + 1))

new_case full-success
printf 'full\n' > "$CASE/.forge-mode"
run_ok
test -f "$CASE/.hermes/skills/menu/SKILL.md"
test -f "$CASE/.hermes/skills/assist-intake/SKILL.md"
passes=$((passes + 1))

new_case missing-source
rm -rf "$CASE/skills-source"
run_failure_preserves_old env

new_case missing-skill-file
rm "$CASE/skills-source/shared/menu/SKILL.md"
run_failure_preserves_old env

new_case copy-failure
run_failure_preserves_old env NORTH_FORGE_TEST_FAIL_COPY=1

new_case swap-failure
run_failure_preserves_old env NORTH_FORGE_TEST_FAIL_SWAP=1

printf 'PASS: %s scratch skill-assembly scenarios\n' "$passes"
