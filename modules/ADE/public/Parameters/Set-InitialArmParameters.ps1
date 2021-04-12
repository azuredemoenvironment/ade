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
    $acrName = "acr-$aliasRegion-01".replace('-', '')

    Write-Log 'Gathering User Information from az'
    $currentAccount = az account show | ConvertFrom-Json
    $adSignedInUser = az ad signed-in-user show | ConvertFrom-Json

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'aliasRegion'                                       = $aliasRegion
        'aliasSecondaryRegion'                              = $aliasSecondaryRegion
        'contactEmailAddress'                               = $email
        'defaultPrimaryRegion'                              = $defaultPrimaryRegion
        'defaultSecondaryRegion'                            = $defaultSecondaryRegion
        'deployAzureFirewall'                               = 'true'
        'deployAzureVpnGateway'                             = 'false'
        'module'                                            = $module
        'overwriteParameterFiles'                           = $overwriteParameterFiles
        'rootDomainName'                                    = $rootDomainName
        'skipConfirmation'                                  = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                             = "sa-$aliasRegion-aciwp".replace('-', '')
        'acrName'                                           = $acrName
        'activityLogDiagnosticsName'                        = 'subscriptionactivitylog'
        'adminUserName'                                     = $resourceUserName
        'aksClusterDNSName'                                 = "aks-$aliasRegion-01-dns"
        'aksClusterName'                                    = "aks-$aliasRegion-01"
        'applicationGatewayManagedIdentityName'             = "id-ade-$aliasRegion-agw"
        'applicationGatewayName'                            = "appgw-$aliasRegion-01"
        'applicationGatewayPublicIPAddressName'             = "pip-$aliasRegion-appgw01"
        'appServicePlanName'                                = "plan-ade-$aliasRegion-001"
        'azureActiveDirectoryTenantID'                      = $currentAccount.tenantId
        'azureActiveDirectoryUserID'                        = $adSignedInUser.objectId
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'azureBastionSubnetNSGName'                         = "nsg-ade-$aliasRegion-azurebastion"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'clientServicesSubnetNSGName'                       = "nsg-ade-$aliasRegion-clientservices"
        'computerVisionAccountName'                         = "computervision"        
        'containerGroupMySQLImage'                          = "$acrName.azurecr.io/mysql:latest"
        'containerGroupShareImage'                          = "$acrName.azurecr.io/azure-cli:latest"
        'containerGroupWordPressImage'                      = "$acrName.azurecr.io/wordpress:latest"
        'containerRegistryLoginServer'                      = "$acrName.azurecr.io"
        'containerRegistryManagedIdentityName'              = "id-ade-$aliasRegion-acr"
        'containerRegistrySPNName'                          = "spn-ade-$aliasRegion-acr"
        'developerName'                                     = "vm-developer01"
        'developerNICName'                                  = "nic-$aliasRegion-developer01"
        'developerOSDiskName'                               = "disk-$aliasRegion-developer01-os"
        'developerPublicIPAddressName'                      = "pip-$aliasRegion-developer01"   
        'githubActionsSPNName'                              = "spn-ade-$aliasRegion-gha"        
        'imageResizerFQDN'                                  = "as-$aliasRegion-imgreszr.azurewebsites.net".Replace('-', '')
        'imageResizerFunctionAppName'                       = "fa-$aliasRegion-imgreszr".replace('-', '')
        'imageResizerFunctionAppStorageAccountName'         = "sa-$aliasRegion-faimgreszr".Replace('-', '')
        'imageResizerHostName'                              = "imageresizer.$rootDomainName".replace('-', '')
        'imageResizerpBackupStorageAccountName'             = "sa-$aliasRegion-bkpimgreszr".Replace('-', '')
        'imageResizerWebAppName'                            = "as-$aliasRegion-imgreszr".Replace('-', '')
        'imageResizerWebAppStorageAccountName'              = "sa-$aliasRegion-asimgreszr".Replace('-', '')        
        "inspectorGadgetAppServicePrivateEndpointName"      = "pe-$aliasRegion-inspectorgadgetappservice"
        "inspectorGadgetAzureSQLPrivateEndpointName"        = "pe-$aliasRegion-inspectorgadgetazuresql"
        'inspectorGadgetFQDN'                               = "as-$aliasRegion-inspectorgadget.azurewebsites.net".Replace('-', '')
        'inspectorGadgetHostName'                           = "inspectorgadget.$rootDomainName".replace('-', '')
        "inspectorGadgetSqlAdminUserName"                   = $resourceUserName
        "inspectorGadgetSqlDatabaseName"                    = "sqldb-$aliasRegion-inspectorgadget".replace('-', '')
        "inspectorGadgetSqlServerName"                      = "sql-$aliasRegion-inspectorgadget".replace('-', '')
        "inspectorGadgetWafPolicyName"                      = "wafp-$aliasRegion-inspectorgadget"
        "inspectorGadgetWebAppName"                         = "as-$aliasRegion-inspectorgadget".replace('-', '')
        'jumpboxName'                                       = "vm-jumpbox01"
        'jumpboxNICName'                                    = "nic-$aliasRegion-jumpbox01"
        'jumpboxOSDiskName'                                 = "disk-$aliasRegion-jumpbox01-os"
        'jumpboxPublicIPAddressName'                        = "pip-$aliasRegion-jumpbox01"
        'keyVaultName'                                      = "kv-ade-$aliasRegion-001"
        'localNetworkGatewayAddressPrefix'                  = $localNetworkRange
        'logAnalyticsWorkspaceName'                         = "log-ade-$aliasRegion-001"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'managementSubnetNSGName'                           = "nsg-ade-$aliasRegion-management"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'nsgFlowLogsStorageAccountName'                     = "sa-ade-$aliasRegion-nsgflow".replace('-', '')     
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'nTierAppSubnetNSGName'                             = "nsg-ade-$aliasRegion-ntierapp"
        'nTierDB01NICName'                                  = "nic-$aliasRegion-ntierdb01"
        'nTierDB01OSDiskName'                               = "disk-$aliasRegion-ntierdb01-os"
        'nTierDB02NICName'                                  = "nic-$aliasRegion-ntierdb02"
        'nTierDB02OSDiskName'                               = "disk-$aliasRegion-ntierdb02-os"
        'nTierDBAvailabilitySetName'                        = "avset-$aliasRegion-ntierdb"
        'nTierDBLoadBalancerName'                           = "lb-$aliasRegion-ntierdb"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'nTierDBSubnetNSGName'                              = "nsg-ade-$aliasRegion-ntierdb"
        'nTierHostName'                                     = "ntier.$rootDomainName"
        'nTierWeb01NICName'                                 = "nic-$aliasRegion-ntierweb01"
        'nTierWeb01OSDiskName'                              = "disk-$aliasRegion-ntierweb01-os"
        'nTierWeb02NICName'                                 = "nic-$aliasRegion-ntierweb02"
        'nTierWeb02OSDiskName'                              = "disk-$aliasRegion-ntierweb02-os"
        'nTierWebAvailabilitySetName'                       = "avset-$aliasRegion-ntierweb"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'nTierWebSubnetNSGName'                             = "nsg-ade-$aliasRegion-ntierweb"   
        'restAPISPNName'                                    = "spn-ade-$aliasRegion-restapi"        
        'sourceAddressPrefix'                               = $sourceAddressPrefix        
        'sslCertificateName'                                = $rootDomainName
        'texAnalyticsAccountName'                           = "textanalytics"
        'trafficManagerProfileDNSName'                      = "tmp-$aliasRegion-helloworld".replace('-', '')
        'trafficManagerProfileName'                         = "tmp-$aliasRegion-helloworld"
        # Required for Deploy-StorageFirewallRules.ps1
        'virtualNetwork001Name'                             = "vnet-ade-$aliasRegion-001"
        # Required for Deploy-StorageFirewallRules.ps1
        'virtualNetwork002Name'                             = "vnet-ade-$aliasRegion-002"     
        # Required for Deploy-StorageFirewallRules.ps1
        'vmDiagnosticsStorageAccountName'                   = "sa-ade-$aliasRegion-vmdiags".replace('-', '')
        'vmssLoadBalancerName'                              = "lb-$aliasRegion-vmss01"
        'vmssLoadBalancerPublicIPAddressName'               = "pip-$aliasRegion-lb-vmss01"
        'vmssName'                                          = "vmss01"
        'vmssNICName'                                       = "nic-$aliasRegion-vmss01"
        # Required for Deploy-AzureNsgFlowLogs.ps1
        'vmssSubnetNSGName'                                 = "nsg-ade-$aliasRegion-vmss"
        'w10clientName'                                     = "vm-w10client01"
        'w10clientNICName'                                  = "nic-$aliasRegion-w10client01"
        'w10clientOSDiskName'                               = "disk-$aliasRegion-w10client01-os"
        'wordPressHostName'                                 = "wordpress.$rootDomainName"

        # Resource Group Names
        'aksNodeResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                              = "$primaryRegionResourceGroupNamePrefix-aks"
        'applicationGatewayResourceGroupName'               = "$primaryRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'                   = "$primaryRegionResourceGroupNamePrefix-appserviceplan"
        'cognitiveServicesResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-cognitiveservices"
        'containerRegistryResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-containerregistry"
        'dnsResourceGroupName'                              = "$primaryRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'                     = "$primaryRegionResourceGroupNamePrefix-imageresizer"
        'inspectorGadgetResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-inspectorgadget"
        'jumpboxResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-jumpbox"
        'keyVaultResourceGroupName'                         = "$primaryRegionResourceGroupNamePrefix-keyvault"
        'managedIdentityResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-identity"
        'monitorResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-monitor"
        'networkingResourceGroupName'                       = "$primaryRegionResourceGroupNamePrefix-networking"
        'ntierResourceGroupName'                            = "$primaryRegionResourceGroupNamePrefix-ntier"
        'trafficManagerResourceGroupName'                   = "$primaryRegionResourceGroupNamePrefix-trafficmanager"
        'vmssResourceGroupName'                             = "$primaryRegionResourceGroupNamePrefix-vmss"
        'w10clientResourceGroupName'                        = "$primaryRegionResourceGroupNamePrefix-w10client"
        'wordpressResourceGroupName'                        = "$primaryRegionResourceGroupNamePrefix-wordpress"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}