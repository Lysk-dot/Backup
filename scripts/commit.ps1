# ========================================
# Script de Commit Automatizado
# ========================================
# Autor: Felipe Petracco Carmo
# Email: kuramopr@gmail.com
# Data: 19/10/2025
# 
# Copyright (c) 2025 Felipe Petracco Carmo
# Todos os direitos reservados.
# 
# Este software é fornecido "como esta", sem garantias
# de qualquer tipo, expressas ou implicitas.
# ========================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert')]
    [string]$Type,
    
    [Parameter(Mandatory=$false)]
    [string]$Message,
    
    [switch]$Push,
    [switch]$Auto
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath

function Write-ColorOutput {
    param([string]$Text, [ConsoleColor]$Color = 'White')
    Write-Host $Text -ForegroundColor $Color
}

Write-ColorOutput "`n========================================" -Color Cyan
Write-ColorOutput "    Git Commit Automatizado" -Color Cyan
Write-ColorOutput "========================================`n" -Color Cyan

if (-not (Test-Path (Join-Path $rootPath ".git"))) {
    Write-ColorOutput "ERRO: Nao e um repositorio Git!" -Color Red
    exit 1
}

Set-Location $rootPath

$status = git status --porcelain
if (-not $status) {
    Write-ColorOutput "Nenhuma alteracao para commitar" -Color Green
    exit 0
}

Write-ColorOutput "Arquivos modificados:" -Color Yellow
git status --short
Write-ColorOutput "`n----------------------------------------`n" -Color Gray

Write-ColorOutput "Adicionando arquivos..." -Color Cyan
git add .

$modifiedFiles = git diff --cached --name-only
$addedFiles = git diff --cached --diff-filter=A --name-only
$deletedFiles = git diff --cached --diff-filter=D --name-only

$scripts = @($modifiedFiles | Where-Object { $_ -match '\.(ps1|sh|bat|cmd)$' }).Count
$configs = @($modifiedFiles | Where-Object { $_ -match '\.(json|yml|yaml|xml|ini|config)$' }).Count
$docs = @($modifiedFiles | Where-Object { $_ -match '\.(md|txt|pdf|doc)$' }).Count

if (-not $Type -and $Auto) {
    if ($addedFiles.Count -gt 0 -and $deletedFiles.Count -eq 0) {
        $Type = 'feat'
    } elseif ($deletedFiles.Count -gt 0) {
        $Type = 'chore'
    } elseif ($docs -gt 0 -and $scripts -eq 0) {
        $Type = 'docs'
    } elseif ($configs -gt 0) {
        $Type = 'chore'
    } else {
        $Type = 'fix'
    }
}

if (-not $Type) {
    Write-ColorOutput "Selecione o tipo de commit:" -Color Cyan
    Write-ColorOutput "  1. feat     - Nova funcionalidade" -Color White
    Write-ColorOutput "  2. fix      - Correcao de bug" -Color White
    Write-ColorOutput "  3. docs     - Documentacao" -Color White
    Write-ColorOutput "  4. style    - Formatacao/estilo" -Color White
    Write-ColorOutput "  5. refactor - Refatoracao de codigo" -Color White
    Write-ColorOutput "  6. perf     - Melhoria de performance" -Color White
    Write-ColorOutput "  7. test     - Testes" -Color White
    Write-ColorOutput "  8. build    - Build/dependencias" -Color White
    Write-ColorOutput "  9. ci       - CI/CD" -Color White
    Write-ColorOutput " 10. chore    - Manutencao/tarefas" -Color White
    Write-ColorOutput " 11. revert   - Reverter commit" -Color White
    
    $choice = Read-Host "`nEscolha (1-11)"
    
    $Type = switch ($choice) {
        "1"  { "feat" }
        "2"  { "fix" }
        "3"  { "docs" }
        "4"  { "style" }
        "5"  { "refactor" }
        "6"  { "perf" }
        "7"  { "test" }
        "8"  { "build" }
        "9"  { "ci" }
        "10" { "chore" }
        "11" { "revert" }
        default { "chore" }
    }
}

