
# ========================================
# Monitor de Saúde do Disco/HD (Loop) | Disk/HD Health Monitor (Loop)
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
    [string]$DriveLetter = 'D',
    [int]$IntervalSeconds = 300,
    [string]$StatusJson = 'D:\status\health-status.json',
    [string]$LogFile = 'D:\logs\health_monitor.log'
)

function Write-Log([string]$msg, [string]$level='INFO') {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$level] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

Write-Log "Iniciando monitor de saúde do disco ($DriveLetter:)" 'INFO'
Write-Log "Intervalo: $IntervalSeconds s | Status: $StatusJson" 'INFO'

while ($true) {
    try {
        $result = & "$PSScriptRoot\health-check.ps1" -DriveLetter $DriveLetter -OutJson $StatusJson -Quiet
        # Ler JSON para decisões
        $status = Get-Content $StatusJson -Raw | ConvertFrom-Json
        $health = $status.health
        $freePct = $status.freePct
        $alerts = $status.alerts -join '; '

        if ($health -eq 'OK') {
            Write-Log "OK - Livre: $freePct%" 'INFO'
        } elseif ($health -eq 'WARN') {
            Write-Log "WARN - $alerts (Livre: $freePct%)" 'WARN'
        } else {
            Write-Log "ALERT - $alerts (Livre: $freePct%)" 'ERROR'
        }
    } catch {
        Write-Log "Erro ao executar health-check: $_" 'ERROR'
    }
    Start-Sleep -Seconds $IntervalSeconds
}
