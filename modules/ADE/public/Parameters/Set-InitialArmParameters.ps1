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

    $primaryRegionResourceGroupNamePrefix = "rg-$aliasRegion"
    $secondaryRegionResourceGroupNamePrefix = "rg-$aliasSecondaryRegion"
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
        'module'                                            = $module
        'overwriteParameterFiles'                           = $overwriteParameterFiles
        'rootDomainName'                                    = $rootDomainName
        'skipConfirmation'                                  = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                             = "sa-$aliasRegion-aciwp".replace('-', '')
        'acrName'                                           = $acrName
        'adminUsername'                                     = $resourceUserName
        'aksClusterDNSName'                                 = "aks-$aliasRegion-01-dns"
        'aksClusterName'                                    = "aks-$aliasRegion-01"
        'appGWManagedIdentityName'                          = "uami-$aliasRegion-appgw"
        'applicationGatewayName'                            = "appgw-$aliasRegion-01"
        'applicationGatewayPublicIPAddressName'             = "pip-$aliasRegion-appgw01"
        'automationAccountName'                             = "aa-$aliasRegion-01"
        'azureActiveDirectoryTenantID'                      = $currentAccount.tenantId
        'azureActiveDirectoryUserID'                        = $adSignedInUser.objectId
        'azureBastionName'                                  = "bastion-$aliasRegion-01"
        'azureBastionPublicIPAddressName'                   = "pip-$aliasRegion-bastion01"
        'azureBastionSubnetNetworkSecurityGroupName'        = "nsg-$aliasRegion-azurebastion"
        'clientServicesSubnetNetworkSecurityGroupName'      = "nsg-$aliasRegion-clientservices"
        'computerVisionAccountName'                         = "computervision"
        'connectionName'                                    = "cn-$aliasRegion-01"
        'containerGroupMySQLImage'                          = "$acrName.azurecr.io/mysql:latest"
        'containerGroupShareImage'                          = "$acrName.azurecr.io/azure-cli:latest"
        'containerGroupWordPressImage'                      = "$acrName.azurecr.io/wordpress:latest"
        'containerRegistryLoginServer'                      = "$acrName.azurecr.io"
        'crManagedIdentityName'                             = "uami-$aliasRegion-cr"
        'crSPNName'                                         = "spn-$aliasRegion-cr"
        'developerName'                                     = "vm-developer01"
        'developerNICName'                                  = "nic-$aliasRegion-developer01"
        'developerOSDiskName'                               = "disk-$aliasRegion-developer01-os".replace('-', '')
        'developerPublicIPAddressName'                      = "pip-$aliasRegion-developer01"
        'developerSubnetNetworkSecurityGroupName'           = "nsg-$aliasRegion-developer"
        'directoryServicesSubnetNetworkSecurityGroupName'   = "nsg-$aliasRegion-directoryservices"
        'firewallName'                                      = "fw-$aliasRegion-01"
        'firewallPublicIPAddressName'                       = "pip-$aliasRegion-fw01"
        'ghaSPNName'                                        = "spn-$aliasRegion-gha"
        'imageResizerAppInsightsName'                       = "appin-$aliasRegion-imageresizer".Replace('-', '')
        'imageResizerFQDN'                                  = "as-$aliasRegion-imgreszr.azurewebsites.net".Replace('-', '')
        'imageResizerFunctionAppName'                       = "fa-$aliasRegion-imgreszr".replace('-', '')
        'imageResizerFunctionAppStorageAccountName'         = "sa-$aliasRegion-faimgreszr".Replace('-', '')
        'imageResizerHostName'                              = "imageresizer.$rootDomainName".replace('-', '')
        'imageResizerpBackupStorageAccountName'             = "sa-$aliasRegion-bkpimgreszr".Replace('-', '')
        'imageResizerWebAppName'                            = "as-$aliasRegion-imgreszr".Replace('-', '')
        'imageResizerWebAppStorageAccountName'              = "sa-$aliasRegion-asimgreszr".Replace('-', '')
        'internetRouteTableName'                            = "rt-$aliasRegion-internet"
        'jumpboxName'                                       = "vm-jumpbox01"
        'jumpboxNICName'                                    = "nic-$aliasRegion-jumpbox01"
        'jumpboxOSDiskName'                                 = "disk-$aliasRegion-jumpbox01-os".replace('-', '')
        'jumpboxPublicIPAddressName'                        = "pip-$aliasRegion-jumpbox01"
        'keyVaultName'                                      = "kv-$aliasRegion-01"
        'localNetworkGatewayAddressPrefix'                  = $localNetworkRange
        'localNetworkGatewayName'                           = "lng-$aliasRegion-01"
        'logAnalyticsWorkspaceName'                         = "la-$aliasRegion-01"
        'managementSubnetNetworkSecurityGroupName'          = "nsg-$aliasRegion-management"
        'natGatewayName'                                    = "natgw-$aliasRegion-01"
        'natGatewayPublicIPAddressName'                     = "pip-$aliasRegion-natgw01"
        'natGatewayPublicIPPrefixName'                      = "pipp-$aliasRegion-natgw01"
        'nsgFlowLogsStorageAccountName'                     = "sa-$aliasRegion-nsgflow".replace('-', '')
        'nTierDB01NICName'                                  = "nic-$aliasRegion-ntierdb01"
        'nTierDB01OSDiskName'                               = "disk-$aliasRegion-ntierdb01-os".replace('-', '')
        'nTierDB02NICName'                                  = "nic-$aliasRegion-ntierdb02"
        'nTierDB02OSDiskName'                               = "disk-$aliasRegion-ntierdb02-os".replace('-', '')
        'nTierDBAvailabilitySetName'                        = "avset-$aliasRegion-ntierdb"
        'nTierDBLoadBalancerName'                           = "lb-$aliasRegion-ntierdb"
        'nTierDBSubnetNetworkSecurityGroupName'             = "nsg-$aliasRegion-ntierdb"
        'nTierHostName'                                     = "ntier.$rootDomainName"
        'nTierWeb01NICName'                                 = "nic-$aliasRegion-ntierweb01"
        'nTierWeb01OSDiskName'                              = "disk-$aliasRegion-ntierweb01-os".replace('-', '')
        'nTierWeb02NICName'                                 = "nic-$aliasRegion-ntierweb02"
        'nTierWeb02OSDiskName'                              = "disk-$aliasRegion-ntierweb02-os".replace('-', '')
        'nTierWebAvailabilitySetName'                       = "avset-$aliasRegion-ntierweb"
        'nTierWebSubnetNetworkSecurityGroupName'            = "nsg-$aliasRegion-ntierweb"
        'peering01'                                         = "vnet-$aliasRegion-01-to-vnet-$aliasRegion-02"
        'peering02'                                         = "vnet-$aliasRegion-02-to-vnet-$aliasRegion-01"
        'peering03'                                         = "vnet-$aliasRegion-01-to-vnet-$aliasRegion-03"
        'peering04'                                         = "vnet-$aliasRegion-03-to-vnet-$aliasRegion-01"
        'primaryRegionAppServicePlanName'                   = "asp-$aliasRegion-01"
        'primaryRegionHelloWorldAppInsightsName'            = "appin-$aliasRegion-helloworld"
        'primaryRegionHelloWorldEndpointName'               = "helloworld-$defaultPrimaryRegionShortName".replace('-', '')
        'primaryRegionHelloWorldWebAppName'                 = "as-$aliasRegion-helloworld".replace('-', '')
        'primaryRegionHelloWorldWebAppStorageAccountName'   = "sa-$aliasRegion-bkphello".replace('-', '')
        'restAPISPNName'                                    = "spn-$aliasRegion-restapi"
        'secondaryRegionAppServicePlanName'                 = "asp-$aliasSecondaryRegion-01"
        'secondaryRegionHelloWorldAppInsightsName'          = "appin-$aliasSecondaryRegion-helloworld"
        'secondaryRegionHelloWorldEndpointName'             = "helloworld-$defaultSecondaryRegionShortName".replace('-', '')
        'secondaryRegionHelloWorldWebAppName'               = "as-$aliasSecondaryRegion-helloworld".replace('-', '')
        'secondaryRegionHelloWorldWebAppStorageAccountName' = "sa-$aliasSecondaryRegion-bkphello".replace('-', '')
        'sourceAddressPrefix'                               = $sourceAddressPrefix
        'sqlToDoAppInsightsName'                            = "appin-$aliasRegion-sqltodo".replace('-', '')
        'sqlToDoFQDN'                                       = "as-$aliasRegion-sqltodo.azurewebsites.net".replace('-', '')
        'sqlToDoHostName'                                   = "sqltodo.$rootDomainName"
        'sqlToDoSqlAdminUserName'                           = $resourceUserName
        'sqlToDoSqlDatabaseName'                            = "sqldb-$aliasRegion-todo".replace('-', '')
        'sqlToDoSqlServerName'                              = "sql-$aliasRegion-todo".replace('-', '')
        'sqlToDoWebAppBackupStorageAccountName'             = "sa-$aliasRegion-bkpsqltodo".replace('-', '')
        'sqlToDoWebAppName'                                 = "as-$aliasRegion-sqltodo".replace('-', '')
        'sslCertificateName'                                = $rootDomainName
        'texAnalyticsAccountName'                           = "textanalytics"
        'trafficManagerProfileDNSName'                      = "tmp-$aliasRegion-helloworld".replace('-', '')
        'trafficManagerProfileName'                         = "tmp-$aliasRegion-helloworld"
        'virtualNetwork01Name'                              = "vnet-$aliasRegion-01"
        'virtualNetwork02Name'                              = "vnet-$aliasRegion-02"
        'virtualNetwork03Name'                              = "vnet-$aliasRegion-03"
        'virtualNetworkGatewayName'                         = "vng-$aliasRegion-01"
        'virtualNetworkGatewayPublicIPAddressName'          = "pip-$aliasRegion-vng01"
        'vmDiagnosticsStorageAccountName'                   = "sa-$aliasRegion-vmdiags".replace('-', '')
        'vmssLoadBalancerName'                              = "lb-$aliasRegion-vmss01"
        'vmssLoadBalancerPublicIPAddressName'               = "pip-$aliasRegion-lb-vmss01"
        'vmssName'                                          = "vmss01"
        'vmssNICName'                                       = "nic-$aliasRegion-vmss01"
        'vmssSubnetNetworkSecurityGroupName'                = "nsg-$aliasRegion-vmss"
        'w10clientName'                                     = "vm-w10client01"
        'w10clientNICName'                                  = "nic-$aliasRegion-w10client01"
        'w10clientOSDiskName'                               = "disk-$aliasRegion-w10client01-os".replace('-', '')
        'wordPressHostName'                                 = "wordpress.$rootDomainName"


        # Resource Group Names
        'aksNodeResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                              = "$primaryRegionResourceGroupNamePrefix-aks"
        'alertsResourceGroupName'                           = "$primaryRegionResourceGroupNamePrefix-alerts"
        'applicationGatewayResourceGroupName'               = "$primaryRegionResourceGroupNamePrefix-applicationgateway"
        'bastionResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-bastion"
        'cognitiveServicesResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-cognitiveservices"
        'containerRegistryResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-containerregistry"
        'developerResourceGroupName'                        = "$primaryRegionResourceGroupNamePrefix-developer"
        'dnsResourceGroupName'                              = "$primaryRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'                     = "$primaryRegionResourceGroupNamePrefix-imageresizer"
        'jumpboxResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-jumpbox"
        'keyVaultResourceGroupName'                         = "$primaryRegionResourceGroupNamePrefix-keyvault"
        'logAnalyticsWorkspaceResourceGroupName'            = "$primaryRegionResourceGroupNamePrefix-loganalytics"
        'managedIdentityResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-managedidentity"
        'networkingResourceGroupName'                       = "$primaryRegionResourceGroupNamePrefix-networking"
        'ntierResourceGroupName'                            = "$primaryRegionResourceGroupNamePrefix-ntier"
        'primaryRegionAppServicePlanResourceGroupName'      = "$primaryRegionResourceGroupNamePrefix-asp"
        'primaryRegionHelloWorldWebAppResourceGroupName'    = "$primaryRegionResourceGroupNamePrefix-helloworld"
        'secondaryRegionAppServicePlanResourceGroupName'    = "$secondaryRegionResourceGroupNamePrefix-asp"
        'secondaryRegionHelloWorldWebAppResourceGroupName'  = "$secondaryRegionResourceGroupNamePrefix-helloworld"
        'sqlTodoResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-sqltodo"
        'storageResourceGroupName'                          = "$primaryRegionResourceGroupNamePrefix-diagnostics"
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