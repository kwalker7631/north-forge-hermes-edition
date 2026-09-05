from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_both_launchers_force_the_drive_local_home():
    shell = (ROOT / "launch-north-forge.sh").read_text(encoding="utf-8")
    batch = (ROOT / "launch-north-forge.bat").read_text(encoding="utf-8")
    assert "ensure_drive_hermes \"$PWD\"" in shell
    assert 'set "HERMES_HOME=%CD%\\.hermes-home"' in batch
    assert 'scripts\\ensure-hermes.ps1' in batch
    assert "where hermes" not in batch


def test_windows_guard_has_three_states_staging_and_diagnostics():
    guard = (ROOT / "scripts/ensure-hermes.ps1").read_text(encoding="utf-8")
    for required in (
        "Test-HermesHome $homeDir",       # valid
        "partial or damaged .hermes-home",  # partial/corrupt
        "This drive will receive its own independent Hermes engine",  # absent
        ".hermes-install-staging",
        ".hermes-install-incomplete",
        "AvailableFreeSpace",
        "$LASTEXITCODE",
        "Diagnostic log:",
        "Shared Hermes setup on this computer was not touched",
    ):
        assert required in guard
