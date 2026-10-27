# Windows security & stability checklist

Used for remote Windows checks. Every item ends with the real output saved in the report.

## Before starting

- [ ] Written authorization from the device owner (scope, date, remote tool)
- [ ] Owner present during the remote session
- [ ] Never ask for or store passwords
- [ ] Agree on what will be changed, if anything, before changing it

## Security baseline

- [ ] Microsoft Defender: antivirus, real-time protection and behavior monitoring enabled (`Get-MpComputerStatus`)
- [ ] Defender signatures updated in the last 24 to 48 hours
- [ ] Quick scan run; full scan scheduled if anything looks suspicious
- [ ] Windows Firewall enabled on Domain, Private and Public profiles (`Get-NetFirewallProfile`)
- [ ] Windows Update: no pending critical updates
- [ ] User account is a standard user for daily use, or the owner knows the risk of daily admin use
- [ ] Unknown startup apps and browser extensions reviewed with the owner
- [ ] Remote access tools not in use are removed or disabled at the end of the session

## Integrity and stability

- [ ] `sfc /scannow` run and final message recorded
- [ ] `DISM /Online /Cleanup-Image /RestoreHealth` run if SFC could not fix everything
- [ ] Disk health (`Get-PhysicalDisk`) and reliability counters recorded
- [ ] Manufacturer disk diagnostic run if any counter looks wrong
- [ ] Event Viewer: Kernel-Power 41, EventLog 6008, BugCheck 1001 and WHEA events counted for the last 30 days
- [ ] Reliability Monitor reviewed around each crash or shutdown
- [ ] Temperatures checked under load if shutdowns are physical

## Closing

- [ ] Report delivered: what was checked, what was found, what is still open, next steps
- [ ] Nothing in the report identifies the person or the device
