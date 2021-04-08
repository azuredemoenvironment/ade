function Remove-AzureKeyVaultResourceGroup {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure KeyVault Resource Group"

    az group delete -n $armParameters.keyVaultResourceGroupName -y
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removing Azure KeyVault Resource Group"
}