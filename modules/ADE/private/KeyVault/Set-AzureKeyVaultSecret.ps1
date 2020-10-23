function Set-AzureKeyVaultSecret {
    param(
        [string] $keyVaultName,
        [string] $secretName,
        [SecureString] $secretValue,
        [string] $secretContentType
    )

    Write-Log "Setting Azure Key Vault $keyVaultName Secret $secretName"
    $secretPlainTextValue = ConvertFrom-SecureString -SecureString $secretValue -AsPlainText

    az keyvault secret set -n $secretName --vault-name $keyVaultName --value $secretPlainTextValue 
    Confirm-LastExitCode

    if ($secretContentType -ne '') {
        Write-Log "Setting Azure Key Vault $keyVaultName Secret $secretName Attributes"

        az keyvault secret set-attributes -n $secretName --vault-name $keyVaultName --content-type $secretContentType
        Confirm-LastExitCode
    }
}