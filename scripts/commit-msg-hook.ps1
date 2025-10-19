# ========================================
# Git Hook - Validação de Mensagem de Commit
# ========================================
# Autor: Felipe Petracco Carmo
# Email: kuramopr@gmail.com
# Data: 19/10/2025
# 
# Copyright (c) 2025 Felipe Petracco Carmo
# Todos os direitos reservados.
# ========================================

# Este hook valida mensagens de commit seguindo Conventional Commits

$commitMsgFile = $args[0]
$commitMsg = Get-Content $commitMsgFile -Raw

# Padrão Conventional Commits
$pattern = '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,}'

if ($commitMsg -notmatch $pattern) {
    Write-Host ""
    Write-Host "ERRO: Mensagem de commit não segue o padrão Conventional Commits!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Formato esperado:" -ForegroundColor Yellow
    Write-Host "  <tipo>: <descrição>" -ForegroundColor White
    Write-Host ""
    Write-Host "Tipos válidos:" -ForegroundColor Yellow
    Write-Host "  feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert" -ForegroundColor White
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Yellow
    Write-Host "  feat: Add new backup feature" -ForegroundColor Green
    Write-Host "  fix: Correct network path issue" -ForegroundColor Green
    Write-Host "  docs: Update README" -ForegroundColor Green
    Write-Host ""
    Write-Host "Use o script commit.ps1 para commits automáticos padronizados!" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

exit 0
