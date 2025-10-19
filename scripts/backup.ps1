
# ========================================
# Script de Backup Automatizado | Automated Backup Script
# Autor/Author: Felipe Petracco Carmo <kuramopr@gmail.com>
# Data/Date: 19/10/2025
#
# Copyright (c) 2025 Felipe Petracco Carmo
# Todos os direitos reservados. | All rights reserved.
#
# Este software é fornecido "como está", sem garantias
# de qualquer tipo, expressas ou implícitas.
# This software is provided "as is", without warranty of any kind,
# express or implied.
# ========================================

param(
    [switch]$Force,
    [switch]$Verbose
)

# Configurações
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath
$configFile = Join-Path $scriptPath "config.json"
$logsPath = Join-Path $rootPath "logs"
$reposPath = Join-Path $rootPath "repos"

# Data e hora atual
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDate = Get-Date -Format "yyyyMMdd"
$logFile = Join-Path $logsPath "backup_$logDate.log"

# Função de log
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error','Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Cores para console
    $color = switch ($Level) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $logMessage
}

# Criar diretórios se não existirem
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
}

if (-not (Test-Path $reposPath)) {
    New-Item -ItemType Directory -Path $reposPath -Force | Out-Null
}

# Iniciar log
Write-Log "========================================" -Level Info
Write-Log "Iniciando processo de backup" -Level Info
Write-Log "========================================" -Level Info

# Carregar configurações
if (-not (Test-Path $configFile)) {
    Write-Log "Arquivo de configuração não encontrado: $configFile" -Level Error
    exit 1
}

try {
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    Write-Log "Configurações carregadas com sucesso" -Level Success
} catch {
    Write-Log "Erro ao carregar configurações: $_" -Level Error
    exit 1
}

# Contadores
$totalRepos = 0
$successCount = 0
$errorCount = 0

# Processar cada repositório
foreach ($repo in $config.repositories) {
    if (-not $repo.enabled) {
        Write-Log "Repositório '$($repo.name)' desabilitado, pulando..." -Level Warning
        continue
    }
    
    $totalRepos++
    Write-Log "----------------------------------------" -Level Info
    Write-Log "Processando: $($repo.name)" -Level Info
    Write-Log "Origem: $($repo.source)" -Level Info
    
    # Verificar se a origem existe
    if (-not (Test-Path $repo.source)) {
        Write-Log "Caminho de origem não encontrado: $($repo.source)" -Level Error
        $errorCount++
        continue
    }
    
    # Criar pasta do repositório
    $repoBackupPath = Join-Path $reposPath $repo.name
    if (-not (Test-Path $repoBackupPath)) {
        New-Item -ItemType Directory -Path $repoBackupPath -Force | Out-Null
        Write-Log "Pasta criada: $repoBackupPath" -Level Info
    }
    
    # Nome do arquivo de backup
    $backupFileName = "$($repo.name)_$timestamp.zip"
    $backupFilePath = Join-Path $repoBackupPath $backupFileName
    
    Write-Log "Criando backup: $backupFileName" -Level Info
    
    try {
        # Comprimir arquivos usando a configuração de compressão
        $compressionLevel = 'Optimal'
        if ($config.settings.compression) {
            switch ($config.settings.compression.ToString()) {
                'Optimal' { $compressionLevel = 'Optimal' }
                'Fastest' { $compressionLevel = 'Fastest' }
                'NoCompression' { $compressionLevel = 'NoCompression' }
                default { $compressionLevel = 'Optimal' }
            }
        }
        Compress-Archive -Path "$($repo.source)\*" -DestinationPath $backupFilePath -CompressionLevel $compressionLevel -Force
        
        # Verificar se foi criado
        if (Test-Path $backupFilePath) {
            $fileSize = (Get-Item $backupFilePath).Length
            $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
            Write-Log "Backup criado com sucesso! Tamanho: $fileSizeMB MB" -Level Success
            
            # Criar checksum se configurado
            if ($config.settings.createChecksum) {
                $hash = Get-FileHash -Path $backupFilePath -Algorithm SHA256
                $hashFile = "$backupFilePath.sha256"
                $hash.Hash | Out-File -FilePath $hashFile -Encoding utf8
                Write-Log "Checksum SHA256 criado" -Level Info
            }
            
            $successCount++

            # Enviar backup para servidor remoto (FastAPI)
            $apiUrl = $config.settings.apiUrl
            $apiToken = $config.settings.apiToken
            if ($apiUrl -and $apiToken) {
                $uploadScript = Join-Path $scriptPath 'upload-backup.ps1'
                if (Test-Path $uploadScript) {
                    Write-Log "Enviando backup para servidor remoto..." -Level Info
                    $uploadParams = @{
                        FilePath = $backupFilePath
                        ApiUrl = $apiUrl
                        Token = $apiToken
                        Repository = $repo.name
                    }
                    $uploadResult = & $uploadScript @uploadParams
                    if ($LASTEXITCODE -eq 0) {
                        Write-Log "Upload realizado com sucesso." -Level Success
                    } else {
                        Write-Log "Falha ao enviar backup remoto." -Level Error
                    }
                } else {
                    Write-Log "Script de upload não encontrado: $uploadScript" -Level Warning
                }
            }
        } else {
            Write-Log "Erro: Arquivo de backup não foi criado" -Level Error
            $errorCount++
        }
        
    } catch {
        Write-Log "Erro ao criar backup: $_" -Level Error
        $errorCount++
        continue
    }
    
    # Limpar backups antigos (manter apenas os N mais recentes)
    $keepBackups = $config.settings.keepBackups
    Write-Log "Verificando backups antigos (manter: $keepBackups)" -Level Info
    
    $existingBackups = Get-ChildItem -Path $repoBackupPath -Filter "*.zip" | 
                      Sort-Object LastWriteTime -Descending
    
    if ($existingBackups.Count -gt $keepBackups) {
        $toDelete = $existingBackups | Select-Object -Skip $keepBackups
        foreach ($old in $toDelete) {
            Remove-Item $old.FullName -Force
            # Remover checksum associado
            $hashFile = "$($old.FullName).sha256"
            if (Test-Path $hashFile) {
                Remove-Item $hashFile -Force
            }
            Write-Log "Backup antigo removido: $($old.Name)" -Level Warning
        }
    }
}

# Resumo final
Write-Log "========================================" -Level Info
Write-Log "RESUMO DO BACKUP" -Level Info
Write-Log "----------------------------------------" -Level Info
Write-Log "Total de repositórios processados: $totalRepos" -Level Info
Write-Log "Backups realizados com sucesso: $successCount" -Level Success
Write-Log "Erros encontrados: $errorCount" -Level $(if ($errorCount -gt 0) { 'Error' } else { 'Info' })
Write-Log "========================================" -Level Info

if ($errorCount -eq 0 -and $successCount -gt 0) {
    Write-Log "Processo de backup concluído com SUCESSO!" -Level Success
    exit 0
} elseif ($errorCount -gt 0) {
    Write-Log "Processo de backup concluído com ERROS!" -Level Error
    exit 1
} else {
    Write-Log "Nenhum backup foi realizado." -Level Warning
    exit 2
}
