# Automatic Backup Upload to Remote Server (FastAPI)

## How it works

After local backup execution, the system can automatically upload the generated ZIP file to a remote Linux server running FastAPI, using the `upload-backup.ps1` script.

### Prerequisites
- FastAPI server running (port 9101, endpoint `/upload`)
- Valid authentication token
- API parameters set in `config.json` (`apiUrl`, `apiToken`)

## Required parameters
- Path to the generated ZIP file
- API endpoint URL
- Authentication token
- Repository name

## Example of automatic integration
The `backup.ps1` script is already configured to automatically call `upload-backup.ps1` after each backup, if `apiUrl` and `apiToken` keys are present in `config.json`:

```powershell
# Excerpt from backup.ps1
$apiUrl = $config.settings.apiUrl
$apiToken = $config.settings.apiToken
if ($apiUrl -and $apiToken) {
    $uploadScript = Join-Path $scriptPath 'upload-backup.ps1'
    $uploadParams = @{
        FilePath = $backupFilePath
        ApiUrl = $apiUrl
        Token = $apiToken
        Repository = $repo.name
    }
    & $uploadScript @uploadParams
}
```

## Notes
- Upload is performed only if API keys are present.
- Success or error logs are automatically recorded.
- Upload is performed for each repository individually, right after ZIP creation.

## Security
- The token must never be shared publicly.
- The endpoint should be protected and accessible only by authorized hosts.
