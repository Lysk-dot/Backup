# Padrão de Commits - Conventional Commits

Este projeto segue o padrão **Conventional Commits** para mensagens de commit.

## 📋 Formato

```
<tipo>: <descrição>

[corpo opcional]

[rodapé opcional]
```

## 🏷️ Tipos de Commit

| Tipo       | Descrição                                          | Exemplo                                    |
|------------|----------------------------------------------------|--------------------------------------------|
| `feat`     | Nova funcionalidade                                | `feat: Add automated backup rotation`      |
| `fix`      | Correção de bug                                    | `fix: Correct network path validation`     |
| `docs`     | Alterações na documentação                         | `docs: Update README with examples`        |
| `style`    | Formatação, espaços, ponto e vírgula, etc          | `style: Format PowerShell scripts`         |
| `refactor` | Refatoração de código (sem alterar funcionalidade) | `refactor: Simplify backup logic`          |
| `perf`     | Melhoria de performance                            | `perf: Optimize file compression`          |
| `test`     | Adição ou correção de testes                       | `test: Add unit tests for restore script`  |
| `build`    | Mudanças no build ou dependências                  | `build: Update PowerShell version`         |
| `ci`       | Mudanças em CI/CD                                  | `ci: Add GitHub Actions workflow`          |
| `chore`    | Tarefas de manutenção                              | `chore: Update .gitignore`                 |
| `revert`   | Reverter commit anterior                           | `revert: Revert "feat: Add feature X"`     |

## 🚀 Como Usar o Script de Commit Automático

### Modo Interativo (Recomendado)

```powershell
cd D:\scripts
.\commit.ps1
```

O script vai:
1. Detectar arquivos modificados
2. Sugerir tipo de commit baseado nas mudanças
3. Gerar sugestões de mensagem
4. Criar commit padronizado

### Modo Rápido

```powershell
# Com tipo específico
.\commit.ps1 -Type feat

# Com mensagem customizada
.\commit.ps1 -Type fix -Message "Corrige erro no backup de rede"

# Com push automático
.\commit.ps1 -Type docs -Push

# Modo totalmente automático
.\commit.ps1 -Auto -Push
```

## 📝 Exemplos de Mensagens

### ✅ Bom

```
feat: Add support for three repositories

- Updated config.json to support repo3
- Modified backup script to handle multiple repos
- Updated documentation
```

```
fix: Correct network path validation in backup script

The script was failing when using UNC paths with special characters.
Now properly escapes and validates network paths.
```

```
docs: Update README with copyright information

- Added LICENSE file
- Updated author information
- Added contact details
```

### ❌ Evitar

```
update files
```

```
fixed stuff
```

```
WIP
```

## 🎯 Regras

1. **Tipo em minúsculas**: `feat`, não `Feat` ou `FEAT`
2. **Descrição clara**: Explique O QUE foi mudado, não COMO
3. **Primeira linha curta**: Máximo 72 caracteres
4. **Imperativo**: "Add feature" não "Added feature" ou "Adds feature"
5. **Sem ponto final**: Na descrição da primeira linha
6. **Corpo opcional**: Use para explicar O PORQUÊ e contexto adicional

## 🔄 Workflow Recomendado

```powershell
# 1. Fazer alterações nos arquivos
# 2. Executar script de commit
cd D:\scripts
.\commit.ps1

# 3. O script vai guiar você pelo processo
# 4. Confirmar e fazer push
```

## 🛠️ Aliases Úteis (Opcional)

Adicione ao seu PowerShell profile (`$PROFILE`):

```powershell
# Commit rápido
function gac { Set-Location D:\scripts; .\commit.ps1 }

# Commit com push
function gacp { Set-Location D:\scripts; .\commit.ps1 -Push }

# Commit automático
function gaca { Set-Location D:\scripts; .\commit.ps1 -Auto }
```

Recarregar profile:
```powershell
. $PROFILE
```

Usar:
```powershell
gac      # Git auto commit
gacp     # Git auto commit and push
gaca     # Git auto commit automático
```

## 📊 Benefícios

- ✅ Histórico de commits limpo e organizado
- ✅ Fácil navegação no log do Git
- ✅ Geração automática de CHANGELOG
- ✅ Melhor colaboração em equipe
- ✅ Commits semânticos facilitam automação
- ✅ Identificação rápida do tipo de mudança

## 🔍 Visualizar Commits

```powershell
# Log formatado
git log --oneline --graph --decorate

# Log com filtro por tipo
git log --oneline --grep="^feat:"
git log --oneline --grep="^fix:"

# Últimos 10 commits
git log --oneline -10
```

## 📚 Referências

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
