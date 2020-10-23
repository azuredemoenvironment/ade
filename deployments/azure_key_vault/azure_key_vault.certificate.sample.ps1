# deploy key vault certificate
Login-AzAccount
$pfxCertificateFilePath = "ENTER PATH TO PFX CERTIFICATE HERE"
$pfxCertificatePassword = "ENTER PASSWORD FOR PFX CERTIFICATE HERE"
$flag = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$collection.Import($pfxCertificateFilePath, $pfxCertificatePassword, $flag)
$pkcs12ContentType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12
$clearBytes = $collection.Export($pkcs12ContentType)
$fileContentEncoded = [System.Convert]::ToBase64String($clearBytes)
$secret = ConvertTo-SecureString -String $fileContentEncoded -AsPlainText –Force
$secretContentType = 'application/x-pkcs12'
$keyVaultName = 'ENTER KEY VAULT NAME HERE'
$keyVaultSecretName = 'certificate'
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -SecretValue $secret -ContentType $secretContentType
