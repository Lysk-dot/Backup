# ========================================
# Backup API Server
# ========================================
# Autor: Felipe Petracco Carmo
# Email: kuramopr@gmail.com
# Data: 19/10/2025
# 
# Copyright (c) 2025 Felipe Petracco Carmo
# Todos os direitos reservados.
# 
# Este software é fornecido "como esta", sem garantias
# de qualquer tipo, expressas ou implicitas.
# ========================================

<#
.SYNOPSIS
    API REST para gerenciamento de backups

.DESCRIPTION
    Servidor HTTP leve que expõe endpoints para:
    - Criar backups
    - Listar backups
    - Restaurar backups
    - Gerenciar repositórios
    - Verificar status

.PARAMETER Port
    Porta do servidor (padrão: 8080)

.EXAMPLE
    .\api-server.ps1
    .\api-server.ps1 -Port 9000
#>

param(
    [int]$Port = 8080
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath
$configFile = Join-Path $scriptPath "config.json"
$logsPath = Join-Path $rootPath "logs"
$reposPath = Join-Path $rootPath "repos"
$statusJson = Join-Path $rootPath "status\health-status.json"

# Criar diretórios necessários
if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath -Force | Out-Null }
if (-not (Test-Path $reposPath)) { New-Item -ItemType Directory -Path $reposPath -Force | Out-Null }

# Log
function Write-ApiLog {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    $logFile = Join-Path $logsPath "api_$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage -ForegroundColor $(if($Level -eq 'ERROR'){'Red'}elseif($Level -eq 'WARN'){'Yellow'}else{'White'})
}

# Carregar configuração
function Get-Config {
    if (Test-Path $configFile) {
        return Get-Content $configFile -Raw | ConvertFrom-Json
    }
    return $null
}

# Salvar configuração
function Save-Config {
    param($Config)
    $Config | ConvertTo-Json -Depth 10 | Set-Content $configFile -Encoding UTF8
}

# Validação de repositórios (conectividade e acesso)
function Validate-Repository {
    param([object]$Repo)
    
    # Extrair host do caminho UNC
    $host = $null
    if ($Repo.source -match "^\\\\([^\\]+)\\") { $host = $matches[1] }
    
    $ping = $null; $smb = $null; $pathExists = $false; $sample = @(); $error = $null
    try { $ping = Test-Connection -ComputerName $host -Count 1 -Quiet -ErrorAction SilentlyContinue } catch {}
    try { $smb = Test-NetConnection -ComputerName $host -Port 445 -InformationLevel Quiet } catch {}
    try { $pathExists = Test-Path $Repo.source } catch {}
    if ($pathExists) {
        try { $sample = (Get-ChildItem $Repo.source -Force | Select-Object -First 5 | ForEach-Object { $_.Name }) } catch { $error = $_.Exception.Message }
    }
    return @{
        name = $Repo.name
        host = $host
        ping = $ping
        smb445 = $smb
        pathExists = $pathExists
        sample = $sample
        error = $error
    }
}

# Função para executar backup
function Invoke-Backup {
    param([string]$RepoName)
    
    $config = Get-Config
    $repo = $config.repositories | Where-Object { $_.name -eq $RepoName }
    
    if (-not $repo) {
        return @{ success = $false; error = "Repository not found" }
    }
    
    if (-not $repo.enabled) {
        return @{ success = $false; error = "Repository is disabled" }
    }
    
    if (-not (Test-Path $repo.source)) {
        return @{ success = $false; error = "Source path not found: $($repo.source)" }
    }
    
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $repoBackupPath = Join-Path $reposPath $repo.name
        
        if (-not (Test-Path $repoBackupPath)) {
            New-Item -ItemType Directory -Path $repoBackupPath -Force | Out-Null
        }
        
        $backupFileName = "$($repo.name)_$timestamp.zip"
        $backupFilePath = Join-Path $repoBackupPath $backupFileName
        
        Write-ApiLog "Starting backup for $RepoName" "INFO"
        
        Compress-Archive -Path "$($repo.source)\*" -DestinationPath $backupFilePath -CompressionLevel Optimal -Force
        
        $fileSize = (Get-Item $backupFilePath).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
        
        # Criar checksum
        if ($config.settings.createChecksum) {
            $hash = Get-FileHash -Path $backupFilePath -Algorithm SHA256
            $hashFile = "$backupFilePath.sha256"
            $hash.Hash | Out-File -FilePath $hashFile -Encoding utf8
        }
        
        # Limpar backups antigos
        $keepBackups = $config.settings.keepBackups
        $existingBackups = Get-ChildItem -Path $repoBackupPath -Filter "*.zip" | Sort-Object LastWriteTime -Descending
        
        if ($existingBackups.Count -gt $keepBackups) {
            $toDelete = $existingBackups | Select-Object -Skip $keepBackups
            foreach ($old in $toDelete) {
                Remove-Item $old.FullName -Force
                $hashFile = "$($old.FullName).sha256"
                if (Test-Path $hashFile) { Remove-Item $hashFile -Force }
            }
        }
        
        Write-ApiLog "Backup completed for $RepoName - Size: $fileSizeMB MB" "INFO"
        
        return @{
            success = $true
            repository = $RepoName
            filename = $backupFileName
            size = $fileSizeMB
            timestamp = $timestamp
        }
    }
    catch {
        Write-ApiLog "Backup failed for $RepoName : $_" "ERROR"
        return @{ success = $false; error = $_.Exception.Message }
    }
}

