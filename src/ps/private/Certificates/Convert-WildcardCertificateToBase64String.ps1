function Convert-WildcardCertificateToBase64String {
    param(
        [SecureString] $secureCertificatePassword,
        [string] $wildcardCertificatePath
    )
    Write-Log "Loading PFX from $wildcardCertificatePath"

    if (-not (Test-Path $wildcardCertificatePath)) {
        throw "A PFX certificate needs to be available at $wildcardCertificatePath. Please copy your certificate to that file path."
    }

    # Convert Secure Password into Plain Text
    $certificatePasswordPlainText = ConvertFrom-SecureString -SecureString $secureCertificatePassword -AsPlainText

    # Convert to Base64 String
    $certificateFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    $certificateCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certificateCollection.Import($wildcardCertificatePath, $certificatePasswordPlainText, $certificateFlags)
    $pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
    $certificateBytes = $certificateCollection.Export($pkcs12ContentType)
    $encodedCertificate = [System.Convert]::ToBase64String($certificateBytes)

    return $encodedCertificate
}