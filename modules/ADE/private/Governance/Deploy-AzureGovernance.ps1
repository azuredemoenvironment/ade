function Deploy-AzureGovernance {
    param(
        [object] $armParameters
    )

    # Parameters
    ##################################################
    $keyVaultName = $armParameters.keyVaultName

    # Deploy the Azure Governance Bicep template at the subscription scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Governance' $armParameters -resourceLevel 'sub' -bicep

    # Configure Azure KeyVault
    ##################################################
    Write-Status "Configuring Azure Key Vault $keyVaultName"

    # Configure the resource password KeyVault secret.
    Set-AzureKeyVaultSecret $keyVaultName 'resourcePassword' $secureResourcePassword

    # Deploy the wildcard certificate KeyVault secret.
    Deploy-WildcardCertificateToAzureKeyVault $keyVaultName $secureCertificatePassword $wildcardCertificatePath

    # Create the Container Registry encryption key.
    New-AzureKeyVaultKey $keyVaultName 'containerRegistry'
    
    # Set the Azure KeyVault resource id for future deployments.
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $keyVaultName"
}