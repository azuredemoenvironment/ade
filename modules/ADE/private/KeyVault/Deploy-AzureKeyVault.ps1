function Deploy-AzureKeyVault {
    param(
        [object] $armParameters,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [object] $wildcardCertificatePath
    )

    Deploy-ArmTemplate 'Azure Key Vault' $armParameters -resourceGroupName $armParameters.keyVaultResourceGroupName -bicep

    Write-Status "Configuring Azure Key Vault $($armParameters.keyVaultName)"

    Set-AzureKeyVaultSecret $armParameters.keyVaultName 'resourcePassword' $secureResourcePassword
    Deploy-WildcardCertificateToAzureKeyVault $armParameters.keyVaultName $secureCertificatePassword $wildcardCertificatePath
    
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $($armParameters.keyVaultName)"
}