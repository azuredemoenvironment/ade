function Deploy-AzureKeyVault {
    param(
        [object] $armParameters,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [object] $wildcardCertificatePath
    )

    # Check to see if our Soft-Delete KeyVault exists
    If ((!$armParameters.keyVaultResourceID) -and (Test-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName)) {
        Write-Status "'Soft Delete' KV $($armParameters.keyVaultName) exists. Running Restore-SoftDeleteKeyVault..."
        Restore-SoftDeleteKeyVault -KeyvaultName $armParameters.keyVaultName
    }

    Deploy-ArmTemplate 'Azure Key Vault' $armParameters -resourceGroupName $armParameters.keyVaultResourceGroupName -bicep
    Write-Status "Configuring Azure Key Vault $($armParameters.keyVaultName)"
    Set-AzureKeyVaultSecret $armParameters.keyVaultName 'resourcePassword' $secureResourcePassword
    Deploy-WildcardCertificateToAzureKeyVault $armParameters.keyVaultName $secureCertificatePassword $wildcardCertificatePath
    New-AzureKeyVaultKey $armParameters.keyVaultName 'containerRegistry'
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $($armParameters.keyVaultName)"
}