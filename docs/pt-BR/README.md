# Documentação (pt-BR)

> ⚠️ **Compatibilidade:** Este projeto é planejado e suportado apenas para Windows. Não há garantia de funcionamento ou suporte em outros sistemas operacionais.
> 
> 📚 **Licença:** Este projeto é destinado apenas para uso pessoal ou de estudo. Não utilize para fins comerciais.

Este diretório reúne toda a documentação do projeto de Backup.

## Índice

- Entrada de dados (cadastrar repositórios): [../usage/ENTRADA_DADOS.md](../usage/ENTRADA_DADOS.md)
- Validação de fontes (rede e acesso): [../../scripts/validate-sources.ps1](../../scripts/validate-sources.ps1)
- Template de repositórios: [../usage/repos-template.json](../usage/repos-template.json)
- Monitoramento de saúde do disco: [../usage/HEALTH_MONITORING.md](../usage/HEALTH_MONITORING.md)
- Coleção Postman da API: [../api/postman_collection.json](../api/postman_collection.json)
- Visão geral da API: [../api/README.md](../api/README.md)
- Guia de uso (execução e restauração): [GUIA_USO.md](GUIA_USO.md)
- Envio automático para servidor remoto: [UPLOAD_BACKUP.md](UPLOAD_BACKUP.md)
- Configuração inicial do Git: [../setup/SETUP_GIT.md](../setup/SETUP_GIT.md)
- Padrão de commits (Conventional Commits): [../commits/GUIDELINES.md](../commits/GUIDELINES.md)
- Licença: [../legal/LICENSE](../legal/LICENSE)


### Execução em Container

- Guia: [CONTAINER.md](CONTAINER.md)

### Qualidade e Contribuição

- CI (PSScriptAnalyzer + Pester): ../../.github/workflows/powershell-ci.yml
- Testes: pasta [../../tests](../../tests)
- Schema do config: [../usage/config.schema.json](../usage/config.schema.json)
- Contribuição: [../../CONTRIBUTING.md](../../CONTRIBUTING.md)
- Segurança: [../../SECURITY.md](../../SECURITY.md)
- Código de Conduta: [../../CODE_OF_CONDUCT.md](../../CODE_OF_CONDUCT.md)
