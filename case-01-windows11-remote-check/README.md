# Case 01 — Windows 11: remote security and integrity check

**Type:** Remote technical support, troubleshooting and basic security check
**Context:** Unpaid job for a personal contact. Device and owner details removed.
**System:** Windows 11, freshly installed on a computer previously running Linux
**Access:** Remote session with AnyDesk, with the owner present
**Status:** Security baseline confirmed; stability still being monitored

## The problem

After installing Windows 11 on a machine that previously ran Linux, the owner reported:

- Boots landing in Windows Automatic Repair
- Repair failure pointing to `System32\Logfiles\Srt\SrtTrail.txt`
- Some boots reaching the desktop normally
- New shutdowns after installing apps and customizing the system

Initial hypotheses: corrupted system files, boot configuration issues, SSD/HDD failure, or hardware, temperature or power problems. None of these was confirmed during the session.

## What I checked

| Area | Command | Purpose | Result |
|---|---|---|---|
| Microsoft Defender | `Get-MpComputerStatus` | Antivirus, real-time protection and behavior monitoring state | All three enabled as expected |
| Windows Firewall | `Get-NetFirewallProfile` | Firewall state on Domain, Private and Public profiles | Enabled on all profiles |
| System files | `sfc /scannow` | Integrity of protected Windows files | Ran; final output not recorded |
| Storage | `Get-PhysicalDisk` | Disks detected and `HealthStatus` | Reported healthy (basic check only) |
| Crash history | `perfmon /rel` | Reliability Monitor for app failures and critical events | Opened for review; no conclusive finding recorded |

## Assessment

- Windows' built-in protections were active, and the basic storage query showed no obvious fault.
- The history of automatic repair and unexpected shutdowns means the system cannot be called stable yet.
- Antivirus and firewall being on does not, by itself, prove the machine is free of malware.
- **The cause of the shutdowns and earlier boot failures is still undetermined.** This report does not claim the problem was solved.

## Next steps recommended

If the symptoms come back:

1. Review Reliability Monitor (`perfmon /rel`) around the time of each shutdown.
2. Check Event Viewer (`eventvwr.msc`) for Kernel-Power 41, BugCheck 1001 and WHEA hardware errors.
3. Run `sfc /scannow` again and record the final message.
4. Run `DISM /Online /Cleanup-Image /RestoreHealth` in an elevated terminal if image corruption is suspected.
5. Read the drive's SMART attributes and run the manufacturer's diagnostic.
6. Check temperatures, RAM and power supply if the shutdowns are physical.
7. If needed, reinstall Windows from trusted installation media.

## What I improved after this job

The two gaps in this case were results that were not recorded (SFC) and crash history that was not exported. To close them, I wrote [`windows-health-check.ps1`](scripts/windows-health-check.ps1): a read-only script that saves Defender, Firewall, disk and crash-event data into one Markdown report, so every future check ends with evidence.

## Tools

Windows 11 · PowerShell · Command Prompt · Microsoft Defender Antivirus · Windows Defender Firewall · System File Checker · Reliability Monitor · AnyDesk

## Security practices followed

- Antivirus and firewall were never disabled.
- No destructive command was run.
- No passwords, public IPs or personal identifiers are stored in this report.
- Results are reported as observed, including what was not verified.

[Versão original em português](README.pt-BR.md)
