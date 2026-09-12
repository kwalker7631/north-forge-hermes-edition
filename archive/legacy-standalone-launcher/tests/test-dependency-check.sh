#!/usr/bin/env bash
# Scratch-only checks for the launch-time Python 3 dependency gate added to
# launch-north-forge.sh. Nothing here touches the real machine's Python: the
# "missing" state is forced with NORTH_FORGE_DEP_FORCE_PY_MISSING and the
# install step is replaced with a mock via NORTH_FORGE_DEP_INSTALLER (same
# env-var-seam style tests/test-drive-hermes-install.sh already uses for the
# Hermes installer). No PATH shadowing - see CLAUDE.md's PATH-shadow rule.
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-dep-check.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
passes=0
fail() { echo "FAIL: $*" >&2; exit 1; }

# A full-enough copy for the cases that run PAST the gate (NORTH_FORGE_ASSEMBLE_ONLY=1).
new_case() {
    CASE="$SCRATCH/$1"
    mkdir -p "$CASE/scripts" "$CASE/home"
    cp "$ROOT/launch-north-forge.sh" "$CASE/"
    cp "$ROOT/scripts/name_validation.py" "$CASE/scripts/"
    cp -R "$ROOT/skills-source" "$CASE/"
    cp -R "$ROOT/mode-blocks" "$CASE/"
    cp "$ROOT/.hermes.template.md" "$CASE/"
    : > "$CASE/.readme-shown"
    printf 'Tester\n2026-01-01 00:00:00\n' > "$CASE/.drive-record.txt"
    printf 'North Forge\n' > "$CASE/.agent-name"
}
mk_installer() { printf '#!/usr/bin/env bash\nexit %s\n' "$2" > "$1"; chmod +x "$1"; }

run() {  # run <stdin-string> <env...> -- ; sets RC, OUT, LOG
    local input="$1"; shift
    RC=0
    OUT="$(cd "$CASE" && printf '%s' "$input" | env HOME="$CASE/home" "$@" \
        bash ./launch-north-forge.sh 2>&1)" || RC=$?
    LOG="$(cat "$CASE/forge-events.log" 2>/dev/null || true)"
}

# 1. Fast path: real python3 present -> no prompt, one INFO line, runs on past
#    the gate (assemble-only exit 0).
new_case fast-path
run '' NORTH_FORGE_ASSEMBLE_ONLY=1
[ "$RC" -eq 0 ] || fail "fast-path: expected rc 0, got $RC ($OUT)"
case "$OUT" in *"needs Python 3 to run"*) fail "fast-path: should not have prompted";; esac
case "$LOG" in *"[INFO] [deps]: Python 3 present"*) ;; *) fail "fast-path: missing 'Python 3 present' log line";; esac
passes=$((passes + 1))

# 2. Missing + operator types 'n' -> clean exit 1, manual help, logged decline,
#    installer never invoked.
new_case decline
mk_installer "$SCRATCH/never.sh" 0
run 'n
' NORTH_FORGE_DEP_FORCE_PY_MISSING=always NORTH_FORGE_DEP_INSTALLER="$SCRATCH/never.sh"
[ "$RC" -eq 1 ] || fail "decline: expected rc 1, got $RC"
case "$OUT" in *"needs Python 3 to run"*) ;; *) fail "decline: missing the prompt text";; esac
case "$OUT" in *"can't start without Python 3"*) ;; *) fail "decline: missing manual instructions";; esac
case "$LOG" in *"operator declined the Python 3 install"*) ;; *) fail "decline: not logged";; esac
passes=$((passes + 1))

# 3. Missing gate + ENTER (default yes) + mock installer succeeds + the
#    post-install re-check finds the real interpreter -> continues past the gate.
new_case approve-ok
mk_installer "$SCRATCH/ok.sh" 0
run '
' NORTH_FORGE_ASSEMBLE_ONLY=1 NORTH_FORGE_DEP_FORCE_PY_MISSING=1 NORTH_FORGE_DEP_INSTALLER="$SCRATCH/ok.sh"
[ "$RC" -eq 0 ] || fail "approve-ok: expected rc 0, got $RC ($OUT)"
case "$LOG" in *"operator approved the Python 3 install"*) ;; *) fail "approve-ok: approval not logged";; esac
case "$LOG" in *"[INFO] [deps]: Python 3 installed and verified"*) ;; *) fail "approve-ok: verify line missing";; esac
passes=$((passes + 1))

# 4. Missing + yes + mock installer fails (exit 7) -> exit 1, failure logged
#    with the exact code, manual help shown.
new_case approve-installer-fails
mk_installer "$SCRATCH/boom.sh" 7
run '
' NORTH_FORGE_DEP_FORCE_PY_MISSING=always NORTH_FORGE_DEP_INSTALLER="$SCRATCH/boom.sh"
[ "$RC" -eq 1 ] || fail "installer-fails: expected rc 1, got $RC"
case "$LOG" in *"Python 3 installer exited 7"*) ;; *) fail "installer-fails: exit code not logged";; esac
case "$OUT" in *"did not finish successfully (exit 7)"*) ;; *) fail "installer-fails: no clear message";; esac
passes=$((passes + 1))

# 5. Missing + yes + mock installer 'succeeds' but python still absent
#    (FORCE=always keeps the re-check empty too) -> exit 1, distinct log line.
new_case approve-still-missing
mk_installer "$SCRATCH/ok2.sh" 0
run '
' NORTH_FORGE_DEP_FORCE_PY_MISSING=always NORTH_FORGE_DEP_INSTALLER="$SCRATCH/ok2.sh"
[ "$RC" -eq 1 ] || fail "still-missing: expected rc 1, got $RC"
case "$LOG" in *"reported success but Python 3 is still not detectable"*) ;; *) fail "still-missing: wrong/no log line";; esac
passes=$((passes + 1))

# 6. Missing + no interactive terminal + no test seam -> refuse to auto-download
#    something unattended, exit 1, say why.
new_case non-interactive
run '' NORTH_FORGE_DEP_FORCE_PY_MISSING=always
[ "$RC" -eq 1 ] || fail "non-interactive: expected rc 1, got $RC"
case "$LOG" in *"no interactive terminal to confirm the install"*) ;; *) fail "non-interactive: not logged";; esac
passes=$((passes + 1))

echo "PASS: $passes launch-time dependency-check scenarios"
