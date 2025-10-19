# Guia de Uso - Sistema de Backup

## 🚀 Início Rápido

### 1️⃣ Configurar Repositórios

Edite `scripts/config.json` e configure os caminhos dos seus repositórios:

```json
{
  "repositories": [
    {
      "name": "repo1",
      "source": "\\\\192.168.1.100\\projeto1",
      "description": "Projeto principal",
      "enabled": true
    }
  ]
}
```

### 2️⃣ Executar Backup Manual

```powershell
# Navegar até a pasta scripts
cd D:\scripts

# Executar backup
.\backup.ps1
```

### 3️⃣ Verificar Backups

```powershell
# Listar todos os backups de um repositório
.\restore.ps1 -RepoName "repo1" -ListBackups
```

### 4️⃣ Restaurar Backup

```powershell
# Restaurar o backup mais recente
.\restore.ps1 -RepoName "repo1" -DestinationPath "C:\Restaurados"

# Restaurar backup específico
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip" -DestinationPath "C:\Restaurados"

# Verificar integridade antes de restaurar
.\restore.ps1 -RepoName "repo1" -VerifyChecksum
```

## 📋 Comandos Úteis

### Backup

```powershell
# Backup padrão
.\backup.ps1

# Backup com saída detalhada
.\backup.ps1 -Verbose

# Forçar backup (ignorar verificações)
.\backup.ps1 -Force
```

### Restauração

```powershell
# Listar backups disponíveis
.\restore.ps1 -RepoName "repo1" -ListBackups

# Restaurar mais recente
.\restore.ps1 -RepoName "repo1"

# Restaurar específico
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip"

# Verificar checksum
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip" -VerifyChecksum

# Sobrescrever destino existente
.\restore.ps1 -RepoName "repo1" -DestinationPath "C:\Existe" -Force
```

## 🤖 Automatização

### Agendar Backup Diário (Agendador de Tarefas)

1. Abra o **Agendador de Tarefas** do Windows
2. Clique em **Criar Tarefa Básica**
3. Nome: `Backup Automático Diário`
4. Gatilho: **Diariamente** às 02:00
5. Ação: **Iniciar um programa**
   - Programa: `powershell.exe`
   - Argumentos: `-ExecutionPolicy Bypass -File "D:\scripts\backup.ps1"`
6. Finalizar

### Agendar via PowerShell

```powershell
# Criar tarefa agendada
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\scripts\backup.ps1'"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName "BackupAutomatico" -Action $action -Trigger $trigger -Description "Backup diário automático"
```

## 📊 Verificar Logs

```powershell
# Ver log de hoje
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log"

# Ver últimas 20 linhas
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log" -Tail 20

# Ver logs em tempo real
Get-Content "D:\logs\backup_$(Get-Date -Format 'yyyyMMdd').log" -Wait
```

## 🔧 Configurações Avançadas

### config.json - Opções

```json
{
  "settings": {
    "compression": "zip",           // Tipo de compressão
    "keepBackups": 5,                // Número de backups a manter
    "createChecksum": true,          // Criar checksum SHA256
    "logLevel": "Info"               // Nível de log (Info, Warning, Error)
  }
}
```

## 🌐 Acesso via Rede

### Mapear Unidade de Rede (Opcional)

```powershell
# Mapear unidade Z:
net use Z: \\servidor\compartilhamento /user:DOMINIO\usuario senha

# Usar no config.json
"source": "Z:\\pasta-do-projeto"
```

### Usar Caminho UNC Diretamente

```json
"source": "\\\\servidor\\compartilhamento\\pasta"
```

### Credenciais de Rede

Se precisar de credenciais:

```powershell
# Salvar credenciais
cmdkey /add:servidor /user:DOMINIO\usuario /pass:senha

# Verificar credenciais salvas
cmdkey /list
```

## ❓ Troubleshooting

### Erro: "Caminho de origem não encontrado"

**Solução:**
- Verifique se o caminho está correto no `config.json`
- Teste o acesso manual: `Test-Path "\\servidor\compartilhamento"`
- Verifique credenciais de rede

### Erro: "Access Denied"

**Solução:**
- Execute PowerShell como Administrador
- Verifique permissões da pasta de destino
- Verifique credenciais de rede

### Backup muito grande

**Solução:**
- Adicione exclusões no `.gitignore` local do repositório
- Use compressão máxima
- Considere backup incremental

### Script não executa

**Solução:**
```powershell
# Permitir execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📈 Boas Práticas

1. ✅ Execute backups diários automaticamente
2. ✅ Mantenha pelo menos 5 versões de backup
3. ✅ Verifique os logs regularmente
4. ✅ Teste a restauração periodicamente
5. ✅ Use checksum para verificar integridade
6. ✅ Armazene backups em local diferente (nuvem/outro servidor)
7. ✅ Documente as mudanças no `config.json`

## 🔐 Segurança

- Não commite senhas no Git
- Use credenciais do Windows Credential Manager
- Restrinja acesso à pasta de backups
- Considere criptografar backups sensíveis
