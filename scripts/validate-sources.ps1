
# ========================================
# Validador de Fontes de Backup | Backup Source Validator
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
    [string]$RepoName,
    [switch]$Verbose
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptPath "config.json"

function Write-Color([string]$msg, [string]$color = 'White') { Write-Host $msg -ForegroundColor $color }

if (-not (Test-Path $configFile)) { Write-Color "Config não encontrada: $configFile" 'Red'; exit 1 }
$config = Get-Content $configFile -Raw | ConvertFrom-Json

$repos = if ($RepoName) { $config.repositories | Where-Object { $_.name -eq $RepoName } } else { $config.repositories }
if (-not $repos -or $repos.Count -eq 0) { Write-Color "Nenhum repositório encontrado para validar." 'Yellow'; exit 1 }

# Util: Extrair host de caminho UNC: \\host\share\...
function Get-HostFromUNC([string]$unc) {
    if ($unc -match "^\\\\([^\\]+)\\") { return $matches[1] } else { return $null }
}

# Teste de conectividade
function Test-Connectivity([string]$host) {
    $ping = Test-Connection -ComputerName $host -Count 1 -Quiet -ErrorAction SilentlyContinue
    $port445 = Test-NetConnection -ComputerName $host -Port 445 -InformationLevel Quiet
    return @{ ping = $ping; smb445 = $port445 }
}

# Execução
foreach ($r in $repos) {
    Write-Color "\nValidando: $($r.name)" 'Cyan'
    Write-Color "Origem: $($r.source)" 'Gray'

    $host = Get-HostFromUNC $r.source
    if (-not $host) { Write-Color "Caminho UNC inválido" 'Red'; continue }

    # Conectividade
    $conn = Test-Connectivity $host
    Write-Color "Ping ($host): $($conn.ping)" ($conn.ping ? 'Green' : 'Red')
    Write-Color "Porta 445/SMB: $($conn.smb445)" ($conn.smb445 ? 'Green' : 'Red')

    # Credenciais (opcional) - listar credenciais salvas para o host
    $creds = cmdkey /list | Select-String -Pattern $host
    if ($creds) { Write-Color "Credenciais armazenadas encontradas para $host" 'Green' } else { Write-Color "Sem credenciais armazenadas para $host (se necessário, use cmdkey)" 'Yellow' }

    # Acesso ao caminho
    $exists = Test-Path $r.source
    Write-Color "Acesso ao caminho: $exists" ($exists ? 'Green' : 'Red')

    if ($exists) {
        try {
            $items = Get-ChildItem $r.source -Force -ErrorAction Stop | Select-Object -First 5
            Write-Color "Itens (amostra):" 'Gray'
            $items | ForEach-Object { Write-Color "  - $($_.Name)" 'Gray' }
        } catch {
            Write-Color "Erro ao listar conteúdo: $_" 'Red'
        }
    }
}
