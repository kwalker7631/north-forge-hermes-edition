#!/usr/bin/env bash
# Scratch-only end-to-end check that two drives never share Hermes state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/north-forge-two-drive.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

SHARED_HOME="$SCRATCH/fake-host"
SHARED_HERMES="$SHARED_HOME/.hermes"
BIN="$SCRATCH/bin"
INVOCATIONS="$SCRATCH/invocations.log"
mkdir -p "$SHARED_HERMES/cron" "$BIN"
printf 'shared config sentinel\n' > "$SHARED_HERMES/config.yaml"
printf 'shared cron sentinel\n' > "$SHARED_HERMES/cron/jobs.tsv"
touch -t 202001020304.05 "$SHARED_HERMES/config.yaml" "$SHARED_HERMES/cron/jobs.tsv"
CONFIG_BEFORE="$(stat -c '%Y:%s' "$SHARED_HERMES/config.yaml")"
CRON_BEFORE="$(stat -c '%Y:%s' "$SHARED_HERMES/cron/jobs.tsv")"

cat > "$BIN/hermes" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
home="$(python3 -c 'import os; print(os.path.realpath(os.environ.get("HERMES_HOME", os.path.expanduser("~/.hermes"))))')"
cwd="$(pwd -P)"
printf '%s|%s' "$home" "$cwd" >> "$FAKE_INVOCATION_LOG"
printf '|%q' "$@" >> "$FAKE_INVOCATION_LOG"
printf '\n' >> "$FAKE_INVOCATION_LOG"
mkdir -p "$home/cron"
db="$home/cron/jobs.tsv"
case "${1:-}" in
  config)
    printf '%s %s\n' "${2:-}" "${3:-}" >> "$home/config.yaml"
    ;;
  cron)
    case "${2:-}" in
      list) [ ! -f "$db" ] || cat "$db" ;;
      add)
        name=""
        for ((i=1; i<=$#; i++)); do
          if [ "${!i}" = --name ]; then j=$((i + 1)); name="${!j}"; fi
        done
        printf '%s\t%s\t%s\n' "$name" "$cwd" "$home" >> "$db"
        ;;
      run-simulated)
        row="$(awk -F '\t' -v wanted="${3:-}" '$1 == wanted { print; exit }' "$db")"
        [ -n "$row" ] || exit 44
        IFS=$'\t' read -r name saved_cwd saved_home <<< "$row"
        [ "$cwd" = "$saved_cwd" ] && [ "$home" = "$saved_home" ] || exit 45
        printf '%s|%s|%s\n' "$name" "$cwd" "$home" >> "$FAKE_JOB_LOG"
        ;;
    esac
    ;;
esac
FAKE
chmod +x "$BIN/hermes"
cat > "$BIN/xdg-open" <<'FAKE'
#!/usr/bin/env bash
exit 0
FAKE
chmod +x "$BIN/xdg-open"

for drive in drive-a drive-b; do
    mkdir "$SCRATCH/$drive"
    (cd "$ROOT" && tar --exclude=.git --exclude=.hermes --exclude=.hermes-home -cf - .) |
        (cd "$SCRATCH/$drive" && tar -xf -)
    # Drive owner, assistant name, then ENTER for the free provider.
    printf '%s\n%s\n\n' "Owner ${drive#drive-}" "Forge ${drive#drive-}" |
        env HOME="$SHARED_HOME" HERMES_HOME="$SHARED_HERMES" \
            PATH="$BIN:$PATH" FAKE_INVOCATION_LOG="$INVOCATIONS" \
            bash "$SCRATCH/$drive/launch-north-forge.sh" > "$SCRATCH/$drive/onboarding.log"
    [ -f "$SCRATCH/$drive/.drive-record.txt" ] || fail "$drive has no drive record"
    [ -f "$SCRATCH/$drive/.provider-choice" ] || fail "$drive has no provider choice"
    [ -f "$SCRATCH/$drive/.hermes.md" ] || fail "$drive has no assembled prompt"
    [ -f "$SCRATCH/$drive/.hermes/skills/daily-brief/SKILL.md" ] || fail "$drive has no assembled skills"
    [ -f "$SCRATCH/$drive/.hermes-home/cron/jobs.tsv" ] || fail "$drive has no cron store"
done

SHARED_CANON="$(cd "$SHARED_HERMES" && pwd -P)"
! awk -F '|' -v shared="$SHARED_CANON" '$1 == shared { bad=1 } END { exit bad ? 0 : 1 }' "$INVOCATIONS" ||
    fail "an onboarding invocation used the host's shared Hermes directory"

for drive in drive-a drive-b; do
    repo="$(cd "$SCRATCH/$drive" && pwd -P)"
    home="$repo/.hermes-home"
    (cd "$repo" && env -i HOME="$SHARED_HOME" PATH="$BIN:/usr/bin:/bin" HERMES_HOME="$home" \
        FAKE_INVOCATION_LOG="$INVOCATIONS" hermes cron add '* * * * *' sentinel \
        --name "sentinel-$drive" >/dev/null < /dev/null)
done

DB_A="$SCRATCH/drive-a/.hermes-home/cron/jobs.tsv"
DB_B="$SCRATCH/drive-b/.hermes-home/cron/jobs.tsv"
grep -q 'sentinel-drive-a' "$DB_A" || fail 'drive-a sentinel is missing'
! grep -q 'sentinel-drive-b' "$DB_A" || fail 'drive-a cron database contains drive-b sentinel'
grep -q 'sentinel-drive-b' "$DB_B" || fail 'drive-b sentinel is missing'
! grep -q 'sentinel-drive-a' "$DB_B" || fail 'drive-b cron database contains drive-a sentinel'

JOB_LOG="$SCRATCH/jobs.log"
for drive in drive-a drive-b; do
    repo="$(cd "$SCRATCH/$drive" && pwd -P)"
    # env -i proves the simulated scheduler does not inherit launcher state.
    (cd "$repo" && env -i HOME="$SHARED_HOME" PATH="$BIN:/usr/bin:/bin" \
        HERMES_HOME="$repo/.hermes-home" FAKE_INVOCATION_LOG="$INVOCATIONS" \
        FAKE_JOB_LOG="$JOB_LOG" hermes cron run-simulated "sentinel-$drive")
    grep -Fxq "sentinel-$drive|$repo|$repo/.hermes-home" "$JOB_LOG" ||
        fail "$drive job did not resolve its original repository and Hermes home"
done

[ "$(cat "$SHARED_HERMES/config.yaml")" = 'shared config sentinel' ] || fail 'shared config contents changed'
[ "$(cat "$SHARED_HERMES/cron/jobs.tsv")" = 'shared cron sentinel' ] || fail 'shared cron contents changed'
[ "$(stat -c '%Y:%s' "$SHARED_HERMES/config.yaml")" = "$CONFIG_BEFORE" ] || fail 'shared config timestamp changed'
[ "$(stat -c '%Y:%s' "$SHARED_HERMES/cron/jobs.tsv")" = "$CRON_BEFORE" ] || fail 'shared cron timestamp changed'

echo 'PASS: two scratch drives keep onboarding, cron stores, and clean-environment jobs isolated.'
