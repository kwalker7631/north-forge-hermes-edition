# Claude Code Session Audit

Timestamp: 2026-09-11 (session start ~D:\ drive, real-drive check against E:\ GREG-NORTH)
Requested task: Confirm where the root-drive "North Forge.lnk" shortcut is actually supposed
to get created, and why it ended up inside the checkout folder instead of at the drive root
(E:\) on the real Greg-North install. Determine whether launch-north-forge.bat/.sh creates
the root-drive shortcut itself, or whether that's solely provision-new-drive.ps1's job; if the
launcher placed it wrong, fix it; if it's meant to require a separate provisioning step, say so
plainly.

## Files inspected
- `launch-north-forge.bat` (root-drive shortcut block, lines ~108-136 pre-fix)
- `launch-north-forge.sh` (confirmed no drive-root `.lnk` logic exists on the Mac/Linux side -
  Desktop `.command` only, at line 250; `.lnk`/COM shortcuts are Windows-only by design)
- `Advanced/provision-new-drive.ps1` (root-drive shortcut block, lines ~126-147 pre-fix)
- `tests/provision-new-drive.Tests.ps1`
- Real installed state on `E:\` (GREG-NORTH, exFAT, the actual Greg-North drive):
  `E:\north-forge-hermes-edition\North Forge.lnk` (misplaced, timestamp 2026-09-11 01:26,
  matches `forge-events.log` line 5: `[INFO] [shortcut]: drive-root North Forge.lnk created
  with icon`), `E:\north-forge-hermes-edition\forge-events.log`, `.drive-record.txt`
  (registered to GREGW at 01:26:39, same run). No `E:\North Forge.lnk` existed at the true
  root at any point observed. No evidence in `forge-events.log` that `provision-new-drive.ps1`
  ever ran on this drive (no git-clone-stage log lines, no PS "Placed a 'North Forge'
  shortcut..." message) - the repo there was set up by a plain `git clone` directly into
  `E:\north-forge-hermes-edition`, then launched via `launch-north-forge.bat`.

## Finding

Both `launch-north-forge.bat` and `Advanced/provision-new-drive.ps1` create the drive-root
shortcut **themselves** - this is not a "must run provisioning separately" situation; the
launcher's own first-run block is explicitly meant to (re)create it every time it's missing,
independent of whether `provision-new-drive.ps1` ever ran. Confirmed by reading the code and by
`forge-events.log` line 5 on the real drive, which is the launcher's own log line, not the
provisioning script's.

The bug: both scripts built the shortcut's path by joining against their **own** directory
instead of the actual drive root.
- `launch-north-forge.bat` used `%~dp0North Forge.lnk` - `%~dp0` is the batch file's own
  directory, i.e. `E:\north-forge-hermes-edition\`, not `E:\`.
- `provision-new-drive.ps1` used `Join-Path $repositoryPath "North Forge.lnk"` -
  `$repositoryPath` is always `Join-Path "${target}:\" "north-forge-hermes-edition"`, the same
  one-level-too-deep folder, never the bare `${target}:\`.

Both scripts' own comments say "the drive root" / "drive's own root," so this was a genuine
logic bug (using the checkout folder as a stand-in for the drive root, which is only correct
if the repo were ever cloned directly to `X:\` with no subfolder - it never is; provisioning
always uses the `north-forge-hermes-edition` subfolder). Reproduced live: `E:\` root has no
`North Forge.lnk`; `E:\north-forge-hermes-edition\North Forge.lnk` does, with a creation
timestamp matching the launcher's own log line.

## Zone A changes made

1. `launch-north-forge.bat` (lines ~108-138): replaced `%~dp0North Forge.lnk` (checkout folder)
   with a new `ROOTSHORTCUT` variable built from `%~d0\North Forge.lnk` (`%~d0` = drive letter
   only, so this is always the true root regardless of how deep the launcher itself is nested).
   Existence checks, the PowerShell `CreateShortcut` call, and both success/failure log lines
   now all reference `%ROOTSHORTCUT%`; `TargetPath`, `WorkingDirectory`, and `IconLocation`
   still correctly point back into the checkout folder (`%~f0` / `%~dp0`). Variable is cleared
   after the block.
2. `Advanced/provision-new-drive.ps1` (line ~132): replaced
   `Join-Path $repositoryPath "North Forge.lnk"` with `Join-Path "${target}:\" "North Forge.lnk"`
   so the provisioning script's shortcut lands at the same true root, matching the launcher's
   fixed behavior. `TargetPath`/`WorkingDirectory`/`IconLocation` unchanged (still reference the
   checkout folder correctly).

