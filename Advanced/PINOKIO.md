# Pinokio — later, optional, not the manager stick

[Pinokio](https://github.com/pinokiocomputer/pinokio) is a one-click
launcher for local open-source apps. Home folder is isolated.
The installer is ~100 MB. **The apps are not.** A serious local zoo is
100 GB minimum. A few terabytes only if you keep many large models.

## AppData vs a big drive

| Choice | Verdict |
|---|---|
| Default AppData / profile | Fine for a trial. Easy to discard. Fills the system disk. Do not park models here. |
| `PINOKIO_HOME` on a data SSD (500 GB–2 TB) | The real design. Discard = delete that folder. |
| Same 32 GB Excalibur stick as North Forge | No. |
| Few-terabyte drive | Plausible as a lab / Pine Barron disk, not the support handoff. |

Pinokio can sit *beside* North Forge on a large admin disk. Do not merge
it into the teammate path for the first viewer.

## If you want it on a lab disk

`Advanced/deploy-console/Install-Pinokio-Lab.ps1` checks a candidate folder
against both rules above before touching anything: it refuses any drive that
looks like a North Forge volume, and refuses anything under 200 GB free
(500 GB+ is the "real design" line above). If Pinokio is already installed,
it can point Pinokio's own `config.json` Home field at the validated target
(after backing the file up); if Pinokio isn't installed yet, it just prints
the target path to paste into Pinokio's first-run Home prompt. Nothing here
is wired into any teammate-path script.

`Remove-Pinokio-Lab.ps1` in the same folder reverses it: runs Pinokio's own
uninstaller if found, clears the AppData/program folders, and only deletes
the Home data folder if you pass `-RemoveHomeData` and confirm.
