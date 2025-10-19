# Git and GitHub Setup

## Step 1: Configure your Git credentials

```powershell
# Replace "YOUR_NAME" with your name or GitHub username
git config --global user.name "YOUR_NAME"

# Replace "YOUR_EMAIL@example.com" with your GitHub email
git config --global user.email "YOUR_EMAIL@example.com"
```

## Step 2: Configure access token

```powershell
# Store your credentials in Git Credential Manager
git config --global credential.helper manager-core
```

## Step 3: Initialize the repository (if needed)

```powershell
# Initialize Git repository in the current folder
git init

# Add all files
git add .

# Make the first commit
git commit -m "Initial commit"
```

## Step 4: Connect to the remote GitHub repository

```powershell
# Replace YOUR_USER and YOUR_REPO
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git

# Check remote
git remote -v
```

## Step 5: Push to GitHub

```powershell
# First time (create main branch on remote)
git branch -M main
git push -u origin main
```

**⚠️ IMPORTANT:** When running `git push`, a window will open asking for your credentials:
- **Username:** Your GitHub username
- **Password:** **PASTE YOUR TOKEN HERE** (not your account password!)

Git Credential Manager will save the token for future use.

---

## 📝 Quick Commands (copy and paste, adjust your data):

```powershell
git config --global user.name "YOUR_NAME"
git config --global user.email "YOUR_EMAIL@example.com"
git config --global credential.helper manager-core
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git branch -M main
git push -u origin main
```

When prompted for credentials on push:
- Username: your_github_user
- Password: **PASTE_YOUR_TOKEN_HERE**

---

## ℹ️ Additional Information

### View current settings:
```powershell
git config --global --list
```

### Remove remote (if you need to reconfigure):
```powershell
git remote remove origin
```

### Alternative credential cache (temporary cache):
```powershell
git config --global credential.helper cache
```
