# Hermes cron/gateway home audit (2026-09-05)

The build container does not contain a Hermes executable or Python package
(`command -v hermes` and Python's `find_spec("hermes")`/`find_spec("hermes_cli")`
all returned no result). Consequently there are no installed upstream module
paths in this image to quote for `cron add`, the cron-store resolver, gateway
installation, Task Scheduler, launchd, or Linux service generation. Network
access to the Hermes installer and upstream source was also denied (HTTP 403).
This is an environment limitation, not evidence that a particular Hermes
release does or does not preserve `HERMES_HOME`.

North Forge therefore takes the conservative path: its relevant local modules
are `scripts/hermes-drive.sh`, `scripts/hermes-drive.ps1`,
`launch-north-forge.sh`, and `launch-north-forge.bat`. The launchers establish
the canonical `<repo>/.hermes-home` before `cron add`; cron registration goes
through the repository wrapper, which independently restores that absolute home
and repository working directory before invoking only a drive-local Hermes
executable. Thus a gateway/service definition which preserves the registration
environment receives `HERMES_HOME`, while a definition which records the
registration executable records the stable wrapper. Neither path depends on a
transient desktop launcher's environment or a PATH lookup.

The focused test in `tests/test_cron_registration.py` models the service
definition and a scheduler with no inherited `HERMES_HOME`. It registers one job
on each of two scratch drives and verifies that each execution sees only its own
cron/config files. A second test removes `.hermes-home` and verifies exit 72, a
short diagnostic, and—most importantly—no replacement shared home.
