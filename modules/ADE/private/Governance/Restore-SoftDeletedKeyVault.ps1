function Restore-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultName       
    )

    Write-ScriptSection "Restoring Soft-Deleted KeyVault $KeyVaultName"

    az keyvault recover -n $KeyVaultName | Out-Null
    Confirm-LastExitCode

    Write-Log "Restored Soft-Deleted KeyVault $KeyVaultName"
}