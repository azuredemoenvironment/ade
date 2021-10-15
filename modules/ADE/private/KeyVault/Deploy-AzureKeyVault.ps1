function Deploy-AzureKeyVault {
    param(
        [object] $armParameters,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [object] $wildcardCertificatePath
    )

    # there's a scenario when debugging just this module that the keyVaultResourceID property
    # doesn't exist; this wouldn't happen in a normal run
    $keyVaultResourceIdPropertyExists = [bool]($armParameters.PSobject.Properties.name -match 'keyVaultResourceID')
    if ((-not $keyVaultResourceIdPropertyExists -or (!$armParameters.keyVaultResourceID)) -and (Test-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName)) {
        Restore-SoftDeleteKeyVault -KeyVaultName $armParameters.keyVaultName
    }

    Deploy-ArmTemplate 'Azure Key Vault' $armParameters -resourceGroupName $armParameters.keyVaultResourceGroupName -bicep

    Write-Status "Configuring Azure Key Vault $($armParameters.keyVaultName)"

    Set-AzureKeyVaultSecret $armParameters.keyVaultName 'resourcePassword' $secureResourcePassword
    Deploy-WildcardCertificateToAzureKeyVault $armParameters.keyVaultName $secureCertificatePassword $wildcardCertificatePath
    New-AzureKeyVaultKey $armParameters.keyVaultName 'containerRegistry'
    Set-AzureKeyVaultResourceId $armParameters

    Write-Status "Finished Configuring Azure Key Vault $($armParameters.keyVaultName)"
}