# Função para listar backups
function Get-Backups {
    param([string]$RepoName = $null)
    
    $result = @()
    
    if ($RepoName) {
        $repoPath = Join-Path $reposPath $RepoName
        if (Test-Path $repoPath) {
            $backups = Get-ChildItem -Path $repoPath -Filter "*.zip" | Sort-Object LastWriteTime -Descending
            foreach ($backup in $backups) {
                $result += @{
                    repository = $RepoName
                    filename = $backup.Name
                    size = [math]::Round($backup.Length / 1MB, 2)
                    date = $backup.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                    hasChecksum = (Test-Path "$($backup.FullName).sha256")
                }
            }
        }
    }
    else {
        $repos = Get-ChildItem -Path $reposPath -Directory
        foreach ($repo in $repos) {
            $backups = Get-ChildItem -Path $repo.FullName -Filter "*.zip" | Sort-Object LastWriteTime -Descending
            foreach ($backup in $backups) {
                $result += @{
                    repository = $repo.Name
                    filename = $backup.Name
                    size = [math]::Round($backup.Length / 1MB, 2)
                    date = $backup.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                    hasChecksum = (Test-Path "$($backup.FullName).sha256")
                }
            }
        }
    }
    
    return $result
}

# Função para obter status
function Get-Status {
    $config = Get-Config
    $totalBackups = 0
    $totalSize = 0
    
    foreach ($repo in $config.repositories) {
        $repoPath = Join-Path $reposPath $repo.name
        if (Test-Path $repoPath) {
            $backups = Get-ChildItem -Path $repoPath -Filter "*.zip"
            $totalBackups += $backups.Count
            $totalSize += ($backups | Measure-Object -Property Length -Sum).Sum
        }
    }
    
    return @{
        repositories = $config.repositories.Count
        totalBackups = $totalBackups
        totalSizeMB = [math]::Round($totalSize / 1MB, 2)
        diskFree = [math]::Round((Get-PSDrive D).Free / 1GB, 2)
        uptime = [math]::Round(((Get-Date) - [DateTime]::Now.Date).TotalHours, 2)
    }
}

# HTTP Listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")

