# Commit Guidelines - Conventional Commits

This project follows the **Conventional Commits** standard for commit messages.

## 📝 Format

```
<type>: <description>

[optional body]

[optional footer]
```

## 🏷️ Commit Types

| Type      | Description                                 | Example                                 |
|-----------|---------------------------------------------|-----------------------------------------|
| `feat`    | New feature                                 | `feat: Add automated backup rotation`   |
| `fix`     | Bug fix                                     | `fix: Correct network path validation`  |
| `docs`    | Documentation changes                       | `docs: Update README with examples`     |
| `style`   | Formatting, spaces, semicolons, etc         | `style: Format PowerShell scripts`      |
| `refactor`| Code refactor (no feature change)           | `refactor: Simplify backup logic`       |
| `perf`    | Performance improvement                     | `perf: Optimize file compression`       |
| `test`    | Add or fix tests                            | `test: Add unit tests for restore`      |
| `build`   | Build/dependency changes                    | `build: Update PowerShell version`      |
| `ci`      | CI/CD changes                               | `ci: Add GitHub Actions workflow`       |
| `chore`   | Maintenance tasks                           | `chore: Update .gitignore`              |
| `revert`  | Revert previous commit                      | `revert: Revert "feat: Add feature X"` |

## 🚀 How to Use the Commit Script

### Interactive Mode (Recommended)

```powershell
cd D:\scripts
./commit.ps1
```

The script will:
1. Detect modified files
2. Suggest commit type based on changes
3. Generate message suggestions
4. Create a standardized commit

### Quick Mode

```powershell
# With specific type
./commit.ps1 -Type feat

# With custom message
./commit.ps1 -Type fix -Message "Fix network backup error"

# With auto push
./commit.ps1 -Type docs -Push

# Fully automatic
./commit.ps1 -Auto -Push
```

## 📝 Good Message Examples

### ✅ Good

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

### ❌ Avoid

```
update files
```

```
fixed stuff
```

```
WIP
```

## 🎯 Rules

1. **Type in lowercase**: `feat`, not `Feat` or `FEAT`
2. **Clear description**: Explain WHAT changed, not HOW
3. **Short first line**: Max 72 characters
4. **Imperative**: "Add feature" not "Added feature" or "Adds feature"
5. **No period**: On the first line description
6. **Optional body**: Use to explain WHY and extra context

## 🔄 Recommended Workflow

```powershell
# 1. Make file changes
# 2. Run commit script
cd D:\scripts
./commit.ps1

# 3. The script will guide you
# 4. Confirm and push
```

## 🛠 Useful Aliases (Optional)

Add to your PowerShell profile (`$PROFILE`):

```powershell
# Quick commit
function gac { Set-Location D:\scripts; ./commit.ps1 }

# Commit with push
function gacp { Set-Location D:\scripts; ./commit.ps1 -Push }

# Auto commit
function gaca { Set-Location D:\scripts; ./commit.ps1 -Auto }
```

Reload profile:
```powershell
. $PROFILE
```

Use:
```powershell
gac      # Git auto commit
gacp     # Git auto commit and push
gaca     # Git auto commit automatic
```

## 📈 Benefits

- ✅ Clean, organized commit history
- ✅ Easy navigation in Git log
- ✅ Automatic CHANGELOG generation
- ✅ Better team collaboration
- ✅ Semantic commits enable automation
- ✅ Quick identification of change type

## 🔍 View Commits

```powershell
# Formatted log
git log --oneline --graph --decorate

# Log filtered by type
git log --oneline --grep="^feat:"
git log --oneline --grep="^fix:"

# Last 10 commits
git log --oneline -10
```

## 📚 References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)
