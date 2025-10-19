# Guia de Uso - Sistema de Backup (pt-BR)

## 🚀 Início Rápido

### 1️⃣ Configurar Repositórios

Edite `scripts/config.json` e configure os caminhos dos repositórios:

```json
{
  "repositories": [
    {
      "name": "repo1",
      "source": "\\\\192.168.1.100\\projeto1",
      "description": "Projeto principal",
      "enabled": true
    },
    {
      "name": "repo2",
      "source": "\\\\192.168.1.100\\projeto2",
      "description": "Segundo projeto",
      "enabled": true
    }
  ],
  "settings": {
    "compression": "Optimal",
    "keepBackups": 5,
    "createChecksum": true,
    "logLevel": "Info",
    "apiUrl": "http://192.168.1.100:9101/upload",
    "apiToken": "mt5-backup-secure-token-2025"
  }
}
```

### 2️⃣ Executar Backup Manual

```powershell
# Vá para a pasta scripts
cd D:\scripts

# Execute o backup
.\backup.ps1
```

### 3️⃣ Listar Backups

```powershell
# Listar todos os backups de um repositório
.\restore.ps1 -RepoName "repo1" -ListBackups
```

### 4️⃣ Restaurar Backup

```powershell
# Restaurar o backup mais recente
.\restore.ps1 -RepoName "repo1" -DestinationPath "C:\Restaurado"

# Restaurar um backup específico
.\restore.ps1 -RepoName "repo1" -BackupFile "repo1_20251019_143000.zip" -DestinationPath "C:\Restaurado"

# Verificar integridade antes de restaurar
.\restore.ps1 -RepoName "repo1" -VerifyChecksum
```

## 📋 Comandos Úteis

### Backup

```powershell
# Backup padrão
.\backup.ps1

# Com saída detalhada
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

## 🤖 Automação

### Agendar Backup Diário (Agendador de Tarefas)

1. Abra o **Agendador de Tarefas** do Windows
2. Clique em **Criar Tarefa Básica**
3. Nome: `Backup Automático Diário`
4. Gatilho: **Diariamente** às 02:00
5. Ação: **Iniciar um programa**
   - Programa: `powershell.exe`
   - Argumentos: `-ExecutionPolicy Bypass -File "D:\scripts\backup.ps1"`
6. Concluir

### Agendar via PowerShell

```powershell
# Criar tarefa agendada
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\scripts\backup.ps1'"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -TaskName "BackupAutomatico" -Action $action -Trigger $trigger -Description "Backup automático diário"
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

## ⚙️ Configurações Avançadas

### config.json - Opções

```json
{
  "settings": {
    "compression": "Optimal",        // Tipo de compressão: Optimal, Fastest, NoCompression
    "keepBackups": 5,                // Número de backups a manter
    "createChecksum": true,          // Criar checksum SHA256
    "logLevel": "Info",              // Nível de log (Info, Warning, Error)
    "apiUrl": "http://192.168.1.100:9101/upload",  // Opcional: Endpoint FastAPI remoto
    "apiToken": "seu-token-seguro"   // Opcional: Token Bearer para API
  }
}
```

**Nota:** Se `apiUrl` e `apiToken` estiverem configurados, os backups serão enviados automaticamente para o servidor remoto após a criação.

## 🌐 Acesso à Rede

### Mapear Unidade de Rede (Opcional)

```powershell
# Mapear unidade Z:
net use Z: \\servidor\compartilhamento /user:DOMINIO\usuario senha

# Usar no config.json
"source": "Z:\\pasta-projeto"
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

# Listar credenciais salvas
cmdkey /list
```

## 🔄 Envio Automático para Servidor Remoto

O sistema suporta envio automático de backups para um servidor Linux rodando FastAPI. Veja a documentação completa em [UPLOAD_BACKUP.md](UPLOAD_BACKUP.md).

### Configuração Rápida

1. Configure o servidor FastAPI no Linux (veja `Implementaçãobackup.md`)
2. Adicione `apiUrl` e `apiToken` no `config.json`
3. Execute o backup normalmente - o envio será automático

```json
{
  "settings": {
    "apiUrl": "http://192.168.1.100:9101/upload",
    "apiToken": "mt5-backup-secure-token-2025"
  }
}
```

## ❓ Solução de Problemas

### Erro: "Caminho de origem não encontrado"

**Solução:**
- Verifique se o caminho está correto no `config.json`
- Teste acesso manual: `Test-Path "\\servidor\compartilhamento"`
- Verifique credenciais de rede

### Erro: "Acesso Negado"

**Solução:**
- Execute PowerShell como Administrador
- Verifique permissões da pasta de destino
- Verifique credenciais de rede

### Backup muito grande

**Solução:**
- Adicione exclusões no `.gitignore` local
- Use compressão máxima
- Considere backup incremental

### Script não executa

**Solução:**
```powershell
# Permitir execução de scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Falha no envio para servidor remoto

**Solução:**
- Verifique se o servidor FastAPI está rodando: `curl http://192.168.1.100:9101/health`
- Confirme que o token está correto
- Verifique conectividade de rede
- Consulte logs: `D:\logs\backup_*.log`

## 📈 Boas Práticas

1. ✅ Execute backups diários automaticamente
2. ✅ Mantenha pelo menos 5 versões de backup
3. ✅ Verifique logs regularmente
4. ✅ Teste restauração periodicamente
5. ✅ Use checksum para verificar integridade
6. ✅ Armazene backups em local diferente (nuvem/outro servidor)
7. ✅ Configure envio automático para servidor remoto
8. ✅ Documente mudanças no `config.json`

## 🔒 Segurança

- Não commite senhas no Git
- Use o Gerenciador de Credenciais do Windows
- Restrinja acesso à pasta de backup
- Proteja o token da API remota
- Considere criptografar backups sensíveis
- Use HTTPS para comunicação com API remota (em produção)
