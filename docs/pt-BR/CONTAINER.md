# Execução em Windows Container (Docker)

Este projeto pode ser executado em container Windows para facilitar deploy e padronização do ambiente.

## Pré-requisitos
- Windows 10/11 Pro, Enterprise ou Windows Server com suporte a containers
- Docker Desktop ou Docker Engine configurado para Windows containers

## Build da imagem

Abra o terminal na raiz do projeto e execute:

```powershell
# Build da imagem
docker build -t backup-api-win .
```

## Rodando o container

```powershell
# Executa o container, mapeando a porta 8080
# (ajuste caminhos conforme necessário para persistência)
docker run -d -p 8080:8080 --name backup-api-win \
  -v D:\backup-logs:C:\backup\logs \
  -v D:\backup-repos:C:\backup\repos \
  -v D:\backup-status:C:\backup\status \
  backup-api-win
```

- Os volumes permitem persistir backups, logs e status fora do container.
- Para acessar shares de rede, o container deve rodar com permissões adequadas e a conta do host deve ter acesso.

## Testando

Acesse a API em http://localhost:8080/api/status

## Observações
- O container é baseado em Windows Server Core (ltsc2022).
- Scripts agendados (Task Scheduler) não rodam automaticamente em container, mas podem ser executados via `docker exec` ou usando ferramentas externas.
- Para uso avançado (autenticação, SMTP, etc), ajuste o Dockerfile e variáveis conforme necessário.
