@{
    Severity     = @('Error','Warning')
    ExcludeRules = @(
        # Allow Write-Host for simple CLI feedback
        'PSAvoidUsingWriteHost'
    )
    Rules        = @{
        PSUseCompatibleSyntax = @{Enable = $true; TargetVersions = @('5.1')}
    }
}
