# Usage Guide - Backup System (en-US)

## 🚀 Quick Start

### 1️⃣ Configure Repositories

Edit `scripts/config.json` and set your repository paths:

```json
{
  "repositories": [
    {
      "name": "repo1",
      "source": "\\192.168.1.100\project1",
      "description": "Main project",
      "enabled": true
    },
    {
      "name": "repo2",
      "source": "\\192.168.1.100\project2",
      "description": "Second project",
      "enabled": true
    },
    {
      "name": "repo3",
      "source": "\\192.168.1.100\project3",
      "description": "Third project",
      "enabled": true
    }
  ]
}
```

### 2️⃣ Run Manual Backup

```powershell
# Go to the scripts folder
cd D:\scripts

# Run backup
.\backup.ps1
```

### 3️⃣ List Backups

```powershell
# List all backups for a repository
.\restore.ps1 -RepoName "repo1" -ListBackups
```

### 4️⃣ Restore Backup

```powershell
# Restore the latest backup
.\restore.ps1 -RepoName "repo1" -DestinationPath "C:\Restored"

# Restore a specific backup
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip" -DestinationPath "C:\Restored"

# Verify integrity before restoring
.\restore.ps1 -RepoName "repo1" -VerifyChecksum
```

## 📋 Useful Commands

### Backup

```powershell
# Standard backup
.\backup.ps1

# Verbose output
.\backup.ps1 -Verbose

# Force backup (ignore checks)
.\backup.ps1 -Force
```

### Restore

```powershell
# List available backups
.\restore.ps1 -RepoName "repo1" -ListBackups

# Restore latest
.\restore.ps1 -RepoName "repo1"

# Restore specific
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip"

# Verify checksum
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip" -VerifyChecksum

# Overwrite existing destination
.\restore.ps1 -RepoName "repo1" -DestinationPath "C:\Exists" -Force
```

## 🤖 Automation

### Schedule Daily Backup (Task Scheduler)

1. Open **Task Scheduler** in Windows
2. Click **Create Basic Task**
3. Name: `Daily Automatic Backup`
4. Trigger: **Daily** at 02:00
5. Action: **Start a program**
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "D:\scripts\backup.ps1"`
6. Finish

### Schedule via PowerShell

```powershell
# Create scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\scripts\backup.ps1'"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName "BackupAutomatic" -Action $action -Trigger $trigger -Description "Daily automatic backup"
```

## 📊 Check Logs

```powershell
# View today's log
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log"

# View last 20 lines
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log" -Tail 20

# View logs in real time
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log" -Wait
```

## ⚙️ Advanced Settings

### config.json - Options

```json
{
  "settings": {
    "compression": "Optimal",        // Compression type: Optimal, Fastest, NoCompression
    "keepBackups": 5,                // Number of backups to keep
    "createChecksum": true,          // Create SHA256 checksum
    "logLevel": "Info",              // Log level (Info, Warning, Error)
    "apiUrl": "http://192.168.1.100:9101/upload",  // Optional: Remote FastAPI endpoint
    "apiToken": "your-secure-token"  // Optional: Bearer token for API
  }
}
```

**Note:** If `apiUrl` and `apiToken` are configured, backups will be automatically uploaded to the remote server after creation.

## 🌐 Network Access

### Map Network Drive (Optional)

```powershell
# Map drive Z:
net use Z: \\server\share /user:DOMAIN\user password

# Use in config.json
"source": "Z:\\project-folder"
```

### Use UNC Path Directly

```json
"source": "\\\\server\\share\\folder"
```

### Network Credentials

If you need credentials:

```powershell
# Save credentials
cmdkey /add:server /user:DOMAIN\user /pass:password

# List saved credentials
cmdkey /list
```

## ❓ Troubleshooting

### Error: "Source path not found"

**Solution:**
- Check if the path is correct in `config.json`
- Test manual access: `Test-Path "\\server\share"`
- Check network credentials

### Error: "Access Denied"

**Solution:**
- Run PowerShell as Administrator
- Check destination folder permissions
- Check network credentials

### Backup too large

**Solution:**
- Add exclusions in the local `.gitignore`
- Use maximum compression
- Consider incremental backup

### Script does not run

**Solution:**
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📈 Best Practices

1. ✅ Run daily backups automatically
2. ✅ Keep at least 5 backup versions
3. ✅ Check logs regularly
4. ✅ Test restore periodically
5. ✅ Use checksum to verify integrity
6. ✅ Store backups in a different location (cloud/other server)
7. ✅ Document changes in `config.json`

## 🔒 Security

- Do not commit passwords to Git
- Use Windows Credential Manager
- Restrict access to the backup folder
- Consider encrypting sensitive backups
