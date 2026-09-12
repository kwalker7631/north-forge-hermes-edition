# Codex Repository Scope and README Review

Timestamp: 2026-09-12 UTC  
Requested task: review the repository's scope and polish or improve the README if needed.

## Files inspected

- `README.md`
- `CURRENT.md`
- `distribution.yaml`
- `Advanced/deploy-console/DEPLOY.md`
- `CLAUDE.md` and `AGENTS.md` (repository authority and reporting rules)
- The tracked file inventory, especially `skills/`, `skills-source/`, `archive/`,
  `tests/`, and `scripts/`
- The most recent README changes in commits `015cb1d` and `1cfdf98`
- The pre-existing working-tree diff in
  `Advanced/deploy-console/Launch-Deploy-Console.cmd`

## Scope assessment

The repository is a private Kyocera manufacturer profile for the public North
Forge chassis. Its active scope is field-support content and workflows for
print, scan, finishing, paper path, supplies, host computers, networks,
PaperCut, MyQ, hotline intake, knowledge-base drafting, escalation, fault
logging, training, sales assistance, and public-source research. It also
contains Windows-oriented deployment tooling for administrators. It is not a
standalone runtime: `distribution.yaml` identifies it as a Hermes profile, and
the retired standalone launchers are isolated under `archive/`.

The README communicates that boundary accurately and much more concisely than
the older standalone-oriented version. It also separates the two audiences:
technicians receive a prepared USB drive, while administrators use the deploy
console or install the profile into the public chassis.

## Findings

### SCOPE-01 — LOW — The README already reflects the current profile-pack architecture

The scope, handoff, architecture, skill catalog, manual-install path, and
governance sections form a short, useful front door. The two immediately prior
commits already rewrote and polished this content, including removing obsolete
FULL/SALES framing. A further broad rewrite now would add churn without a clear
operator benefit.

### SCOPE-02 — LOW — The README could be slightly easier for a first-time Windows administrator

The manual-install section starts with an SSH-form Git URL and command snippets
without explicitly telling a minimally technical Windows operator where to run
them. The linked deploy-console guide is the safer path and is already described
as the no-Git route. In a future owner-approved revision, consider labeling the
manual path as “advanced,” linking directly to
`Advanced/deploy-console/ADMIN_FIRST_TIME.txt`, and adding one short sentence
such as “Open PowerShell in the public North Forge folder before running these
commands.” The tradeoff is length: adding more setup detail to the repository
front door duplicates the dedicated deployment guide.

### SCOPE-03 — MEDIUM — `/readme` placement should be reconciled before documenting it further

The README advertises `/readme`, and HEAD contains
`skills-source/shared/readme/SKILL.md`, but the profile's directly installable
`skills/` tree does not contain a `readme` folder. `CURRENT.md` likewise omits
`readme` from its catalog. This may be intentional if the public chassis
assembles shared skills into the installed profile, but that behavior cannot be
proved from this repository alone. The owner should either confirm the chassis
assembly contract or place the skill in the location consumed by profile
installation. Until then, expanding the README claim would risk misleading an
operator.

Follow-up (same day): `skills/readme/SKILL.md` added and `CURRENT.md` catalog
updated so `/readme` is in the tree the profile actually loads.

### SCOPE-04 — INFORMATIONAL — README changes are outside Codex's edit authority

`CLAUDE.md` explicitly classifies `README.md` as Zone B, authored user-facing
content. `AGENTS.md` directs Codex to consult and respect that authority model.
The request asked for a review and possible improvement, but did not provide a
specific, pre-approved README revision for placement. The governing rule says
even a broad request to fix issues does not authorize composing Zone B content.
Consequently, this session reviewed the README but did not edit it. The concrete
recommendations above are preserved for the Blacksmith or Claude Project chat
to approve and hand off.

### SCOPE-05 — MEDIUM — Standalone-launcher tests remain active after the launcher was retired

The full Python discovery run executes tests that still open the former root
launchers (`launch-north-forge.sh` and `launch-north-forge.bat`) and
`scripts/hermes-drive.sh`. Those production files were removed or archived
during the move to the profile architecture, so 9 cases error with
`FileNotFoundError`. The four tests covering still-active Python helpers and
static assets pass. This is a maintenance regression rather than a README
defect: a future Zone A change should either move the old tests alongside the
archived launcher or replace them with tests of the current profile contract.

### WORKTREE-01 — INFORMATIONAL — An unrelated modification was preserved

`Advanced/deploy-console/Launch-Deploy-Console.cmd` had an uncommitted
line-ending-only change before this review began. This session did not stage,
modify, or include it in its commit.

## Verification performed

- Compared the complete README with `CURRENT.md`, `distribution.yaml`, and the
  deploy-console documentation.
- Enumerated tracked files and compared the documented skill catalog with both
  `skills/` and `skills-source/`.
- Reviewed the last two README commits to distinguish current design choices
  from stale text.
- Ran a local Markdown-link check across `README.md`; all 3 local links and
  image targets resolved.
- Ran the Python test suite with `python -m unittest discover -s tests -p
  'test_*.py'`; 3 cases passed and 9 errored because retired standalone
  launcher files no longer exist at their old paths.
- Ran the active helper and asset tests separately with `python -m unittest
  tests.test_name_validation tests.test_drive_reset_safety
  tests.test_drive_hermes_contract tests.test_static_html_assets`; all 4 passed.
- Ran `git diff --check`; it reported no whitespace errors in this session's
  changes.

No test was added because no application logic or user documentation was
changed; adding unrelated test code solely to satisfy the review would reduce
signal rather than protect behavior.

## Diff summary

Added this audit report only. It records the repository boundary, confirms that
the recently polished README is broadly accurate, identifies the uncertain
`/readme` installation contract and stale standalone-launcher tests, and
explains why the protected README was not edited. Watch for the separately
owned line-ending change in the deploy-console launcher; it is intentionally
excluded.

## Status

**COMPLETE — repository scope reviewed and recommendations recorded; no README
change was made because the current README is already concise and any further
authored-content revision requires an approved Zone B handoff.**
