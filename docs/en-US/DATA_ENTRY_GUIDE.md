# Data Entry Guide (Repositories)

This guide shows how to register and validate repositories for backup, safely and efficiently, using two methods:

- Direct configuration in `scripts/config.json`
- Via API (recommended for network/HD environments)

---

## 1) Prerequisites and Best Practices

- Use the correct network (UNC) path: \\server\share\folder
- Ensure read permissions on the source path
- Avoid mapped drives (Z:\) when running as another account
- Test connectivity and credentials before registering

### Quick Tests

```powershell
# Does the path exist?
Test-Path "\\server\share\repo1"

# List contents (first items)
Get-ChildItem "\\server\share\repo1" -Force | Select-Object -First 5

# Save credentials in Windows Credential Manager (if needed)
cmdkey /add:server /user:DOMAIN\user /pass:password
cmdkey /list
```

---

## 2) Register via file (config.json)

File: `D:\scripts\config.json`

Main fields:
- `name`: short identifier, no spaces (e.g., `web-project`)
- `source`: UNC source path
- `description`: short description
- `enabled`: temporarily enable/disable the repo

Example config with 3 repositories:

```json
{
  "repositories": [
    {
      "name": "web-project",
      "source": "\\192.168.1.10\projects\web",
      "description": "Main web application",
      "enabled": true
    },
    {
      "name": "reports",
      "source": "\\fileserver\department\reports",
      "description": "Spreadsheets and reports",
      "enabled": true
    },
    {
      "name": "db-dumps",
      "source": "\\dbserver\exports\dumps",
      "description": "Database dumps",
      "enabled": true
    }
  ],
  "settings": {
    "compression": "zip",
    "keepBackups": 5,
    "createChecksum": true,
    "logLevel": "Info"
  }
}
```

Validate after editing:
```powershell
# Validate JSON
Get-Content D:\scripts\config.json -Raw | ConvertFrom-Json | Out-Null; if ($?) { "OK" } else { "Error" }

# Test declared paths
($cfg = Get-Content D:\scripts\config.json -Raw | ConvertFrom-Json).repositories | ForEach-Object {
  $ok = Test-Path $_.source
  "[$($ok ? 'OK' : 'ERROR')] $($_.name) => $($_.source)"
}
```

---

## 3) Register via API (Recommended)

Advantages: no manual file editing, easier validation, integrates with other systems.

1. Start the API server:
```powershell
cd D:\scripts
./api-server.ps1
```

2. Use the CLI client to add a repository:
```powershell
./api-client.ps1 add
# You will be prompted: name, UNC path, and description
```

3. List registered repositories:
```powershell
./api-client.ps1 repos
```

4. Optional: direct call (no CLI), with cURL or PowerShell

PowerShell:
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/repositories" -Method POST -ContentType "application/json" -Body (@{
  name = "web-project"
  source = "\\192.168.1.10\projects\web"
  description = "Main web application"
  enabled = $true
} | ConvertTo-Json)
```

cURL:
```bash
curl -X POST http://localhost:8080/api/repositories \
  -H "Content-Type: application/json" \
  -d '{"name":"web-project","source":"\\\\192.168.1.10\\projects\\web","description":"Main web application","enabled":true}'
```

---

## 4) Validation Checklist

- [ ] `Test-Path` returns True
- [ ] Data size fits available backup disk
- [ ] Read permissions confirmed
- [ ] Name has no spaces or special characters
- [ ] `enabled` field = true
- [ ] Valid JSON config

---

## 5) Performance Tips (HD)

- Prefer backups outside business hours
- Avoid multiple simultaneous backups on the same disk
- Enable checksums (useful for integrity, low cost)
- Consider exclusions (temporary logs) via separate subfolders
- Prefer UNC paths over mapped drives

---

## 5.1) Topology: 2 repositories on another server and 1 on a VM

When sources are distributed between servers and VMs, pay attention to:

- Different credentials per host (use `cmdkey` for each host: `fileserver`, `dbserver`, `vmapp01`)
- Firewall allowing SMB (port 445/TCP) between machines
- Name resolution (DNS); if it fails, use IP in UNC path (\\192.168.x.x\share)
- Consistent NTFS/Share permissions for the backup account

Example `config.json` with distinct hosts:

```json
{
  "repositories": [
    { "name": "repo-server1-a", "source": "\\fileserver\projA", "description": "Repo A on server 1", "enabled": true },
    { "name": "repo-server1-b", "source": "\\fileserver\projB", "description": "Repo B on server 1", "enabled": true },
    { "name": "repo-vm",        "source": "\\vmapp01\projVM",  "description": "Repo on VM inside server", "enabled": true }
  ]
}
```

Quick validation per host:

```powershell
# Ping and SMB port
Test-Connection fileserver -Count 1
Test-NetConnection fileserver -Port 445
Test-NetConnection vmapp01 -Port 445

# Dedicated credentials (if needed)
cmdkey /add:fileserver /user:DOMAIN\backup_user /pass:password
cmdkey /add:vmapp01 /user:DOMAIN\backup_user /pass:password
```

Validation with script (recommended):

```powershell
# Validate all repositories from config.json
cd D:\scripts
./validate-sources.ps1

# Validate only the VM repo
./validate-sources.ps1 -RepoName repo-vm
```

---

## 6) Quick Examples

Register 3 repositories by editing the file:
```powershell
notepad D:\scripts\config.json
```

Run backup for all:
```powershell
cd D:\scripts
./backup.ps1
```

Via API (all):
```powershell
./api-client.ps1 backup all
```

List backups for a repository:
```powershell
./api-client.ps1 list web-project
```

---

Need a template? See: `docs/usage/repos-template.json`.
