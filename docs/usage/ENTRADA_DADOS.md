# Guia de Entrada de Dados (Repositórios)

Este guia mostra como cadastrar e validar repositórios para backup, de forma segura e eficiente, usando duas formas:

- Configuração direta no `scripts/config.json`
- Via API (recomendado para ambientes em HD e em rede)

---

## 1) Pré-requisitos e boas práticas

- Tenha o caminho de rede (UNC) correto: \\servidor\\compartilhamento\\pasta
- Garanta permissões de leitura no caminho de origem
- Evite caminhos com mapeamentos de unidade (Z:\\) quando o serviço for executado como outra conta
- Teste conectividade e credenciais antes de cadastrar

### Testes rápidos

```powershell
# O caminho existe?
Test-Path "\\\\servidor\\compartilhamento\\repo1"

# Ver conteúdo (primeiros itens)
Get-ChildItem "\\\\servidor\\compartilhamento\\repo1" -Force | Select-Object -First 5

# Salvar credenciais no Windows Credential Manager (se necessário)
cmdkey /add:servidor /user:DOMINIO\usuario /pass:senha
cmdkey /list
```

---

## 2) Cadastro via arquivo (config.json)

Arquivo: `D:\scripts\config.json`

Campos principais:
- `name`: identificador curto, sem espaços (ex: `projeto-web`)
- `source`: caminho UNC de origem
- `description`: descrição curta
- `enabled`: habilita/desabilita temporariamente o repo

Exemplo de configuração com 3 repositórios:

```json
{
  "repositories": [
    {
      "name": "projeto-web",
      "source": "\\\\192.168.1.10\\projetos\\web",
      "description": "Aplicação web principal",
      "enabled": true
    },
    {
      "name": "relatorios",
      "source": "\\\\fileserver\\departamento\\relatorios",
      "description": "Planilhas e relatórios",
      "enabled": true
    },
    {
      "name": "bd-dumps",
      "source": "\\\\dbserver\\exports\\dumps",
      "description": "Dumps do banco de dados",
      "enabled": true
    }
  ],
  "settings": {
    "compression": "zip",
    "keepBackups": 5,
    "createChecksum": true,
    "logLevel": "Info"
  }
}
```

Validação após editar:
```powershell
# Validar JSON
Get-Content D:\scripts\config.json -Raw | ConvertFrom-Json | Out-Null; if ($?) { "OK" } else { "Erro" }

# Testar caminhos declarados
($cfg = Get-Content D:\scripts\config.json -Raw | ConvertFrom-Json).repositories | ForEach-Object {
  $ok = Test-Path $_.source
  "[$($ok ? 'OK' : 'ERRO')] $($_.name) => $($_.source)"
}
```

---

## 3) Cadastro via API (Recomendado)

Vantagens: sem editar arquivo manualmente, validação mais simples, integra com outros sistemas.

1. Inicie o servidor API:
```powershell
cd D:\scripts
.\api-server.ps1
```

2. Use o cliente CLI para adicionar um repositório:
```powershell
.\api-client.ps1 add
# Será solicitado: nome, caminho UNC e descrição
```

3. Listar repositórios cadastrados:
```powershell
.\api-client.ps1 repos
```

4. Opcional: chamada direta (sem CLI), com cURL ou PowerShell

PowerShell:
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/repositories" -Method POST -ContentType "application/json" -Body (@{
  name = "projeto-web"
  source = "\\\\192.168.1.10\\projetos\\web"
  description = "Aplicação web principal"
  enabled = $true
} | ConvertTo-Json)
```

cURL:
```bash
curl -X POST http://localhost:8080/api/repositories \
  -H "Content-Type: application/json" \
  -d '{"name":"projeto-web","source":"\\\\192.168.1.10\\projetos\\web","description":"Aplicação web principal","enabled":true}'
```

---

## 4) Checklist de validação

- [ ] `Test-Path` do caminho retorna True
- [ ] Tamanho dos dados cabe no HD de backup disponível
- [ ] Permissões de leitura confirmadas
- [ ] Nome sem espaços e caracteres especiais
- [ ] Campo `enabled` = true
- [ ] Configuração JSON válida

---

## 5) Dicas de performance (HD)

- Priorize backups fora do horário comercial
- Evite múltiplos backups simultâneos no mesmo disco
- Habilite checksums (útil para integridade, baixo custo)
- Avalie exclusões (logs temporários) via subpastas separadas
- Prefira caminhos UNC a unidades mapeadas

---

## 6) Exemplos rápidos

Cadastrar 3 repositórios editando o arquivo:
```powershell
notepad D:\scripts\config.json
```

Rodar backup de todos:
```powershell
cd D:\scripts
.\backup.ps1
```

Via API (todos):
```powershell
.\api-client.ps1 backup all
```

Listar backups de um repositório:
```powershell
.\api-client.ps1 list projeto-web
```

---

Precisa de um modelo? Veja: `docs/usage/repos-template.json`.
