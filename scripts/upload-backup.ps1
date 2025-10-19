# upload-backup.ps1
# Script para enviar backup ZIP para servidor FastAPI remoto
# Author: Felipe Petracco Carmo <kuramopr@gmail.com>
# Data: 19/10/2025
# License: Uso pessoal/estudo, compatível apenas com Windows

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$true)]
    [string]$ApiUrl,
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [Parameter(Mandatory=$true)]
    [string]$Repository
)

if (-not (Test-Path $FilePath)) {
    Write-Host "Arquivo não encontrado: $FilePath" -ForegroundColor Red
    exit 1
}

try {
    $Headers = @{ Authorization = "Bearer $Token" }
    $Form = @{ file = Get-Item $FilePath; repository = $Repository }
    $Response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Headers $Headers -Form $Form -TimeoutSec 300
    Write-Host "Upload realizado com sucesso: $($Response.message)" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Erro ao enviar backup: $_" -ForegroundColor Red
    exit 2
}
