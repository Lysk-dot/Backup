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
    # PowerShell 5.1 compatível - usando multipart/form-data manualmente
    Add-Type -AssemblyName System.Net.Http
    
    $httpClient = New-Object System.Net.Http.HttpClient
    $httpClient.Timeout = New-TimeSpan -Seconds 300
    
    $content = New-Object System.Net.Http.MultipartFormDataContent
    
    # Adicionar arquivo
    $fileStream = [System.IO.File]::OpenRead($FilePath)
    $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/octet-stream")
    $content.Add($fileContent, "file", [System.IO.Path]::GetFileName($FilePath))
    
    # Adicionar headers
    $httpClient.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $Token)
    $httpClient.DefaultRequestHeaders.Add("X-Repository-Name", $Repository)
    
    # Enviar request
    Write-Host "Enviando backup para $ApiUrl..." -ForegroundColor Cyan
    $response = $httpClient.PostAsync($ApiUrl, $content).Result
    
    if ($response.IsSuccessStatusCode) {
        $responseBody = $response.Content.ReadAsStringAsync().Result
        Write-Host "Upload realizado com sucesso!" -ForegroundColor Green
        Write-Host $responseBody -ForegroundColor Gray
        $fileStream.Close()
        $httpClient.Dispose()
        exit 0
    } else {
        $errorBody = $response.Content.ReadAsStringAsync().Result
        Write-Host "Erro HTTP $($response.StatusCode): $errorBody" -ForegroundColor Red
        $fileStream.Close()
        $httpClient.Dispose()
        exit 2
    }
} catch {
    Write-Host "Erro ao enviar backup: $_" -ForegroundColor Red
    exit 2
}
