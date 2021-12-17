function Restore-SoftDeleteKeyVault {
    param(
        [string] $KeyVaultResourceGroupName,
        [string] $KeyVaultName       
    )

    Write-ScriptSection "Restoring Soft-Deleted KeyVault $KeyVaultName"

    if (-not (Confirm-AzureResourceExists 'group' $KeyVaultResourceGroupName)) {
        az group create --name $KeyVaultResourceGroupName
        Confirm-LastExitCode
    }

    az keyvault recover -n $KeyVaultName | Out-Null
    Confirm-LastExitCode

    Write-Log "Restored Soft-Deleted KeyVault $KeyVaultName"
}