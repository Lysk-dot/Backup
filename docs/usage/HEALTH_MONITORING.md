# Monitoramento de Saúde do HD

Este guia explica como monitorar a saúde do disco (HD) onde os backups são gravados.

## O que é verificado

- Espaço livre (%) e em GB
- Status SMART (se disponível)
- Eventos recentes de disco (IDs: 7, 11, 15, 51, 55, 129, 153)
- Métricas de performance: Avg. Disk Queue Length e % Disk Time (se disponíveis)

## Scripts

- `scripts/health-check.ps1`: executa uma checagem e salva um snapshot JSON em `D:\status\health-status.json`
- `scripts/monitor-health.ps1`: roda em loop e registra logs periódicos em `D:\logs\health_monitor.log`

## Uso Rápido

```powershell
# Checagem única e mostrar resultado
cd D:\scripts
./health-check.ps1 -DriveLetter D -OutJson 'D:\status\health-status.json'

# Monitorar continuamente (a cada 5 min)
./monitor-health.ps1 -DriveLetter D -IntervalSeconds 300
```

## Integrando com a API

O servidor expõe o endpoint:

```http
GET /api/health
```

- Retorna o JSON de `D:\status\health-status.json`
- Se o arquivo não existir, tenta gerar uma checagem rápida

Exemplo (PowerShell):
```powershell
Invoke-RestMethod -Uri 'http://localhost:8080/api/health' -Method GET
```

## Agendar no Windows (Task Scheduler)

```powershell
# Rodar health-check a cada hora
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File 'D:\scripts\health-check.ps1'"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 60) -RepetitionDuration ([TimeSpan]::MaxValue)
Register-ScheduledTask -TaskName 'Backup_HealthCheck_Hourly' -Action $action -Trigger $trigger -RunLevel Highest

# Rodar o monitor contínuo no logon (opcional)
$action2 = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File 'D:\scripts\monitor-health.ps1'"
$trigger2 = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'Backup_HealthMonitor_OnLogon' -Action $action2 -Trigger $trigger2 -RunLevel Highest
```

## Alarmes e Sinais de Atenção

- Espaço livre < 15% (ajuste o limiar se necessário)
- SMART: `PredictFailure = true`
- Eventos de disco recorrentes (IDs citados)
- Fila de disco muito alta por longos períodos

## Dicas e Recomendações

- Execute monitoramento fora de horários críticos (reduz carga)
- Revise o log `D:\logs\health_monitor.log` semanalmente
- Considere alertar por e-mail ou Teams/Slack (próximo passo)
- Mantenha firmware/driver do storage atualizados
- Faça limpeza de backups antigos (já automatizado pelo sistema)

## Próximos Passos (Opcional)

- Envio de alertas por e-mail (SMTP) quando `health != OK`
- Envio de métricas para um sistema externo (Prometheus/Telegraf)
- Implementar endpoint `/api/alerts` com histórico
