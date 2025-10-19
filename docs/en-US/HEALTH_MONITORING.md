# Disk Health Monitoring

This guide explains how to monitor the health of the disk (HD) where backups are stored.

## What is checked

- Free space (%) and in GB
- SMART status (if available)
- Recent disk events (IDs: 7, 11, 15, 51, 55, 129, 153)
- Performance metrics: Avg. Disk Queue Length and % Disk Time (if available)

## Scripts

- `scripts/health-check.ps1`: runs a check and saves a JSON snapshot to `D:\status\health-status.json`
- `scripts/monitor-health.ps1`: runs in a loop and logs periodically to `D:\logs\health_monitor.log`

## Quick Usage

```powershell
# Single check and show result
cd D:\scripts
./health-check.ps1 -DriveLetter D -OutJson 'D:\status\health-status.json'

# Monitor continuously (every 5 min)
./monitor-health.ps1 -DriveLetter D -IntervalSeconds 300
```

## Integrating with the API

The server exposes the endpoint:

```http
GET /api/health
```

- Returns the JSON from `D:\status\health-status.json`
- If the file does not exist, tries to generate a quick check

Example (PowerShell):
```powershell
Invoke-RestMethod -Uri 'http://localhost:8080/api/health' -Method GET
```

## Schedule in Windows (Task Scheduler)

```powershell
# Run health-check every hour
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File 'D:\scripts\health-check.ps1'"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 60) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName 'Backup_HealthCheck_Hourly' -Action $action -Trigger $trigger -RunLevel Highest

# Run the continuous monitor at logon (optional)
$action2 = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File 'D:\scripts\monitor-health.ps1'"
$trigger2 = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'Backup_HealthMonitor_OnLogon' -Action $action2 -Trigger $trigger2 -RunLevel Highest
```

## Alerts and Warning Signs

- Free space < 15% (adjust threshold if needed)
- SMART: `PredictFailure = true`
- Recurring disk events (IDs above)
- Disk queue too high for long periods

## Tips and Recommendations

- Run monitoring outside critical hours (reduces load)
- Review the `D:\logs\health_monitor.log` weekly
- Consider alerting by email or Teams/Slack (next step)
- Keep storage firmware/driver up to date
- Clean up old backups (already automated by the system)

## Next Steps (Optional)

- Send alerts by email (SMTP) when `health != OK`
- Send metrics to an external system (Prometheus/Telegraf)
- Implement `/api/alerts` endpoint with history
