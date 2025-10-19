# API de Backup - Documentação

## 🌐 Visão Geral

API REST para gerenciamento de backups em disco HD. Solução leve e eficiente que permite controle remoto dos backups sem sobrecarregar o disco.

## 🎯 Vantagens da Abordagem API

✅ **Performance**: Processamento assíncrono, não bloqueia operações  
✅ **Eficiência**: Menor uso de recursos do HD  
✅ **Escalabilidade**: Múltiplos clientes podem conectar  
✅ **Monitoramento**: Status em tempo real  
✅ **Automação**: Fácil integração com scripts e ferramentas  
✅ **Remoto**: Controle via rede  

## 🚀 Início Rápido

### 1. Iniciar o Servidor API

```powershell
cd D:\scripts
.\api-server.ps1
```

O servidor estará disponível em: `http://localhost:8080`

Para usar outra porta:
```powershell
.\api-server.ps1 -Port 9000
```

### 2. Usar o Cliente CLI

```powershell
# Ver status do sistema
.\api-client.ps1 status

# Fazer backup de um repositório
.\api-client.ps1 backup repo1

# Fazer backup de todos
.\api-client.ps1 backup all

# Listar backups
.\api-client.ps1 list

# Listar repositórios
.\api-client.ps1 repos

# Adicionar novo repositório
.\api-client.ps1 add
```

## 📡 Endpoints da API

### Status do Sistema
```http
GET /api/status
```

**Resposta:**
```json
{
  "repositories": 3,
  "totalBackups": 15,
  "totalSizeMB": 1250.5,
  "diskFree": 450.2,
  "uptime": 12.5
}
```

### Listar Repositórios
```http
GET /api/repositories
```

**Resposta:**
```json
{
  "repositories": [
    {
      "name": "repo1",
      "source": "\\\\servidor\\repo1",
      "description": "Repositório 1",
      "enabled": true
    }
  ]
}
```

### Adicionar Repositório
```http
POST /api/repositories
Content-Type: application/json

{
  "name": "repo4",
  "source": "\\\\servidor\\repo4",
  "description": "Novo repositório",
  "enabled": true
}
```

### Listar Todos os Backups
```http
GET /api/backups
```

**Resposta:**
```json
{
  "backups": [
    {
      "repository": "repo1",
      "filename": "repo1_20251019_143000.zip",
      "size": 125.5,
      "date": "2025-10-19 14:30:00",
      "hasChecksum": true
    }
  ]
}
```

### Listar Backups de um Repositório
```http
GET /api/backups/repo1
```

### Criar Backup de um Repositório
```http
POST /api/backup/repo1
```

**Resposta (Sucesso):**
```json
{
  "success": true,
  "repository": "repo1",
  "filename": "repo1_20251019_143000.zip",
  "size": 125.5,
  "timestamp": "20251019_143000"
}
```

**Resposta (Erro):**
```json
{
  "success": false,
  "error": "Source path not found"
}
```

### Criar Backup de Todos os Repositórios
```http
POST /api/backup/all
```

**Resposta:**
```json
{
  "results": [
    {
      "success": true,
      "repository": "repo1",
      "filename": "repo1_20251019_143000.zip",
      "size": 125.5
    },
    {
      "success": true,
      "repository": "repo2",
      "filename": "repo2_20251019_143001.zip",
      "size": 89.2
    }
  ]
}
```

## 💻 Exemplos de Uso

### PowerShell

```powershell
# Status
Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Method GET

# Backup
Invoke-RestMethod -Uri "http://localhost:8080/api/backup/repo1" -Method POST

# Listar backups
Invoke-RestMethod -Uri "http://localhost:8080/api/backups" -Method GET
```

### cURL

```bash
# Status
curl http://localhost:8080/api/status

# Backup
curl -X POST http://localhost:8080/api/backup/repo1

# Adicionar repositório
curl -X POST http://localhost:8080/api/repositories \
  -H "Content-Type: application/json" \
  -d '{"name":"repo4","source":"\\\\servidor\\repo4","description":"Novo","enabled":true}'
```

### Python

