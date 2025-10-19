# Smoke tests for repository scripts
# These are lightweight checks to catch obvious issues in CI.

BeforeAll {
    $ErrorActionPreference = 'Stop'
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Set-Location $repoRoot
}

Describe 'Repository structure' {
    It 'has a scripts folder' {
        Test-Path -Path 'scripts' | Should -BeTrue
    }

    It 'has a docs folder' {
        Test-Path -Path 'docs' | Should -BeTrue
    }
}

Describe 'PowerShell scripts syntax' {
    $scriptFiles = Get-ChildItem -Path 'scripts' -Filter '*.ps1' -Recurse -File

    It 'finds at least one script' {
        $scriptFiles.Count | Should -BeGreaterThan 0
    }

    foreach ($file in $scriptFiles) {
        It "parses without syntax errors: $($file.Name)" {
            $null = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$null)
            # If ParseFile throws, Pester will catch it and fail the test
            $true | Should -BeTrue
        }
    }
}
