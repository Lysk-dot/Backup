
# ========================================
# Backup API Client
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

<#
.SYNOPSIS
    Cliente CLI para interagir com a API de Backup

.EXAMPLE
    .\api-client.ps1 status
    .\api-client.ps1 backup repo1
    .\api-client.ps1 backup all
    .\api-client.ps1 list
    .\api-client.ps1 list repo1
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('status', 'backup', 'list', 'repos', 'add', 'validate')]
    [string]$Command,
    
    [Parameter(Mandatory=$false, Position=1)]
    [string]$Target,
    
    [string]$ApiUrl = "http://localhost:8080"
)

function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $url = "$ApiUrl$Endpoint"
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $url -Method $Method -Body $jsonBody -ContentType "application/json"
        }
        else {
            $response = Invoke-RestMethod -Uri $url -Method $Method
        }
        return $response
    }
    catch {
        Write-Host "Erro ao conectar com a API: $_" -ForegroundColor Red
        Write-Host "Certifique-se de que o servidor esta rodando: .\api-server.ps1" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Backup API Client" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    'status' {
        Write-Host "Consultando status do sistema..." -ForegroundColor Yellow
        $status = Invoke-ApiRequest -Method GET -Endpoint "/api/status"
        
        Write-Host ""
        Write-Host "Status do Sistema:" -ForegroundColor Green
        Write-Host "  Repositorios configurados: $($status.repositories)" -ForegroundColor White
        Write-Host "  Total de backups: $($status.totalBackups)" -ForegroundColor White
        Write-Host "  Tamanho total: $($status.totalSizeMB) MB" -ForegroundColor White
        Write-Host "  Espaco livre no disco: $($status.diskFree) GB" -ForegroundColor White
        Write-Host ""
    }
    
    'backup' {
        if (-not $Target) {
            Write-Host "Erro: Especifique o repositorio ou 'all'" -ForegroundColor Red
            Write-Host "Uso: .\api-client.ps1 backup <repo|all>" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "Iniciando backup de: $Target" -ForegroundColor Yellow
        $result = Invoke-ApiRequest -Method POST -Endpoint "/api/backup/$Target"
        
        if ($Target -eq "all") {
            Write-Host ""
            Write-Host "Resultados do backup:" -ForegroundColor Green
            foreach ($r in $result.results) {
                if ($r.success) {
                    Write-Host "  ✓ $($r.repository): $($r.filename) ($($r.size) MB)" -ForegroundColor Green
                }
                else {
                    Write-Host "  ✗ $($r.repository): $($r.error)" -ForegroundColor Red
                }
            }
        }
        else {
            if ($result.success) {
                Write-Host ""
                Write-Host "✓ Backup criado com sucesso!" -ForegroundColor Green
                Write-Host "  Repositorio: $($result.repository)" -ForegroundColor White
                Write-Host "  Arquivo: $($result.filename)" -ForegroundColor White
                Write-Host "  Tamanho: $($result.size) MB" -ForegroundColor White
            }
            else {
                Write-Host ""
                Write-Host "✗ Erro: $($result.error)" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
    
    'list' {
        if ($Target) {
            Write-Host "Listando backups de: $Target" -ForegroundColor Yellow
            $data = Invoke-ApiRequest -Method GET -Endpoint "/api/backups/$Target"
            $backups = $data.backups
        }
        else {
            Write-Host "Listando todos os backups..." -ForegroundColor Yellow
            $data = Invoke-ApiRequest -Method GET -Endpoint "/api/backups"
            $backups = $data.backups
        }
        
        if ($backups.Count -eq 0) {
            Write-Host ""
            Write-Host "Nenhum backup encontrado" -ForegroundColor Yellow
        }
        else {
            Write-Host ""
            Write-Host "Backups disponiveis:" -ForegroundColor Green
            Write-Host ""
            
            $backups | ForEach-Object {
                $check = if ($_.hasChecksum) { "[SHA256]" } else { "" }
                Write-Host "  $($_.repository):" -ForegroundColor Cyan
                Write-Host "    Arquivo: $($_.filename)" -ForegroundColor White
                Write-Host "    Tamanho: $($_.size) MB" -ForegroundColor White
                Write-Host "    Data: $($_.date) $check" -ForegroundColor Gray
                Write-Host ""
            }
        }
    }
    
    'repos' {
        Write-Host "Listando repositorios..." -ForegroundColor Yellow
        $data = Invoke-ApiRequest -Method GET -Endpoint "/api/repositories"
        
        Write-Host ""
        Write-Host "Repositorios configurados:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($repo in $data.repositories) {
            $status = if ($repo.enabled) { "[ATIVO]" } else { "[INATIVO]" }
            $color = if ($repo.enabled) { "Green" } else { "Gray" }
            
            Write-Host "  $($repo.name) $status" -ForegroundColor $color
            Write-Host "    Origem: $($repo.source)" -ForegroundColor White
            Write-Host "    Descricao: $($repo.description)" -ForegroundColor Gray
            Write-Host ""
        }
    }
    
    'add' {
        Write-Host "Adicionar novo repositorio" -ForegroundColor Yellow
        Write-Host ""
        
        $name = Read-Host "Nome do repositorio"
        $source = Read-Host "Caminho de origem (ex: \\servidor\compartilhamento\pasta)"
        $description = Read-Host "Descricao"
        
        $newRepo = @{
            name = $name
            source = $source
            description = $description
            enabled = $true
        }
        
        $result = Invoke-ApiRequest -Method POST -Endpoint "/api/repositories" -Body $newRepo
        
        if ($result.success) {
            Write-Host ""
            Write-Host "✓ Repositorio adicionado com sucesso!" -ForegroundColor Green
        }
        else {
            Write-Host ""
            Write-Host "✗ Erro ao adicionar repositorio" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    'validate' {
        if ($Target) {
            Write-Host "Validando repositório: $Target" -ForegroundColor Yellow
            try {
                $result = Invoke-ApiRequest -Method GET -Endpoint "/api/repositories/validate/$Target"
                Write-Host ""; Write-Host "Resultado:" -ForegroundColor Green
                $result | ConvertTo-Json -Depth 10
            } catch {
                Write-Host "Falha ao validar $Target via API. Tente o script local: .\\validate-sources.ps1 -RepoName $Target" -ForegroundColor Red
            }
        } else {
            Write-Host "Validando todos os repositórios..." -ForegroundColor Yellow
            try {
                $result = Invoke-ApiRequest -Method GET -Endpoint "/api/repositories/validate"
                Write-Host ""; Write-Host "Resultados:" -ForegroundColor Green
                $result | ConvertTo-Json -Depth 10
            } catch {
                Write-Host "Falha ao validar via API. Tente o script local: .\\validate-sources.ps1" -ForegroundColor Red
            }
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
