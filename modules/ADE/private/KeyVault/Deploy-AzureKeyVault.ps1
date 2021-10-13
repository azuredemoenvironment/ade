function Deploy-AzureKeyVault {
    param(
        [object] $armParameters,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [object] $wildcardCertificatePath
    )

    # Similar to other 'Deploy' functions, skip this KV Creation if the KV already exists
    If ($armParameters.keyVaultResourceID){ # We already Confirmed that this Azure resource existed earlier in script Set-InitialArmParameters.ps1 and populated the property keyVaultResourceID
        Write-Log "Key Vault $($armParameters.keyVaultName) already exists; skipping creation."
    }
    elseIf (Test-SoftDeleteKeyVault -KeyvaultName $armParameters.keyVaultName){
        Write-Status "'Soft Delete' KV $($armParameters.keyVaultName) exists. Recovering now..."
        Restore-SoftDeleteKeyvault -KeyvaultName $armParameters.keyVaultName
    }
    else {
        Deploy-ArmTemplate 'Azure Key Vault' $armParameters -resourceGroupName $armParameters.keyVaultResourceGroupName -bicep
        Write-Status "Configuring Azure Key Vault $($armParameters.keyVaultName)"
        Set-AzureKeyVaultSecret $armParameters.keyVaultName 'resourcePassword' $secureResourcePassword
        Deploy-WildcardCertificateToAzureKeyVault $armParameters.keyVaultName $secureCertificatePassword $wildcardCertificatePath
        New-AzureKeyVaultKey $armParameters.keyVaultName 'containerRegistry'
        Set-AzureKeyVaultResourceId $armParameters
    }
    Write-Status "Finished Configuring Azure Key Vault $($armParameters.keyVaultName)"
}