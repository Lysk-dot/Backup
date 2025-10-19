# Documentação

Este diretório reúne toda a documentação do projeto de Backup.

## Índice

- Entrada de dados (cadastrar repositórios): [docs/usage/ENTRADA_DADOS.md](../docs/usage/ENTRADA_DADOS.md)
- Validação de fontes (rede e acesso): [scripts/validate-sources.ps1](../scripts/validate-sources.ps1)
- Template de repositórios: [docs/usage/repos-template.json](../docs/usage/repos-template.json)
- Monitoramento de saúde do disco: [docs/usage/HEALTH_MONITORING.md](../docs/usage/HEALTH_MONITORING.md)
- Coleção Postman da API: [docs/api/postman_collection.json](../docs/api/postman_collection.json)
- Visão geral da API: [docs/api/README.md](../docs/api/README.md)
- Guia de uso (execução e restauração): [docs/usage/GUIA_USO.md](../docs/usage/GUIA_USO.md)
- Configuração inicial do Git: [docs/setup/SETUP_GIT.md](../docs/setup/SETUP_GIT.md)
- Padrão de commits (Conventional Commits): [docs/commits/GUIDELINES.md](../docs/commits/GUIDELINES.md)
- Licença: [docs/legal/LICENSE](../docs/legal/LICENSE)
  
### Qualidade e Contribuição

- CI (PSScriptAnalyzer + Pester): .github/workflows/powershell-ci.yml
- Testes: pasta [tests/](../tests)
- Schema do config: [docs/usage/config.schema.json](../docs/usage/config.schema.json) (referenciado por scripts/config.json)
- Contribuição: [CONTRIBUTING.md](../CONTRIBUTING.md)
- Segurança: [SECURITY.md](../SECURITY.md)
- Código de Conduta: [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)

## Estrutura

```
docs/
├── api/
│   └── README.md
├── commits/
│   └── GUIDELINES.md
├── legal/
│   └── LICENSE
├── setup/
│   └── SETUP_GIT.md
└── usage/
    ├── ENTRADA_DADOS.md
    ├── GUIA_USO.md
    └── repos-template.json
```
