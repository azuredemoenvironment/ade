function Deploy-AzureGovernance {
    param(
        [object] $armParameters
    )

    # Parameters
    ##################################################
    $keyVaultKeyName = $armParameters.keyVaultKeyName
    $keyVaultName = $armParameters.keyVaultName

    # there's a scenario when debugging just this module that the keyVaultResourceID property
    # doesn't exist; this wouldn't happen in a normal run
    $keyVaultResourceIdPropertyExists = [bool]($armParameters.PSobject.Properties.name -match 'keyVaultResourceID')
    if ((-not $keyVaultResourceIdPropertyExists -or (!$armParameters.keyVaultResourceID)) -and (Test-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName)) {
        Restore-SoftDeleteKeyVault -KeyVaultResourceGroupName $armParameters.keyVaultResourceGroupName -KeyVaultName $armParameters.keyVaultName
    }

    # Deploy Azure Governance
    ##################################################
    Write-ScriptSection "Initializing Azure Governance Deployment"

    # Deploy the Azure Governance Bicep template at the subscription scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Governance' $armParameters -resourceLevel 'sub' -bicep

    Write-Status "Finished Azure Governance Deployment"

    # Configure Azure KeyVault
    ##################################################
    Write-Status "Configuring Azure Key Vault $keyVaultName"

    # Configure the resource password KeyVault secret.
    Set-AzureKeyVaultSecret $keyVaultName 'resourcePassword' $secureResourcePassword

    # Deploy the wildcard certificate KeyVault secret.
    Deploy-WildcardCertificateToAzureKeyVault $keyVaultName $secureCertificatePassword $wildcardCertificatePath

    # Create the Container Registry encryption key.
    New-AzureKeyVaultKey $keyVaultName $keyVaultKeyName
    
    # Set the Azure KeyVault resource id for future deployments.
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $keyVaultName"
}
