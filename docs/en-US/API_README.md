# Backup API - Documentation

## 🌐 Overview

REST API for managing backups on HD. Lightweight and efficient solution for remote backup control without overloading the disk.

## 🎯 API Approach Advantages

✅ **Performance**: Asynchronous processing, does not block operations  
✅ **Efficiency**: Lower HD resource usage  
✅ **Scalability**: Multiple clients can connect  
✅ **Monitoring**: Real-time status  
✅ **Automation**: Easy integration with scripts and tools  
✅ **Remote**: Control over the network  

## 🚀 Quick Start

### 1. Start the API Server

```powershell
cd D:\scripts
./api-server.ps1
```

The server will be available at: `http://localhost:8080`

To use another port:
```powershell
./api-server.ps1 -Port 9000
```

### 2. Use the CLI Client

```powershell
# System status
./api-client.ps1 status

# Backup a repository
./api-client.ps1 backup repo1

# Backup all
./api-client.ps1 backup all

# List backups
./api-client.ps1 list

# List repositories
./api-client.ps1 repos

# Add new repository
./api-client.ps1 add
```

## 📡 API Endpoints

### System Status
```http
GET /api/status
```

**Response:**
```json
{
  "repositories": 3,
  "totalBackups": 15,
  "totalSizeMB": 1250.5,
  "diskFree": 450.2,
  "uptime": 12.5
}
```

### List Repositories
```http
GET /api/repositories
```

**Response:**
```json
{
  "repositories": [
    {
      "name": "repo1",
      "source": "\\server\repo1",
      "description": "Repository 1",
      "enabled": true
    }
  ]
}
```

### Add Repository
```http
POST /api/repositories
Content-Type: application/json

{
  "name": "repo4",
  "source": "\\server\repo4",
  "description": "New repository",
  "enabled": true
}
```

### List All Backups
```http
GET /api/backups
```

**Response:**
```json
{
  "backups": [
    {
      "repository": "repo1",
      "filename": "repo1_20251019_143000.zip",
      "size": 125.5,
      "date": "2025-10-19 14:30:00",
      "hasChecksum": true
    }
  ]
}
```

### List Backups for a Repository
```http
GET /api/backups/repo1
```

### Create Backup for a Repository
```http
POST /api/backup/repo1
```

**Response (Success):**
```json
{
  "success": true,
  "repository": "repo1",
  "filename": "repo1_20251019_143000.zip",
  "size": 125.5,
  "timestamp": "20251019_143000"
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "Source path not found"
}
```

### Create Backup for All Repositories
```http
POST /api/backup/all
```

**Response:**
```json
{
  "results": [
    {
      "success": true,
      "repository": "repo1",
      "filename": "repo1_20251019_143000.zip",
      "size": 125.5
    },
    {
      "success": true,
      "repository": "repo2",
      "filename": "repo2_20251019_143001.zip",
      "size": 89.2
    }
  ]
}
```

## 💻 Usage Examples

### PowerShell

```powershell
# Status
Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Method GET

# Backup
Invoke-RestMethod -Uri "http://localhost:8080/api/backup/repo1" -Method POST

# List backups
Invoke-RestMethod -Uri "http://localhost:8080/api/backups" -Method GET
```

### cURL

```bash
# Status
curl http://localhost:8080/api/status

# Backup
curl -X POST http://localhost:8080/api/backup/repo1

# Add repository
curl -X POST http://localhost:8080/api/repositories \
  -H "Content-Type: application/json" \
  -d '{"name":"repo4","source":"\\\\server\\repo4","description":"New","enabled":true}'
```

### Python

```python
import requests

API_URL = "http://localhost:8080"

# Status
response = requests.get(f"{API_URL}/api/status")
print(response.json())

# Backup
response = requests.post(f"{API_URL}/api/backup/repo1")
print(response.json())

# List backups
response = requests.get(f"{API_URL}/api/backups")
for backup in response.json()['backups']:
    print(f"{backup['repository']}: {backup['filename']}")
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

const API_URL = 'http://localhost:8080';

// Status
async function getStatus() {
  const response = await axios.get(`${API_URL}/api/status`);
  console.log(response.data);
}

// Backup
async function createBackup(repo) {
  const response = await axios.post(`${API_URL}/api/backup/${repo}`);
  console.log(response.data);
}

getStatus();
createBackup('repo1');
```

## 🤖 Automation

### Scheduled Backup via Task Scheduler

```powershell
# Create daily backup task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"Invoke-RestMethod -Uri 'http://localhost:8080/api/backup/all' -Method POST`""
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName "BackupAPI_Daily" -Action $action -Trigger $trigger
```

### Monitoring Script

```powershell
# monitor.ps1
while ($true) {
    $status = Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Method GET
    Write-Host "Backups: $($status.totalBackups) | Free space: $($status.diskFree) GB"
    Start-Sleep -Seconds 60
}
```

## 🛠 Network Configuration

### Remote Access

By default, the API only accepts local connections. For remote access:

1. **Run as Administrator**
2. **Configure Firewall:**

```powershell
# Add firewall rule
New-NetFirewallRule -DisplayName "Backup API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

3. **Start server:**

```powershell
./api-server.ps1 -Port 8080
```

4. **Access from another computer:**

```powershell
./api-client.ps1 status -ApiUrl "http://192.168.1.100:8080"
```

## 📊 Monitoring and Logs

All logs are saved in `logs/api_AAAAMMDD.log`

```powershell
# View logs in real time
Get-Content "D:\logs\api_$(Get-Date -Format 'yyyyMMdd').log" -Wait

# Last 50 lines
Get-Content "D:\logs\api_$(Get-Date -Format 'yyyyMMdd').log" -Tail 50
```

## 🔒 Security

### Recommendations

1. ✅ Use firewall to restrict access
2. ✅ Run on a private network
3. ✅ Consider adding authentication (token/API key)
4. ✅ Use HTTPS in production
5. ✅ Monitor logs regularly

### Add Simple Authentication (Optional)

Edit `api-server.ps1` and add token validation:

```powershell
$apiKey = "your-secret-token-here"

# At the start of the request loop:
$authHeader = $request.Headers["Authorization"]
if ($authHeader -ne "Bearer $apiKey") {
    $statusCode = 401
    $responseData = @{ error = "Unauthorized" } | ConvertTo-Json
    # ... return error
}
```

Client:
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Headers @{Authorization="Bearer your-secret-token-here"}
```

## 📝 Next Steps

1. Start server: `./api-server.ps1`
2. Test client: `./api-client.ps1 status`
3. Configure repositories via API
4. Schedule automatic backups
5. Monitor logs
