
# ========================================
# Health Check - Disco/HD
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
    [string]$OutJson = 'D:\status\health-status.json',
    [switch]$Quiet
)

function Write-Color([string]$msg, [string]$color = 'White') { if (-not $Quiet) { Write-Host $msg -ForegroundColor $color } }

# Info de volume
$drive = Get-PSDrive $DriveLetter -ErrorAction SilentlyContinue
if (-not $drive) { Write-Color "Drive $DriveLetter: não encontrado" 'Red'; exit 1 }

# SMART via WMI/CIM (pode exigir permissão/admin e suporte do driver)
$smartStatus = $null
try {
    $disk = Get-CimInstance -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus -ErrorAction Stop | Select-Object -First 1
    if ($disk) { $smartStatus = @{ PredictFailure = $disk.PredictFailure; Active = $disk.Active } }
} catch { $smartStatus = @{ error = 'SMART not available' } }

# Eventos recentes de disco no Event Log
$events = @()
try {
    $events = Get-WinEvent -FilterHashtable @{LogName='System'; Id=@(7, 11, 15, 51, 55, 129, 153)} -MaxEvents 50 | Select-Object TimeCreated,Id,ProviderName,LevelDisplayName,Message
} catch {}

# Performance: fila de disco e tempo de disco (se disponíveis)
$perf = @{}
try {
    $q = Get-Counter -Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length' -ErrorAction Stop
    $t = Get-Counter -Counter '\PhysicalDisk(_Total)\% Disk Time' -ErrorAction Stop
    $perf = @{ QueueLength = [math]::Round($q.CounterSamples.CookedValue,2); DiskTime = [math]::Round($t.CounterSamples.CookedValue,2) }
} catch { $perf = @{ note = 'Perf counters not available' } }

# Espaço
$totalGB = [math]::Round($drive.Used/1GB + $drive.Free/1GB, 2)
$freeGB  = [math]::Round($drive.Free/1GB, 2)
$usedGB  = [math]::Round($drive.Used/1GB, 2)
$freePct = if ($totalGB -gt 0) { [math]::Round(($freeGB/$totalGB)*100, 2) } else { 0 }

# Temperatura (se suportado via WMI - nem todos expõem)
$temperatureC = $null
try {
    $temp = Get-CimInstance -Namespace root\wmi -Class MSStorageDriver_FailurePredictData -ErrorAction Stop | Select-Object -First 1
    # Não trivial extrair temperatura real; muitos drivers não fornecem.
} catch {}

# Status final
$status = @{
    timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    drive = "$DriveLetter:"
    totalGB = $totalGB
    usedGB = $usedGB
    freeGB = $freeGB
    freePct = $freePct
    smart = $smartStatus
    perf = $perf
    recentDiskEvents = ($events | Select-Object -First 10)
}

# Critérios simples de alerta
$alerts = @()
if ($freePct -lt 15) { $alerts += "Espaço livre abaixo de 15% ($freePct%)" }
if ($smartStatus -and $smartStatus.PredictFailure) { $alerts += "SMART indica falha iminente" }
$status.alerts = $alerts
$status.health = if ($alerts.Count -eq 0) { 'OK' } elseif ($alerts.Count -le 2) { 'WARN' } else { 'ALERT' }

# Output
$status | ConvertTo-Json -Depth 5 | Set-Content -Path $OutJson -Encoding UTF8
Write-Color "Health salvo em $OutJson" 'Green'
if (-not $Quiet) { $status }
