function Set-AzureKeyVaultResourceId {
    param(
        [object] $armParameters
    )

    Write-Log 'Getting Azure Key Vault Resource ID and Assigning to ARM Parameters'
    $keyVaultResourceID = az keyvault show -n $armParameters.keyVaultName -g $armParameters.keyVaultResourceGroupName --query id
    $armParameters['keyVaultResourceID'] = $keyVaultResourceID.replace('"', '')
    Confirm-LastExitCode
}