if (-not $Message) {
    $suggestions = @()
    
    if ($addedFiles.Count -gt 0) {
        if ($addedFiles.Count -eq 1) {
            $fileName = Split-Path $addedFiles[0] -Leaf
            $suggestions += "Add $fileName"
        } else {
            $suggestions += "Add $($addedFiles.Count) new files"
        }
    }
    
    if ($deletedFiles.Count -gt 0) {
        if ($deletedFiles.Count -eq 1) {
            $fileName = Split-Path $deletedFiles[0] -Leaf
            $suggestions += "Remove $fileName"
        } else {
            $suggestions += "Remove $($deletedFiles.Count) files"
        }
    }
    
    if ($modifiedFiles.Count -gt 0 -and $addedFiles.Count -eq 0 -and $deletedFiles.Count -eq 0) {
        if ($scripts -gt 0) { $suggestions += "Update backup scripts" }
        if ($configs -gt 0) { $suggestions += "Update configuration files" }
        if ($docs -gt 0) { $suggestions += "Update documentation" }
        
        if ($suggestions.Count -eq 0) {
            if ($modifiedFiles.Count -eq 1) {
                $fileName = Split-Path $modifiedFiles[0] -Leaf
                $suggestions += "Update $fileName"
            } else {
                $suggestions += "Update $($modifiedFiles.Count) files"
            }
        }
    }
    
    Write-ColorOutput "`nSugestoes de mensagem:" -Color Yellow
    for ($i = 0; $i -lt $suggestions.Count; $i++) {
        Write-ColorOutput "  $($i + 1). $($suggestions[$i])" -Color White
    }
    Write-ColorOutput "  0. Mensagem personalizada" -Color Gray
    
    $msgChoice = Read-Host "`nEscolha a mensagem (0-$($suggestions.Count))"
    
    if ($msgChoice -eq "0") {
        $Message = Read-Host "Digite a mensagem do commit"
    } elseif ($msgChoice -match '^\d+$' -and [int]$msgChoice -le $suggestions.Count -and [int]$msgChoice -gt 0) {
        $Message = $suggestions[[int]$msgChoice - 1]
    } else {
        $Message = $suggestions[0]
    }
}

$commitMessage = "$Type`: $Message"

$commitBody = @()
if ($addedFiles.Count -gt 0) {
    $commitBody += "`nAdded files:"
    $addedFiles | ForEach-Object { $commitBody += "- $_" }
}

if ($modifiedFiles.Count -gt 0 -and $addedFiles.Count -eq 0) {
    $commitBody += "`nModified files:"
    $modifiedFiles | Select-Object -First 10 | ForEach-Object { $commitBody += "- $_" }
    if ($modifiedFiles.Count -gt 10) {
        $commitBody += "... and $($modifiedFiles.Count - 10) more files"
    }
}

if ($deletedFiles.Count -gt 0) {
    $commitBody += "`nDeleted files:"
    $deletedFiles | ForEach-Object { $commitBody += "- $_" }
}

$fullMessage = $commitMessage
if ($commitBody.Count -gt 0) {
    $fullMessage += "`n" + ($commitBody -join "`n")
}

Write-ColorOutput "`n========================================" -Color Cyan
Write-ColorOutput "Preview do Commit:" -Color Cyan
Write-ColorOutput "========================================" -Color Cyan
Write-ColorOutput $fullMessage -Color White
Write-ColorOutput "========================================`n" -Color Cyan

$confirm = Read-Host "Confirmar commit? (S/n)"
if ($confirm -eq 'n' -or $confirm -eq 'N') {
    Write-ColorOutput "Commit cancelado" -Color Yellow
    exit 0
}

Write-ColorOutput "`nCriando commit..." -Color Cyan
git commit -m $fullMessage

if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput "Commit criado com sucesso!" -Color Green
    
    $commitHash = git rev-parse --short HEAD
    Write-ColorOutput "  Hash: $commitHash" -Color Gray
    
    if ($Push) {
        Write-ColorOutput "`nEnviando para o repositorio remoto..." -Color Cyan
        git push
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Push realizado com sucesso!" -Color Green
        } else {
            Write-ColorOutput "Erro ao fazer push" -Color Red
            exit 1
        }
    } else {
        Write-ColorOutput "`nDica: Use -Push para enviar automaticamente" -Color Gray
    }
} else {
    Write-ColorOutput "Erro ao criar commit" -Color Red
    exit 1
}

Write-ColorOutput "`n========================================`n" -Color Cyan
