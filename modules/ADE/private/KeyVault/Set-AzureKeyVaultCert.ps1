function Set-AzureKeyVaultCert {
    param(
        [string] $keyVaultName,
        [string] $secretName,
        [string] $wildcardCertificatePath,
        [SecureString] $secureCertificatePassword
            )
    if (-not (Test-Path $wildcardCertificatePath)) {
        throw "A PFX certificate needs to be available at $wildcardCertificatePath. Please copy your certificate to that file path."
    }
    Write-Log "Setting Azure Key Vault $keyVaultName Wildcard Certificate $secretName"
    $certificatePlainText = ConvertFrom-SecureString -SecureString $secureCertificatePassword -AsPlainText

    az keyvault certificate import --vault-name $keyVaultName --name $secretName --file $wildcardCertificatePath --password $certificatePlainText
    Confirm-LastExitCode
}