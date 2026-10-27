<#
.SYNOPSIS
    Read-only Windows 11 security and stability snapshot. Saves a Markdown report.

.DESCRIPTION
    Collects Microsoft Defender status, Windows Firewall profiles, physical disk health,
    disk reliability counters and the last 30 days of unexpected shutdown and crash events.
    The script does not change any setting on the computer.

    It does not record the computer name, user name or IP addresses.

.PARAMETER OutFile
    Where to save the report. Default: windows-health-report.md on the current user's Desktop.

.EXAMPLE
    # In PowerShell opened as Administrator:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    .\windows-health-check.ps1

.NOTES
    Author: Gabriel Barbosa
    Run as Administrator for complete results (disk reliability counters need it).
#>

param(
    [string]$OutFile = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'windows-health-report.md')
)

$lines = New-Object System.Collections.Generic.List[string]

$lines.Add('# Windows health snapshot')
$lines.Add('')
$lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")

# --- Operating system ---------------------------------------------------------
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$lines.Add("OS: $($os.Caption) (version $($os.Version), build $($os.BuildNumber))")
$lines.Add("Last boot: $($os.LastBootUpTime)")

# --- Microsoft Defender -------------------------------------------------------
$lines.Add('')
$lines.Add('## Microsoft Defender')
try {
    $mp = Get-MpComputerStatus -ErrorAction Stop
    $lines.Add('| Check | Value |')
    $lines.Add('|---|---|')
    $checks = 'AntivirusEnabled', 'RealTimeProtectionEnabled', 'BehaviorMonitorEnabled',
              'IoavProtectionEnabled', 'AntivirusSignatureLastUpdated', 'QuickScanAge', 'FullScanAge'
    foreach ($name in $checks) {
        $lines.Add("| $name | $($mp.$name) |")
    }
}
catch {
    $lines.Add("Could not read Defender status: $($_.Exception.Message)")
}

# --- Windows Firewall ---------------------------------------------------------
$lines.Add('')
$lines.Add('## Windows Firewall')
try {
    $lines.Add('| Profile | Enabled | Default inbound action |')
    $lines.Add('|---|---|---|')
    Get-NetFirewallProfile -ErrorAction Stop | ForEach-Object {
        $lines.Add("| $($_.Name) | $($_.Enabled) | $($_.DefaultInboundAction) |")
    }
}
catch {
    $lines.Add("Could not read firewall profiles: $($_.Exception.Message)")
}

# --- Physical disks -----------------------------------------------------------
$lines.Add('')
$lines.Add('## Physical disks')
$disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)
$lines.Add('| Disk | Media type | Health | Operational status |')
$lines.Add('|---|---|---|---|')
foreach ($d in $disks) {
    $lines.Add("| $($d.FriendlyName) | $($d.MediaType) | $($d.HealthStatus) | $($d.OperationalStatus) |")
}

$lines.Add('')
$lines.Add('### Disk reliability counters')
$lines.Add('| Disk | Temperature (C) | Read errors (total) | Wear (%) | Power-on hours |')
$lines.Add('|---|---|---|---|---|')
foreach ($d in $disks) {
    try {
        $c = $d | Get-StorageReliabilityCounter -ErrorAction Stop
        $lines.Add("| $($d.FriendlyName) | $($c.Temperature) | $($c.ReadErrorsTotal) | $($c.Wear) | $($c.PowerOnHours) |")
    }
    catch {
        $lines.Add("| $($d.FriendlyName) | not available | - | - | - |")
    }
}
$lines.Add('')
$lines.Add('_These counters are not a full SMART test. Use the drive manufacturer''s diagnostic tool for a complete check._')

# --- Unexpected shutdowns and crashes (last 30 days) --------------------------
$since = (Get-Date).AddDays(-30)
$lines.Add('')
$lines.Add('## Unexpected shutdowns and crashes (last 30 days)')
$lines.Add('| Event | Count | Most recent |')
$lines.Add('|---|---|---|')

$eventChecks = @(
    @{ Label = 'Kernel-Power 41 (lost power or hard reset)';
       Filter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 41; StartTime = $since } },
    @{ Label = 'EventLog 6008 (previous shutdown was unexpected)';
       Filter = @{ LogName = 'System'; ProviderName = 'EventLog'; Id = 6008; StartTime = $since } },
    @{ Label = 'BugCheck 1001 (blue screen)';
       Filter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting'; Id = 1001; StartTime = $since } },
    @{ Label = 'WHEA-Logger (hardware errors)';
       Filter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-WHEA-Logger'; StartTime = $since } },
    @{ Label = 'Disk errors (disk / stornvme)';
       Filter = @{ LogName = 'System'; ProviderName = 'disk', 'stornvme'; Level = 2, 3; StartTime = $since } }
)

foreach ($check in $eventChecks) {
    $found = @(Get-WinEvent -FilterHashtable $check.Filter -ErrorAction SilentlyContinue)
    $mostRecent = if ($found.Count -gt 0) { $found[0].TimeCreated } else { '-' }
    $lines.Add("| $($check.Label) | $($found.Count) | $mostRecent |")
}

# --- Manual steps ---------------------------------------------------------------
$lines.Add('')
$lines.Add('## Manual steps to complete')
$lines.Add('- [ ] Run `sfc /scannow` as Administrator and paste the final message here:')
$lines.Add('- [ ] If SFC found errors it could not fix, run `DISM /Online /Cleanup-Image /RestoreHealth` and record the result.')
$lines.Add('- [ ] Open Reliability Monitor (`perfmon /rel`) and note critical events around each shutdown.')

# --- Save -----------------------------------------------------------------------
$lines | Out-File -FilePath $OutFile -Encoding utf8
Write-Host "Report saved to $OutFile"