Verified on scratch state only, per instruction not to touch the real Greg-North drive: mapped
a temp folder to a virtual drive letter (`subst Z: <scratch temp dir>`) with a
`Z:\north-forge-hermes-edition\` subfolder mirroring the real layout, extracted the fixed batch
snippet into a standalone test `.bat` there, ran it, and confirmed `North Forge.lnk` was created
at `Z:\North Forge.lnk` (true root) rather than inside the subfolder. Unmapped the virtual drive
and deleted the scratch folder afterward. Did not run the fix against `E:\` at all - the real
drive's existing misplaced shortcut was left untouched (observed only, not modified) per the "no
destructive changes to the real Greg-North drive" instruction; next real launch of the fixed
`launch-north-forge.bat` on `E:\` will create the correct `E:\North Forge.lnk` (the stray one
inside the checkout folder will remain unless someone deletes it by hand - not done this session
since it wasn't asked for and isn't destructive to leave in place).

Ran `tests\provision-new-drive.Tests.ps1` before and after the fix
(`powershell -NoProfile -ExecutionPolicy Bypass -File tests\provision-new-drive.Tests.ps1`): it
fails both before and after my change on an unrelated, pre-existing assertion -
`TEST FAILED: Mac/Linux launcher must target its own .hermes-home` - because the test's regex
(`export HERMES_HOME="\$\(pwd\)/\.hermes-home"`) no longer matches
`launch-north-forge.sh`'s actual current line (`export HERMES_HOME="$(pwd -P)/.hermes-home"`,
line 10 - a `-P` flag was added at some point after the test was written). This is a stale test
expectation unrelated to the shortcut fix; not touched this session (out of scope for the task
asked, and the STANDING RULE in this file about not silently reverting/altering things without
being sure of intent applies - flagging it below instead).

## Zone B findings (not fixed - reported only)

None found this session (task did not touch Zone B files).

## Commits made this session

- `6c54c37` - "Fix drive-root North Forge.lnk landing in checkout folder, not drive root"
  (`Advanced/provision-new-drive.ps1`, `launch-north-forge.bat`). Pushed to `origin/main`
  (`d7494f0..6c54c37`).
- This audit report commit (see git log after this file is committed).

## Uncertain / flagged for primary GPT review

1. **Stale test assertion** in `tests\provision-new-drive.Tests.ps1` (line 26/27): the
   `.hermes-home` regex for `launch-north-forge.sh` doesn't match the script's current
   `$(pwd -P)` line. Pre-existing (reproduced on unmodified `main` before this session's
   changes), unrelated to the shortcut fix, not touched. Should be reconciled - either the test
   regex needs `-P` added, or the `.sh` script's `-P` addition needs re-justifying against the
   test's intent - by someone with context on why `-P` was added.
2. **Stray misplaced shortcut left on the real `E:\` drive**: `E:\north-forge-hermes-edition\
   North Forge.lnk` still exists from before the fix. Not deleted this session (out of scope,
   not destructive to leave, and deleting real-drive files wasn't part of the ask). The fixed
   launcher will create the correct `E:\North Forge.lnk` on next launch but will not clean up
   the old misplaced one automatically (its `if not exist` guard only checks the new correct
   path). Flagging in case a cleanup step is wanted later.
3. Two pre-existing untracked files in the working tree at session start, not created or touched
   by this session, left as-is: `north-forge-hermes-edition-logs_2026-09-10_2324.zip` and its
   `.sha256`.

## Status

Clean - task completed and verified on scratch state; two items above flagged for awareness,
neither blocking.
