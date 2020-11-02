function Set-HelloWorldCert {
    param(
        [object] $armParameters
    )

        $kvName = $armParameters.keyVaultName
        $certName = $armParameters.HelloWorldCert
        $primaryRG = $armParameters.primaryRegionHelloWorldWebAppResourceGroupName
        $primaryWA = $armParameters.primaryRegionHelloWorldWebAppName
        $secondaryRG = $armParameters.secondaryRegionHelloWorldWebAppResourceGroupName
        $secondaryWA = $armParameters.secondaryRegionHelloWorldWebAppName
        $rootDN = $armParameters.RootDomainName
        $fqdn = "helloworld."+$rootDN

        # Import Key Vault cert to primary region Hello World app
        # Concerned this requires a waiting period for the KV Access Policy to work correctly
        Write-Log "Importing KV Certificate to primary Hello World app"
        az webapp config ssl import --resource-group $primaryRG --name $primaryWA --key-vault $kvName --key-vault-certificate-name $certName
        Confirm-LastExitCode
        # Import Key Vault cert to secondary  region Hello World app
        
        Write-Log "Importing KV Certificate to secondary Hello World app"
        az webapp config ssl import --resource-group $secondaryRG --name $secondaryWA --key-vault $kvName --key-vault-certificate-name $certName
        Confirm-LastExitCode


        # Bind imported cert to the primary region app service
        Write-Log "Importing KV Certificate to secondary Hello World app"
        $Thumbprint = az keyvault certificate show --name $certName --vault-name $kvName --query x509ThumbprintHex --output tsv

        <# 
        Disabled until Azure CLI Issue 13929 resolved - https://github.com/Azure/azure-cli/issues/13929
        
        az webapp config ssl bind --certificate-thumbprint $Thumbprint --name $primaryWA --resource-group $primaryRG --ssl-type SNI 
        #>
        Write-Log "Binding imported KV certificate to primary hello world app"
        New-AzWebAppSSLBinding -ResourceGroupName $primaryRG -WebAppName $primaryWA -Thumbprint $Thumbprint -Name $fqdn -SslState SniEnabled
        Confirm-LastExitCode
        
        Write-Log "Binding imported KV certificate to secondary hello world app"
        New-AzWebAppSSLBinding -ResourceGroupName $secondaryRG -WebAppName $secondaryWA -Thumbprint $Thumbprint -Name $fqdn -SslState SniEnabled
        Confirm-LastExitCode
    }