function Restore-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultName       
    )
    Write-Log "Restoring Soft-Delete KeyVault by running: az keyvault recover -n $KeyVaultName | Out-Null" 
    az keyvault recover -n $KeyVaultName | Out-Null
    Confirm-LastExitCode
}