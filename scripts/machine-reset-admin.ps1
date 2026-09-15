# machine-reset-admin - host-level admin passcode for machine-reset.bat's admin
# gate. Replaces the old hardcoded 'RumpleStiltskin' literal-string comparison
# (CHG: retire compromised passcodes) with a real, rotatable, PBKDF2-hashed
# credential — same shape as hermes_cli.nf_tier's drive-scoped .nf-admin, but
# deliberately a SEPARATE, host-level file: machine-reset.bat explicitly never
# uses HERMES_HOME (host maintenance must never accidentally target a drive), so
# its admin gate must not depend on any drive's own admin passcode either.
<#
  scripts\machine-reset-admin.ps1 -Action Test   [-Passcode <text>] [-StorePath <path>]
  scripts\machine-reset-admin.ps1 -Action Set     -Passcode <text>  [-StorePath <path>]
  scripts\machine-reset-admin.ps1 -Action Rotate  -Passcode <text>  [-StorePath <path>]

  -Action Test    Exit 0 if -Passcode (or stdin, if -Passcode omitted) matches
                  the stored hash. FAILS CLOSED (exit 1) when no passcode is
                  configured yet — never silently permits everyone just
                  because nothing has been set. Never prints the passcode.
  -Action Set     Establish the passcode for the first time. Refuses (exit 1)
                  if one already exists — use -Action Rotate to change it.
  -Action Rotate  Change an existing passcode (or establish one if none exists).

  -StorePath defaults to "$env:LOCALAPPDATA\hermes\.machine-reset-admin.json" —
  host-level, independent of any drive's own north-forge/.nf-admin.

  This script only builds/tests the MECHANISM. It never chooses a passcode
  value on its own — Kenneth runs -Action Set/Rotate himself with the real
  value, the same way a Claude Code session must not set or ask for one.

  PowerShell 5.1 compatible (no [Convert]::FromHexString, added in .NET 5).
#>
[CmdletBinding()]
param(
    [ValidateSet('Test', 'Set', 'Rotate')]
    [string]$Action = 'Test',
    [string]$Passcode,
    [string]$StorePath
)

$ErrorActionPreference = 'Stop'

if (-not $StorePath) { $StorePath = Join-Path $env:LOCALAPPDATA 'hermes\.machine-reset-admin.json' }
$Iterations = 210000

function ConvertTo-HexStringLocal([byte[]]$Bytes) {
    -join ($Bytes | ForEach-Object { $_.ToString('x2') })
}

function ConvertFrom-HexStringLocal([string]$Hex) {
    $bytes = New-Object byte[] ($Hex.Length / 2)
    for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($Hex.Substring($i * 2, 2), 16) }
    return , $bytes
}

function Get-Pbkdf2HashLocal([string]$Text, [byte[]]$Salt, [int]$Iters) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($bytes, $Salt, $Iters, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
    try { return , $derive.GetBytes(32) } finally { $derive.Dispose() }
}

function Test-BytesEqualConstantTime([byte[]]$A, [byte[]]$B) {
    # Fixed-length compare over the max of both lengths so an early length
    # mismatch doesn't short-circuit the loop and leak timing either.
    $len = [Math]::Max($A.Length, $B.Length)
    $diff = $A.Length -bxor $B.Length
    for ($i = 0; $i -lt $len; $i++) {
        $ab = if ($i -lt $A.Length) { $A[$i] } else { 0 }
        $bb = if ($i -lt $B.Length) { $B[$i] } else { 0 }
        $diff = $diff -bor ($ab -bxor $bb)
    }
    return $diff -eq 0
}

switch ($Action) {
    'Test' {
        if (-not (Test-Path -LiteralPath $StorePath -PathType Leaf)) {
            # No admin passcode configured — fail CLOSED. This is the state
            # right after retiring a compromised passcode and before Kenneth
            # sets a real replacement: refuse everyone, never fall back to
            # "nothing set yet, so let it through" (that leniency belongs to a
            # brand-new drive's first-ever setup, not a revoked credential).
            exit 1
        }
        if (-not $PSBoundParameters.ContainsKey('Passcode')) {
            $Passcode = [Console]::In.ReadLine()
        }
        try {
            $data = Get-Content -LiteralPath $StorePath -Raw | ConvertFrom-Json
            $salt = ConvertFrom-HexStringLocal $data.salt
            $want = ConvertFrom-HexStringLocal $data.hash
            $iters = [int]$data.iterations
        } catch {
            exit 1
        }
        $got = Get-Pbkdf2HashLocal -Text ($Passcode -as [string]) -Salt $salt -Iters $iters
        if (Test-BytesEqualConstantTime $got $want) { exit 0 } else { exit 1 }
    }
    { $_ -in 'Set', 'Rotate' } {
        if (-not $Passcode -or $Passcode.Length -lt 6) {
            [Console]::Error.WriteLine('Passcode must be at least 6 characters.')
            exit 1
        }
        $exists = Test-Path -LiteralPath $StorePath -PathType Leaf
        if ($exists -and $Action -eq 'Set') {
            [Console]::Error.WriteLine("$StorePath already exists - use -Action Rotate to change it.")
            exit 1
        }
        $salt = New-Object byte[] 16
        [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($salt)
        $hash = Get-Pbkdf2HashLocal -Text $Passcode -Salt $salt -Iters $Iterations
        $dir = Split-Path -Parent $StorePath
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        @{
            salt         = (ConvertTo-HexStringLocal $salt)
            hash         = (ConvertTo-HexStringLocal $hash)
            iterations   = $Iterations
            created_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        } | ConvertTo-Json | Set-Content -LiteralPath $StorePath -Encoding utf8
        Write-Output "admin passcode $(if ($Action -eq 'Rotate') { 'rotated' } else { 'set' }) at $StorePath"
        exit 0
    }
}