try {
    $listener.Start()
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Backup API Server" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Server rodando em: http://localhost:$Port" -ForegroundColor Green
    Write-Host ""
    Write-Host "Endpoints disponiveis:" -ForegroundColor Yellow
    Write-Host "  GET  /api/status              - Status do sistema" -ForegroundColor White
    Write-Host "  GET  /api/repositories        - Listar repositorios" -ForegroundColor White
    Write-Host "  POST /api/repositories        - Adicionar repositorio" -ForegroundColor White
    Write-Host "  GET  /api/repositories/validate            - Validar todos repos" -ForegroundColor White
    Write-Host "  GET  /api/repositories/validate/{repo}     - Validar um repo" -ForegroundColor White
    Write-Host "  GET  /api/health              - Status de saúde do disco" -ForegroundColor White
    Write-Host "  GET  /api/backups             - Listar todos backups" -ForegroundColor White
    Write-Host "  GET  /api/backups/{repo}      - Listar backups de um repo" -ForegroundColor White
    Write-Host "  POST /api/backup/{repo}       - Criar backup" -ForegroundColor White
    Write-Host "  POST /api/backup/all          - Backup de todos repos" -ForegroundColor White
    Write-Host ""
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Gray
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-ApiLog "API Server started on port $Port" "INFO"
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $method = $request.HttpMethod
        $url = $request.RawUrl
        
        Write-ApiLog "$method $url" "INFO"
        
        $responseData = ""
        $statusCode = 200
        
        try {
            # Routing
            if ($url -eq "/api/status" -and $method -eq "GET") {
                $responseData = Get-Status | ConvertTo-Json -Depth 10
            }
            elseif ($url -eq "/api/repositories" -and $method -eq "GET") {
                $config = Get-Config
                $responseData = @{ repositories = $config.repositories } | ConvertTo-Json -Depth 10
            }
            elseif ($url -eq "/api/repositories" -and $method -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd() | ConvertFrom-Json
                $config = Get-Config
                $config.repositories += $body
                Save-Config $config
                $responseData = @{ success = $true; message = "Repository added" } | ConvertTo-Json
            }
            elseif ($url -eq "/api/health" -and $method -eq "GET") {
                if (Test-Path $statusJson) {
                    $responseData = Get-Content $statusJson -Raw
                } else {
                    # Executa uma checagem rápida on-demand se não existir
                    try {
                        & "$scriptPath\..\scripts\health-check.ps1" -Quiet | Out-Null
                    } catch {}
                    if (Test-Path $statusJson) {
                        $responseData = Get-Content $statusJson -Raw
                    } else {
                        $statusCode = 503
                        $responseData = @{ error = "Health status not available" } | ConvertTo-Json
                    }
                }
            }
            elseif ($url -eq "/api/repositories/validate" -and $method -eq "GET") {
                $config = Get-Config
                $results = @()
                foreach ($repo in $config.repositories) { $results += (Validate-Repository -Repo $repo) }
                $responseData = @{ results = $results } | ConvertTo-Json -Depth 10
            }
            elseif ($url -match "^/api/repositories/validate/(.+)$" -and $method -eq "GET") {
                $repoName = $matches[1]
                $config = Get-Config
                $repo = $config.repositories | Where-Object { $_.name -eq $repoName }
                if (-not $repo) {
                    $statusCode = 404
                    $responseData = @{ error = "Repository not found" } | ConvertTo-Json
                } else {
                    $result = Validate-Repository -Repo $repo
                    $responseData = $result | ConvertTo-Json -Depth 10
                }
            }
            elseif ($url -eq "/api/backups" -and $method -eq "GET") {
                $backups = Get-Backups
                $responseData = @{ backups = $backups } | ConvertTo-Json -Depth 10
            }
            elseif ($url -match "^/api/backups/(.+)$" -and $method -eq "GET") {
                $repoName = $matches[1]
                $backups = Get-Backups -RepoName $repoName
                $responseData = @{ repository = $repoName; backups = $backups } | ConvertTo-Json -Depth 10
            }
            elseif ($url -match "^/api/backup/(.+)$" -and $method -eq "POST") {
                $repoName = $matches[1]
                if ($repoName -eq "all") {
                    $config = Get-Config
                    $results = @()
                    foreach ($repo in $config.repositories | Where-Object { $_.enabled }) {
                        $results += Invoke-Backup -RepoName $repo.name
                    }
                    $responseData = @{ results = $results } | ConvertTo-Json -Depth 10
                }
                else {
                    $result = Invoke-Backup -RepoName $repoName
                    $responseData = $result | ConvertTo-Json -Depth 10
                }
            }
            else {
                $statusCode = 404
                $responseData = @{ error = "Endpoint not found" } | ConvertTo-Json
            }
        }
        catch {
            $statusCode = 500
            $responseData = @{ error = $_.Exception.Message } | ConvertTo-Json
            Write-ApiLog "Error processing request: $_" "ERROR"
        }
        
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseData)
        $response.ContentType = "application/json"
        $response.ContentLength64 = $buffer.Length
        $response.StatusCode = $statusCode
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}
catch {
    Write-ApiLog "Server error: $_" "ERROR"
}
finally {
    $listener.Stop()
    Write-ApiLog "API Server stopped" "INFO"
}
