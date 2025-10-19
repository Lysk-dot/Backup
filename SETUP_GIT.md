# 🔧 Configuração do Git e GitHub

## Passo 1: Configure suas credenciais Git

```powershell
# Substitua "SEU_NOME" pelo seu nome ou username do GitHub
git config --global user.name "SEU_NOME"

# Substitua "SEU_EMAIL@exemplo.com" pelo email cadastrado no GitHub
git config --global user.email "SEU_EMAIL@exemplo.com"
```

## Passo 2: Configure o token de acesso

```powershell
# Armazena suas credenciais no Git Credential Manager
git config --global credential.helper manager-core
```

## Passo 3: Inicialize o repositório (se necessário)

```powershell
# Inicializar repositório Git na pasta atual
git init

# Adicionar todos os arquivos
git add .

# Fazer o primeiro commit
git commit -m "Initial commit"
```

## Passo 4: Conectar ao repositório remoto do GitHub

```powershell
# Substitua SEU_USUARIO e SEU_REPOSITORIO
git remote add origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git

# Verificar o remote
git remote -v
```

## Passo 5: Enviar para o GitHub (Push)

```powershell
# Primeira vez (criar a branch main no remoto)
git branch -M main
git push -u origin main
```

**⚠️ IMPORTANTE:** Quando executar o `git push`, uma janela vai abrir pedindo suas credenciais:
- **Username:** Seu nome de usuário do GitHub
- **Password:** **COLE SEU TOKEN AQUI** (não a senha da conta!)

O Git Credential Manager vai salvar o token para os próximos usos.

---

## 📋 Comandos Rápidos (copie e cole, ajustando seus dados):

```powershell
git config --global user.name "SEU_NOME"
git config --global user.email "SEU_EMAIL@exemplo.com"
git config --global credential.helper manager-core
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
git branch -M main
git push -u origin main
```

Quando pedir credenciais no push:
- Username: seu_usuario_github
- Password: **COLE_SEU_TOKEN_AQUI**

---

## ℹ️ Informações Adicionais

### Ver configurações atuais:
```powershell
git config --global --list
```

### Remover remote (se precisar reconfigurar):
```powershell
git remote remove origin
```

### Cache de credenciais alternativo (cache temporário):
```powershell
git config --global credential.helper cache
```
