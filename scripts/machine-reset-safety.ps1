[CmdletBinding()]
param(
    [ValidateSet('Validate', 'Purge', 'RemoveEnv')]
    [string]$Action = 'Validate',
    [string]$Candidate,
    [string]$ExpectedCanonical
)

$ErrorActionPreference = 'Stop'

function Stop-Validation([string]$Message) {
    [Console]::Error.WriteLine("Safety check failed: $Message")
    exit 2
}

function Get-CanonicalHermesHome([string]$InputPath) {
    if ([string]::IsNullOrWhiteSpace($InputPath)) {
        Stop-Validation 'HERMES_HOME and LOCALAPPDATA are both empty.'
    }

    # Check the operator's original spelling. Resolving first would hide traversal.
    if ($InputPath -split '[\\/]' -contains '..') {
        Stop-Validation "the path contains a literal '..' segment."
    }
    if ($InputPath -match '^[\\/]{2}' -or $InputPath -match '^\\\\[?.]\\') {
        Stop-Validation 'UNC and device paths are not allowed.'
    }
    if ($InputPath -notmatch '^[A-Za-z]:[\\/]') {
        Stop-Validation 'use an absolute local path such as C:\Hermes (not a relative or drive-relative path).'
    }

    try { $canonical = [System.IO.Path]::GetFullPath($InputPath) }
    catch { Stop-Validation "the path could not be resolved: $($_.Exception.Message)" }
    $root = [System.IO.Path]::GetPathRoot($canonical)
    if ($canonical.TrimEnd('\', '/') -ieq $root.TrimEnd('\', '/')) {
        Stop-Validation 'a drive root can never be a Hermes home.'
    }

    $protected = @(
        $env:SystemDrive, $env:SystemRoot, $env:windir, $env:USERPROFILE,
        $env:LOCALAPPDATA, $env:APPDATA, $env:ProgramData, $env:PUBLIC,
        $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramW6432,
        $(if ($env:SystemDrive) { Join-Path $env:SystemDrive 'Users' }),
        $(if ($env:SystemDrive) { Join-Path $env:SystemDrive 'Documents and Settings' }),
        $(if ($env:HOMEDRIVE -and $env:HOMEPATH) { "$($env:HOMEDRIVE)$($env:HOMEPATH)" })
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
        try { [System.IO.Path]::GetFullPath($_).TrimEnd('\', '/') } catch { $_.TrimEnd('\', '/') }
    }
    if ($protected -icontains $canonical.TrimEnd('\', '/')) {
        Stop-Validation 'the target is a Windows system, program, or user-profile root.'
    }

    if (-not (Test-Path -LiteralPath $canonical -PathType Container)) {
        Stop-Validation 'the target directory does not exist.'
    }

    # Walk from the drive root to the target so a link cannot hide in a parent.
    $relative = $canonical.Substring($root.Length).Trim('\', '/')
    $current = $root
    $rootItem = Get-Item -LiteralPath $current -Force
    if (($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        $rootItem.LinkType -in @('SymbolicLink', 'Junction')) {
        Stop-Validation "drive root '$current' is a symbolic link or junction."
    }
    foreach ($part in ($relative -split '[\\/]' | Where-Object { $_ })) {
        $current = Join-Path $current $part
        $item = Get-Item -LiteralPath $current -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            $item.LinkType -in @('SymbolicLink', 'Junction')) {
            Stop-Validation "'$current' is, or passes through, a symbolic link or junction."
        }
    }

    $config = Join-Path $canonical 'config.yaml'
    $agent = Join-Path $canonical 'hermes-agent'
    if (-not (Test-Path -LiteralPath $config -PathType Leaf) -or
        -not (Test-Path -LiteralPath $agent -PathType Container)) {
        Stop-Validation "both the config.yaml file and hermes-agent directory are required."
    }
    foreach ($marker in @($config, $agent)) {
        $item = Get-Item -LiteralPath $marker -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            $item.LinkType -in @('SymbolicLink', 'Junction')) {
            Stop-Validation "required marker '$marker' is a symbolic link or junction."
        }
    }
    return $canonical.TrimEnd('\', '/')
}

if (-not $PSBoundParameters.ContainsKey('Candidate')) {
    $Candidate = if ($Action -ne 'Validate' -and $env:VALIDATED_HERMES_HOME) {
        $env:VALIDATED_HERMES_HOME
    } elseif ($env:HERMES_HOME) {
        $env:HERMES_HOME
    } else {
        Join-Path $env:LOCALAPPDATA 'hermes'
    }
}
$validated = Get-CanonicalHermesHome $Candidate

if ($Action -eq 'Validate') {
    [Console]::Out.WriteLine($validated)
    exit 0
}
if (-not $PSBoundParameters.ContainsKey('ExpectedCanonical')) { $ExpectedCanonical = $env:VALIDATED_HERMES_HOME }
if ([string]::IsNullOrWhiteSpace($ExpectedCanonical) -or $validated -cne $ExpectedCanonical) {
    Stop-Validation 'the freshly validated path does not exactly match the confirmed canonical path.'
}

if ($Action -eq 'Purge') {
    Remove-Item -LiteralPath $validated -Recurse -Force
    if (Test-Path -LiteralPath $validated) { throw "Partial deletion: '$validated' still exists." }
} else {
    $envFile = Join-Path $validated '.env'
    if (Test-Path -LiteralPath $envFile -PathType Leaf) { Remove-Item -LiteralPath $envFile -Force }
    if (Test-Path -LiteralPath $envFile) { throw "Partial deletion: '$envFile' still exists." }
}
exit 0
