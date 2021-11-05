function New-AzureKeyVaultKey {
    param(
        [string] $keyVaultName,
        [string] $keyVaultKeyName
    )

    Write-Log "Creating Azure Key Vault $keyVaultName Key $keyVaultKeyName"
    az keyvault key create --vault-name $keyVaultName -n $keyVaultKeyName --kty RSA --size 2048 --only-show-errors
    Confirm-LastExitCode
}