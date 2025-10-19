# Envio automático de backup para servidor remoto (FastAPI)

## Como funciona

Após a execução do backup local, o sistema pode enviar automaticamente o arquivo ZIP gerado para um servidor remoto Linux rodando FastAPI, usando o script `upload-backup.ps1`.

### Pré-requisitos
- Servidor FastAPI configurado e rodando (porta 9101, endpoint `/upload`)
- Token de autenticação válido
- Parâmetros de API configurados no `config.json` (apiUrl, apiToken)

## Parâmetros necessários
- Caminho do arquivo ZIP gerado
- URL do endpoint da API
- Token de autenticação
- Nome do repositório

## Exemplo de integração automática
O script `backup.ps1` já está configurado para, ao final de cada backup, chamar automaticamente o `upload-backup.ps1` se as chaves `apiUrl` e `apiToken` estiverem presentes em `config.json`:

```powershell
# Trecho do backup.ps1
$apiUrl = $config.settings.apiUrl
$apiToken = $config.settings.apiToken
if ($apiUrl -and $apiToken) {
    $uploadScript = Join-Path $scriptPath 'upload-backup.ps1'
    $uploadParams = @{
        FilePath = $backupFilePath
        ApiUrl = $apiUrl
        Token = $apiToken
        Repository = $repo.name
    }
    & $uploadScript @uploadParams
}
```

## Observações
- O upload é feito apenas se as chaves de API estiverem presentes.
- Logs de sucesso ou erro são registrados automaticamente.
- O envio é feito para cada repositório individualmente, logo após a criação do ZIP.

## Segurança
- O token nunca deve ser compartilhado publicamente.
- O endpoint deve ser protegido e acessível apenas por hosts autorizados.
