# Building a Round Table Drive - The Real Walkthrough

Called **Excalibur** before 2026-09-14 (see [EXCALIBUR.md](EXCALIBUR.md) for
what that name means now — the admin/designer's own drive, not this one).
Nothing about the build process below changed in the rename, only the name.

This is the actual, twice-verified process - built and confirmed working
on real hardware (Greg's original drive, then a full clean rebuild that
needed zero manual fixes). Two paths below: the normal one (Deploy
Console, no typing) and the fallback (manual commands, for when you're
away from home base with nothing but a terminal).

## Path A - Deploy Console (the normal way)

1. Right-click `Launch-Deploy-Console.cmd` (in
   `Advanced\deploy-console\` inside your `north-forge-hermes-edition`
   checkout) -> **Run as administrator**.
2. A browser tab opens with the deploy form.
3. Pick the target drive.
4. Fill in:
   - **Volume label** - the field that got added tonight specifically so
     you never have to bypass the console again. Use the naming
     convention: `<FirstName><LastInitial>-NORTH` (e.g. `GREGW-NORTH`
     for Greg Warhol).
   - **Tier**: `basic` (this is what "locked to Kyocera" actually means
     under the hood - a Round Table build is always basic-tier).
   - **Pin**: `kyocera`.
   - **Passcode**: your admin passcode (one field in the actual console
     UI, not two - checked against the real form).
5. Confirm format. Wait - full deploy takes a few minutes (clone, venv
   bootstrap, provisioning). You'll see "DEPLOYMENT COMPLETE" when done.
   Since 2026-09-14, a drive under 8 GB is refused before formatting even
   starts, rather than failing partway through the clone once it's already
   wiped - if you see that refusal, the target is too small; use 32 GB+.
6. **Pinokio is now excluded automatically** - you don't need to check
   for or remove it by hand anymore. That used to be a manual step;
   it's fixed at the source now.

## Path B - Manual commands (the "I'm stuck without the console" fallback)

Same result, just typed directly. This is what you'd do from any machine
with git, PowerShell, and your GitHub access - no console needed. This is
the **one** command - it does the format, both clones, the bootstrap, and
the provisioning itself. Do not manually `git clone` or run
`bootstrap-north-forge.ps1` yourself first: the format step below would
just wipe that work, and the script re-clones and re-bootstraps on its
own anyway - a separate manual pass first is wasted effort, not a
safer or more thorough version of this step.

```powershell
# From anywhere with git, PowerShell, and your GitHub access.
# Get this script onto the machine first (e.g. clone north-forge-hermes-edition,
# or copy Advanced\deploy-console\Zero-Touch-Deploy.ps1 over) - then run it
# directly against the target drive letter (e.g. E:):
Zero-Touch-Deploy.ps1 -DriveLetter E -ConfirmFormat FORMAT -Tier basic -Pin kyocera -Passcode <your-passcode> -Label GREGW-NORTH
```

Exit code `0` and a "DEPLOYMENT COMPLETE" message means it worked. Pinokio
exclusion happens automatically here too - no `-ExcludeSkills` flag
needed, it's the default now for `-Tier basic`.

## Step 3 (either path) - Configure the AI model

This step only applies to a **Round Table** build specifically (`-Tier
basic` — real technicians need real model quality). A `-Tier full` build
(what's now called an **Excalibur** build - your own admin/designer drive)
typically skips this and uses the free Nous Portal tier instead - no key
needed unless you specifically want one configured there too.

```powershell
hermes config set ANTHROPIC_API_KEY <your real key>
hermes config set model anthropic/claude-sonnet-5
```

Verify it stuck: `hermes config show` - should show the model name and a
masked version of the key.

## Step 4 - First real launch

Double-click **Start North Forge.lnk** at the drive root. This:
- Runs a self-check (`nf-preflight`) - should show all-PASS.
- Creates **How To Start.lnk** at the drive root, pointing at the
  onboarding page - this only appears after the first real launch, not
  right after deploy, so don't worry if you don't see it immediately
  after building.
- Drops you into a real chat session.

## Step 5 - Prove it actually works

Ask it something real. Two examples, both actually run against a real
build and confirmed to produce good, in-voice responses - not just
plausible-sounding, actually checked:

> "A customer's TASKalfa keeps disconnecting from wifi every few hours.
> What should I check?"

> "TASKalfa 5054ci throwing a C6000 code after the last firmware
> update"

The second one is a good gut-check example specifically because the real
response declined to guess: it said the C6000/fuser association it found
was for a different model family, refused to hand over a mismatched fix,
and asked for the exact sub-code before going further. That refusal-to-
guess is the actual proof it's working right, not a shortcoming.

You're looking for: it asks for specifics before diagnosing, gives a
structured answer (what to check, what to collect, what it's not
claiming), and never sounds like a generic chatbot.

## Step 6 - Confirm Pinokio really isn't there

Type `hermes skills list` (or just try `/pinokio` in chat - it should
not exist as a command). You should see exactly the Kyocera skill set,
nothing extra.

## That's the whole thing

Format → clone → bootstrap → deploy → configure the model (Round Table
only) → launch → verify. Every step above is exactly what happened on
the real, twice-confirmed drive - nothing here is theoretical.
