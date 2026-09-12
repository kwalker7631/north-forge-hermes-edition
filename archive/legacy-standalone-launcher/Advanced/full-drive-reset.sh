#!/usr/bin/env bash
# Full drive purge: gateway first, then exactly this repo's .hermes-home.
set -u
# This script lives in Advanced/ but purges the drive root's .hermes-home.
# "$(dirname "$0")/.." is the drive root; scripts/ and forge-events.log
# below resolve against it.
cd "$(dirname "$0")/.." || exit 1
REPO="$(pwd -P)"
CANDIDATE="$REPO/.hermes-home"
if ! TARGET="$(python3 scripts/drive-reset-safety.py --action validate --repo "$REPO" --candidate "$CANDIDATE")"; then
    echo "Full drive purge stopped safely; nothing was deleted."
    exit 2
fi
echo "FULL DRIVE PURGE removes the local engine and ALL drive Hermes state:"
echo "  $TARGET"
echo "Credentials, memory, sessions, cron jobs, and logs will be unrecoverable."
echo "Help: copy the complete path above, paste it below, then press Enter."
read -r -p "Exact folder path: " CONFIRM
[ "$CONFIRM" = "$TARGET" ] || { echo "Cancelled - the path did not match; nothing was changed."; exit 1; }
command -v hermes >/dev/null 2>&1 || { echo "Safety stop: hermes is not on PATH, so the gateway cannot be checked."; exit 1; }
HERMES_HOME="$TARGET" hermes gateway stop || { echo "Safety stop: gateway stop failed; no files were deleted."; printf '[%s] [ERROR] [drive-purge]: gateway stop failed\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> forge-events.log; exit 1; }
HERMES_HOME="$TARGET" hermes gateway uninstall || { echo "Safety stop: gateway uninstall failed; no files were deleted."; printf '[%s] [ERROR] [drive-purge]: gateway uninstall failed\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> forge-events.log; exit 1; }
python3 scripts/drive-reset-safety.py --action purge --repo "$REPO" --candidate "$TARGET" --confirmed "$CONFIRM" || exit $?
printf '[%s] [INFO] [drive-purge]: exact .hermes-home removed\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> forge-events.log
echo "Done - this drive's Hermes engine and state were fully removed."
