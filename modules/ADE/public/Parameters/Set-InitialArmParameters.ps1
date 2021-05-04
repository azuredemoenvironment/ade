function Set-InitialArmParameters {
    param(
        [string] $alias,
        [string] $email,
        [string] $resourceUserName,
        [string] $rootDomainName,
        [string] $localNetworkRange,
        [string] $defaultPrimaryRegion,
        [string] $defaultSecondaryRegion,
        [string] $module,
        [bool] $overwriteParameterFiles,
        [bool] $skipConfirmation
    )
    
    # Initial Parameter Setup
    $defaultPrimaryRegionShortName = Get-RegionShortName $defaultPrimaryRegion
    $defaultSecondaryRegionShortName = Get-RegionShortName $defaultSecondaryRegion
    $aliasRegion = "$alias-$defaultPrimaryRegionShortName".ToLowerInvariant()
    $aliasSecondaryRegion = "$alias-$defaultSecondaryRegionShortName".ToLowerInvariant()

    $primaryRegionResourceGroupNamePrefix = "rg-ade-$aliasRegion"
    $secondaryRegionResourceGroupNamePrefix = "rg-ade-$aliasSecondaryRegion"
    $sourceAddressPrefix = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    $acrName = "acr-ade-$aliasRegion-001".replace('-', '')

    Write-Log 'Gathering User Information from az'
    $currentAccount = az account show | ConvertFrom-Json
    $adSignedInUser = az ad signed-in-user show | ConvertFrom-Json

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'aliasRegion'                                  = $aliasRegion
        'aliasSecondaryRegion'                         = $aliasSecondaryRegion
        'contactEmailAddress'                          = $email
        'defaultPrimaryRegion'                         = $defaultPrimaryRegion
        'defaultSecondaryRegion'                       = $defaultSecondaryRegion
        'deployAzureFirewall'                          = 'false'
        'deployAzureVpnGateway'                        = 'false'
        'module'                                       = $module
        'overwriteParameterFiles'                      = $overwriteParameterFiles
        'rootDomainName'                               = $rootDomainName
        'skipConfirmation'                             = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                        = "sa-$aliasRegion-aciwp".replace('-', '')
        'acrName'                                      = $acrName
        'activityLogDiagnosticsName'                   = 'subscriptionactivitylog'
        'adeInitiativeDefinition'                      = "policy-ade-$aliasRegion-adeinitiative"
        'adminUserName'                                = $resourceUserName
        'aksClusterDNSName'                            = "aks-$aliasRegion-01-dns"
        'aksClusterName'                               = "aks-$aliasRegion-01"
        'applicationGatewayName'                       = "appgw-$aliasRegion-01"
        'applicationGatewayPublicIPAddressName'        = "pip-$aliasRegion-appgw01"
        'appServicePlanName'                           = "plan-ade-$aliasRegion-001"
        'azureActiveDirectoryTenantID'                 = $currentAccount.tenantId
        'azureActiveDirectoryUserID'                   = $adSignedInUser.objectId
        'computerVisionAccountName'                    = "computervision"        
        'containerGroupMySQLImage'                     = "$acrName.azurecr.io/mysql:latest"
        'containerGroupShareImage'                     = "$acrName.azurecr.io/azure-cli:latest"
        'containerGroupWordPressImage'                 = "$acrName.azurecr.io/wordpress:latest"
        'containerRegistryLoginServer'                 = "$acrName.azurecr.io"    
        "inspectorGadgetAppServicePrivateEndpointName" = "pe-$aliasRegion-inspectorgadgetappservice"
        'inspectorGadgetFQDN'                          = "as-$aliasRegion-inspectorgadget.azurewebsites.net".Replace('-', '')
        'inspectorGadgetHostName'                      = "inspectorgadget.$rootDomainName".replace('-', '')
        "inspectorGadgetWafPolicyName"                 = "wafp-$aliasRegion-inspectorgadget"
        "inspectorGadgetWebAppName"                    = "as-$aliasRegion-inspectorgadget".replace('-', '')
        'keyVaultName'                                 = "kv-ade-$aliasRegion-001"
        'localNetworkGatewayAddressPrefix'             = $localNetworkRange
        'logAnalyticsWorkspaceName'                    = "log-ade-$aliasRegion-001"        
        'nTierHostName'                                = "ntier.$rootDomainName"               
        'sourceAddressPrefix'                          = $sourceAddressPrefix        
        'sslCertificateName'                           = $rootDomainName
        'texAnalyticsAccountName'                      = "textanalytics"
        'trafficManagerProfileDNSName'                 = "tmp-$aliasRegion-helloworld".replace('-', '')
        'trafficManagerProfileName'                    = "tmp-$aliasRegion-helloworld"      
        'wordPressHostName'                            = "wordpress.$rootDomainName"

        # Required for Deploy-AzureGovernance.ps1
        'applicationGatewayManagedIdentityName'        = "id-ade-$aliasRegion-agw"
        'containerRegistryManagedIdentityName'         = "id-ade-$aliasRegion-acr"
        'containerRegistrySPNName'                     = "spn-ade-$aliasRegion-acr"          
        'githubActionsSPNName'                         = "spn-ade-$aliasRegion-gha"
        'restAPISPNName'                               = "spn-ade-$aliasRegion-restapi"
        
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'azureBastionSubnetNSGName'                    = "nsg-ade-$aliasRegion-bastion"
        'clientServicesSubnetNSGName'                  = "nsg-ade-$aliasRegion-clientservices"
        'managementSubnetNSGName'                      = "nsg-ade-$aliasRegion-management"
        'nsgFlowLogsStorageAccountName'                = "sa-ade-$aliasRegion-nsgflow".replace('-', '')     
        'nTierAppSubnetNSGName'                        = "nsg-ade-$aliasRegion-ntierapp"
        'nTierDBSubnetNSGName'                         = "nsg-ade-$aliasRegion-ntierdb"
        'nTierWebSubnetNSGName'                        = "nsg-ade-$aliasRegion-ntierweb"
        'vmssSubnetNSGName'                            = "nsg-ade-$aliasRegion-vmss"

        # Resource Group Names
        'adeAppAppServicesResourceGroupName'           = "$primaryRegionResourceGroupNamePrefix-adeappappservices"
        'adeAppSqlResourceGroupName'                   = "$primaryRegionResourceGroupNamePrefix-adeappsql"
        'aksNodeResourceGroupName'                     = "$primaryRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                         = "$primaryRegionResourceGroupNamePrefix-aks"
        'applicationGatewayResourceGroupName'          = "$primaryRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'              = "$primaryRegionResourceGroupNamePrefix-appserviceplan"
        'cognitiveServicesResourceGroupName'           = "$primaryRegionResourceGroupNamePrefix-cognitiveservices"
        'containerRegistryResourceGroupName'           = "$primaryRegionResourceGroupNamePrefix-containerregistry"
        'dnsResourceGroupName'                         = "$primaryRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-imageresizer"
        'inspectorGadgetResourceGroupName'             = "$primaryRegionResourceGroupNamePrefix-inspectorgadget"
        'jumpboxResourceGroupName'                     = "$primaryRegionResourceGroupNamePrefix-jumpbox"
        'keyVaultResourceGroupName'                    = "$primaryRegionResourceGroupNamePrefix-keyvault"
        'identityResourceGroupName'                    = "$primaryRegionResourceGroupNamePrefix-identity"
        'monitorResourceGroupName'                     = "$primaryRegionResourceGroupNamePrefix-monitor"
        'networkingResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-networking"
        'nTierResourceGroupName'                       = "$primaryRegionResourceGroupNamePrefix-ntier"
        'trafficManagerResourceGroupName'              = "$primaryRegionResourceGroupNamePrefix-trafficmanager"
        'vmssResourceGroupName'                        = "$primaryRegionResourceGroupNamePrefix-vmss"
        'w10clientResourceGroupName'                   = "$primaryRegionResourceGroupNamePrefix-w10client"
        'wordpressResourceGroupName'                   = "$primaryRegionResourceGroupNamePrefix-wordpress"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}