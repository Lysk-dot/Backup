# ========================================
# Script de Restauração de Backup
# Autor: Lysk-dot
# Data: 19/10/2025
# ========================================

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupFile,
    
    [Parameter(Mandatory=$false)]
    [string]$DestinationPath,
    
    [switch]$ListBackups,
    [switch]$VerifyChecksum,
    [switch]$Force
)

# Configurações
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath
$reposPath = Join-Path $rootPath "repos"
$logsPath = Join-Path $rootPath "logs"

# Data e hora atual
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDate = Get-Date -Format "yyyyMMdd"
$logFile = Join-Path $logsPath "restore_$logDate.log"

# Função de log
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error','Success')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        'Info'    { 'White' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
    
    if (-not (Test-Path $logsPath)) {
        New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
    }
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "========================================" -Level Info
Write-Log "Script de Restauração de Backup" -Level Info
Write-Log "========================================" -Level Info

# Verificar se a pasta do repositório existe
$repoBackupPath = Join-Path $reposPath $RepoName
if (-not (Test-Path $repoBackupPath)) {
    Write-Log "Repositório '$RepoName' não encontrado em: $repoBackupPath" -Level Error
    Write-Log "Repositórios disponíveis:" -Level Info
    Get-ChildItem -Path $reposPath -Directory | ForEach-Object {
        Write-Log "  - $($_.Name)" -Level Info
    }
    exit 1
}

# Listar backups disponíveis
if ($ListBackups) {
    Write-Log "Backups disponíveis para '$RepoName':" -Level Info
    Write-Log "----------------------------------------" -Level Info
    
    $backups = Get-ChildItem -Path $repoBackupPath -Filter "*.zip" | Sort-Object LastWriteTime -Descending
    
    if ($backups.Count -eq 0) {
        Write-Log "Nenhum backup encontrado" -Level Warning
        exit 0
    }
    
    foreach ($backup in $backups) {
        $size = [math]::Round($backup.Length / 1MB, 2)
        $date = $backup.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        $hasChecksum = Test-Path "$($backup.FullName).sha256"
        $checksumInfo = if ($hasChecksum) { "[SHA256]" } else { "" }
        
        Write-Log "$($backup.Name) - $size MB - $date $checksumInfo" -Level Info
    }
    exit 0
}

# Selecionar arquivo de backup
if (-not $BackupFile) {
    Write-Log "Selecionando backup mais recente..." -Level Info
    $backups = Get-ChildItem -Path $repoBackupPath -Filter "*.zip" | Sort-Object LastWriteTime -Descending
    
    if ($backups.Count -eq 0) {
        Write-Log "Nenhum backup encontrado para '$RepoName'" -Level Error
        exit 1
    }
    
    $selectedBackup = $backups[0]
} else {
    $selectedBackup = Get-Item -Path (Join-Path $repoBackupPath $BackupFile) -ErrorAction SilentlyContinue
    
    if (-not $selectedBackup) {
        Write-Log "Arquivo de backup não encontrado: $BackupFile" -Level Error
        exit 1
    }
}

Write-Log "Backup selecionado: $($selectedBackup.Name)" -Level Info
Write-Log "Tamanho: $([math]::Round($selectedBackup.Length / 1MB, 2)) MB" -Level Info
Write-Log "Data de criação: $($selectedBackup.LastWriteTime)" -Level Info

# Verificar checksum se solicitado
if ($VerifyChecksum) {
    $checksumFile = "$($selectedBackup.FullName).sha256"
    
    if (Test-Path $checksumFile) {
        Write-Log "Verificando integridade do arquivo..." -Level Info
        
        $storedHash = Get-Content $checksumFile -Raw
        $storedHash = $storedHash.Trim()
        
        $currentHash = (Get-FileHash -Path $selectedBackup.FullName -Algorithm SHA256).Hash
        
        if ($storedHash -eq $currentHash) {
            Write-Log "Verificação de integridade: OK" -Level Success
        } else {
            Write-Log "ERRO: Arquivo corrompido! Checksum não corresponde" -Level Error
            Write-Log "Esperado: $storedHash" -Level Error
            Write-Log "Obtido:   $currentHash" -Level Error
            exit 1
        }
    } else {
        Write-Log "Arquivo de checksum não encontrado" -Level Warning
    }
}

# Definir destino da restauração
if (-not $DestinationPath) {
    $DestinationPath = Join-Path $rootPath "restore_$RepoName`_$timestamp"
}

Write-Log "Destino da restauração: $DestinationPath" -Level Info

# Verificar se o destino existe
if (Test-Path $DestinationPath) {
    if (-not $Force) {
        Write-Log "ERRO: O destino já existe. Use -Force para sobrescrever" -Level Error
        exit 1
    } else {
        Write-Log "Removendo destino existente..." -Level Warning
        Remove-Item -Path $DestinationPath -Recurse -Force
    }
}

# Criar pasta de destino
New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null

# Restaurar backup
Write-Log "Iniciando restauração..." -Level Info

try {
    Expand-Archive -Path $selectedBackup.FullName -DestinationPath $DestinationPath -Force
    Write-Log "Restauração concluída com SUCESSO!" -Level Success
    Write-Log "Arquivos restaurados em: $DestinationPath" -Level Success
    
    # Contar arquivos restaurados
    $fileCount = (Get-ChildItem -Path $DestinationPath -Recurse -File).Count
    Write-Log "Total de arquivos restaurados: $fileCount" -Level Info
    
    exit 0
} catch {
    Write-Log "ERRO ao restaurar backup: $_" -Level Error
    exit 1
}
