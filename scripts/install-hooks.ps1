# ========================================
# Script de Instalação de Git Hooks
# ========================================
# Autor: Felipe Petracco Carmo
# Email: kuramopr@gmail.com
# Data: 19/10/2025
# 
# Copyright (c) 2025 Felipe Petracco Carmo
# Todos os direitos reservados.
# ========================================

param(
    [switch]$Uninstall
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath
$hooksPath = Join-Path $rootPath ".git\hooks"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Git Hooks - Instalação" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verificar se é um repositório Git
if (-not (Test-Path (Join-Path $rootPath ".git"))) {
    Write-Host "ERRO: Não é um repositório Git!" -ForegroundColor Red
    exit 1
}

# Criar pasta de hooks se não existir
if (-not (Test-Path $hooksPath)) {
    New-Item -ItemType Directory -Path $hooksPath -Force | Out-Null
}

if ($Uninstall) {
    Write-Host "Removendo hooks..." -ForegroundColor Yellow
    
    $hookFile = Join-Path $hooksPath "commit-msg"
    if (Test-Path $hookFile) {
        Remove-Item $hookFile -Force
        Write-Host "✓ Hook commit-msg removido" -ForegroundColor Green
    }
    
    Write-Host "`nHooks desinstalados com sucesso!`n" -ForegroundColor Green
    exit 0
}

# Instalar hook commit-msg
Write-Host "Instalando hook commit-msg..." -ForegroundColor Cyan

$hookContent = @'
#!/bin/sh
# Git Hook - Commit Message Validation
# Valida mensagens de commit seguindo Conventional Commits

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Padrão Conventional Commits
pattern="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,}"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
    echo ""
    echo "ERRO: Mensagem de commit não segue o padrão Conventional Commits!"
    echo ""
    echo "Formato esperado:"
    echo "  <tipo>: <descrição>"
    echo ""
    echo "Tipos válidos:"
    echo "  feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
    echo ""
    echo "Exemplos:"
    echo "  feat: Add new backup feature"
    echo "  fix: Correct network path issue"
    echo "  docs: Update README"
    echo ""
    echo "Use o script commit.ps1 para commits automáticos padronizados!"
    echo ""
    exit 1
fi

exit 0
'@

$hookFile = Join-Path $hooksPath "commit-msg"
$hookContent | Out-File -FilePath $hookFile -Encoding ASCII -NoNewline

# Tornar executável (no Windows, isso é opcional)
if ($IsLinux -or $IsMacOS) {
    chmod +x $hookFile
}

Write-Host "✓ Hook commit-msg instalado" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Instalação concluída!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "O hook irá validar todas as mensagens de commit." -ForegroundColor White
Write-Host "Use: .\scripts\commit.ps1 para commits padronizados" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para desinstalar: .\scripts\install-hooks.ps1 -Uninstall" -ForegroundColor Gray
Write-Host ""