```python
import requests

API_URL = "http://localhost:8080"

# Status
response = requests.get(f"{API_URL}/api/status")
print(response.json())

# Backup
response = requests.post(f"{API_URL}/api/backup/repo1")
print(response.json())

# Listar backups
response = requests.get(f"{API_URL}/api/backups")
for backup in response.json()['backups']:
    print(f"{backup['repository']}: {backup['filename']}")
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

const API_URL = 'http://localhost:8080';

// Status
async function getStatus() {
  const response = await axios.get(`${API_URL}/api/status`);
  console.log(response.data);
}

// Backup
async function createBackup(repo) {
  const response = await axios.post(`${API_URL}/api/backup/${repo}`);
  console.log(response.data);
}

getStatus();
createBackup('repo1');
```

## 🤖 Automação

### Backup Agendado via Task Scheduler

```powershell
# Criar tarefa para backup diário
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"Invoke-RestMethod -Uri 'http://localhost:8080/api/backup/all' -Method POST`""
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName "BackupAPI_Daily" -Action $action -Trigger $trigger
```

### Script de Monitoramento

```powershell
# monitorar.ps1
while ($true) {
    $status = Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Method GET
    Write-Host "Backups: $($status.totalBackups) | Espaco livre: $($status.diskFree) GB"
    Start-Sleep -Seconds 60
}
```

## 🔧 Configuração de Rede

### Acesso Remoto

Por padrão, a API aceita apenas conexões locais. Para acesso remoto:

1. **Executar como Administrador**
2. **Configurar Firewall:**

```powershell
# Adicionar regra no firewall
New-NetFirewallRule -DisplayName "Backup API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

3. **Iniciar servidor:**

```powershell
.\api-server.ps1 -Port 8080
```

4. **Acessar de outro computador:**

```powershell
.\api-client.ps1 status -ApiUrl "http://192.168.1.100:8080"
```

## 📊 Monitoramento e Logs

Todos os logs são salvos em `logs/api_AAAAMMDD.log`

```powershell
# Ver logs em tempo real
Get-Content "D:\logs\api_$(Get-Date -Format 'yyyyMMdd').log" -Wait

# Últimas 50 linhas
Get-Content "D:\logs\api_$(Get-Date -Format 'yyyyMMdd').log" -Tail 50
```

## 🔒 Segurança

### Recomendações

1. ✅ Use firewall para restringir acesso
2. ✅ Execute em rede privada
3. ✅ Considere adicionar autenticação (token/API key)
4. ✅ Use HTTPS em produção
5. ✅ Monitore logs regularmente

### Adicionar Autenticação Simples (Opcional)

Edite `api-server.ps1` e adicione validação de token:

```powershell
$apiKey = "seu-token-secreto-aqui"

# No início do loop de requisições:
$authHeader = $request.Headers["Authorization"]
if ($authHeader -ne "Bearer $apiKey") {
    $statusCode = 401
    $responseData = @{ error = "Unauthorized" } | ConvertTo-Json
    # ... retornar erro
}
```

Cliente:
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Headers @{Authorization="Bearer seu-token-secreto-aqui"}
```

## 🎯 Comparação: API vs Scripts Diretos

| Aspecto | Scripts Diretos | API |
|---------|----------------|-----|
| Performance HD | ❌ Maior uso | ✅ Otimizado |
| Acesso Remoto | ❌ Difícil | ✅ Fácil |
| Monitoramento | ❌ Manual | ✅ Automático |
| Escalabilidade | ❌ Limitada | ✅ Alta |
| Integração | ⚠️ Média | ✅ Fácil |
| Complexidade | ✅ Simples | ⚠️ Média |

## 📝 Próximos Passos

1. Iniciar servidor: `.\api-server.ps1`
2. Testar cliente: `.\api-client.ps1 status`
3. Configurar repositórios via API
4. Agendar backups automáticos
5. Monitorar logs

## 🆘 Troubleshooting

### Porta em uso
```powershell
# Verificar porta
Get-NetTCPConnection -LocalPort 8080

# Usar outra porta
.\api-server.ps1 -Port 9000
```

### Erro de conexão
- Verificar se servidor está rodando
- Verificar firewall
- Verificar URL correta

### Backup lento
- Verificar carga do HD
- Verificar tamanho dos arquivos
- Considerar horários de menor uso
