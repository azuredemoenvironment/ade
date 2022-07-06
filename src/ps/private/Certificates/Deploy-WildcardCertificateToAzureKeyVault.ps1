function Deploy-WildcardCertificateToAzureKeyVault {
    param(
        [string] $keyVaultName,
        [SecureString] $secureCertificatePassword,
        [string] $wildcardCertificatePath
    )
    Write-Log "Loading PFX from $wildcardCertificatePath"

    if (-not (Test-Path $wildcardCertificatePath)) {
        throw "A PFX certificate needs to be available at $wildcardCertificatePath. Please copy your certificate to that file path."
    }

    # Convert Secure Password into Plain Text
    $certificatePasswordPlainText = ConvertFrom-SecureString -SecureString $secureCertificatePassword -AsPlainText

    # Upload PFX Certificate to Key Vault as a Certificate
    az keyvault certificate import --vault-name $keyVaultName --name 'pfx-certificate' --file $wildcardCertificatePath --password $certificatePasswordPlainText --only-show-errors
    Confirm-LastExitCode

    # TODO: move to separate function
    $certificateFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    $certificateCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certificateCollection.Import($wildcardCertificatePath, $certificatePasswordPlainText, $certificateFlags)
    $pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
    $certificateBytes = $certificateCollection.Export($pkcs12ContentType)
    $encodedCertificate = [System.Convert]::ToBase64String($certificateBytes)
    $secureEncodedCertificate = ConvertTo-SecureString $encodedCertificate -AsPlainText -Force

    Set-AzureKeyVaultSecret $keyVaultName 'certificate' $secureEncodedCertificate 'application/x-pkcs12'
}