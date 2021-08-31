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
        'aliasRegion'                           = $aliasRegion
        'aliasSecondaryRegion'                  = $aliasSecondaryRegion
        'contactEmailAddress'                   = $email
        'defaultPrimaryRegion'                  = $defaultPrimaryRegion
        'defaultSecondaryRegion'                = $defaultSecondaryRegion
        'deployAzureFirewall'                   = 'true'
        'deployAzureVpnGateway'                 = 'false'
        'module'                                = $module
        'overwriteParameterFiles'               = $overwriteParameterFiles
        'rootDomainName'                        = $rootDomainName
        'skipConfirmation'                      = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                 = "sa-$aliasRegion-aciwp".replace('-', '')
        'acrName'                               = $acrName
        'activityLogDiagnosticsName'            = "subscriptionActivityLog"
        'adeInitiativeDefinition'               = "policy-ade-$aliasRegion-adeinitiative"
        'adminUserName'                         = $resourceUserName
        'aksClusterDNSName'                     = "aks-$aliasRegion-01-dns"
        'aksClusterName'                        = "aks-$aliasRegion-01"        
        'azureActiveDirectoryTenantID'          = $currentAccount.tenantId
        'azureActiveDirectoryUserID'            = $adSignedInUser.objectId   
        'containerRegistryLoginServer'          = "$acrName.azurecr.io"    
        'keyVaultName'                          = "kv-ade-$aliasRegion-001"
        'localNetworkGatewayAddressPrefix'      = $localNetworkRange
        'logAnalyticsWorkspaceName'             = "log-ade-$aliasRegion-001"        
        'nTierHostName'                         = "ntier.$rootDomainName"               
        'sourceAddressPrefix'                   = $sourceAddressPrefix        
        'sslCertificateName'                    = $rootDomainName    

        # Required for Deploy-AzureGovernance.ps1
        'applicationGatewayManagedIdentityName' = "id-ade-$aliasRegion-agw"
        'containerRegistryManagedIdentityName'  = "id-ade-$aliasRegion-acr"
        'containerRegistrySPNName'              = "spn-ade-$aliasRegion-acr"          
        'githubActionsSPNName'                  = "spn-ade-$aliasRegion-gha"
        'restAPISPNName'                        = "spn-ade-$aliasRegion-restapi"

        # Required for Deploy-AzureAppServicePlanScaleDown.ps1
        'appServicePlanName'                    = "plan-ade-$aliasRegion-001"

        # Required for Deploy-AzureDns.ps1
        'applicationGatewayPublicIPAddressName' = "pip-ade-$aliasRegion-appgw001"

        # Required for Enable-HighCostAzureServices.ps1 and Disable-HighCostAzureServices.ps1
        'azureFirewallPublicIpAddressName'      = "pip-ade-$aliasRegion-fw001"
        'azureFirewallName'                     = "fw-ade-$aliasRegion-001"
        'jumpboxName'                           = "vm-jumpbox01"
        'nTierWeb01Name'                        = "vm-ntierweb01"
        'nTierWeb02Name'                        = "vm-ntierweb02"
        'nTierWeb03Name'                        = "vm-ntierweb03"
        'nTierApp01Name'                        = "vm-ntierapp01"
        'nTierApp02Name'                        = "vm-ntierapp02"
        'nTierApp03Name'                        = "vm-ntierapp03"
        'virtualNetwork001Name'                 = "vnet-ade-${aliasRegion}-001"
        'vmssName'                              = "vmss01"
        'w10clientName'                         = "vm-w10client"
        
        # Resource Group Names
        'adeAppAppServicesResourceGroupName'    = "$primaryRegionResourceGroupNamePrefix-adeappweb"
        'adeAppLoadTestingResourceGroupName'    = "$primaryRegionResourceGroupNamePrefix-adeapploadtesting"
        'adeAppSqlResourceGroupName'            = "$primaryRegionResourceGroupNamePrefix-adeappdb"
        'aksNodeResourceGroupName'              = "$primaryRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-aks"
        'applicationGatewayResourceGroupName'   = "$primaryRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'       = "$primaryRegionResourceGroupNamePrefix-appserviceplan"
        'cognitiveServicesResourceGroupName'    = "$primaryRegionResourceGroupNamePrefix-cognitiveservices"
        'containerRegistryResourceGroupName'    = "$primaryRegionResourceGroupNamePrefix-containerregistry"
        'dnsResourceGroupName'                  = "$primaryRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'         = "$primaryRegionResourceGroupNamePrefix-imageresizer"
        'inspectorGadgetResourceGroupName'      = "$primaryRegionResourceGroupNamePrefix-inspectorgadget"
        'jumpboxResourceGroupName'              = "$primaryRegionResourceGroupNamePrefix-jumpbox"
        'keyVaultResourceGroupName'             = "$primaryRegionResourceGroupNamePrefix-keyvault"
        'identityResourceGroupName'             = "$primaryRegionResourceGroupNamePrefix-identity"
        'monitorResourceGroupName'              = "$primaryRegionResourceGroupNamePrefix-monitor"
        'networkingResourceGroupName'           = "$primaryRegionResourceGroupNamePrefix-networking"
        'nTierResourceGroupName'                = "$primaryRegionResourceGroupNamePrefix-ntier"
        'trafficManagerResourceGroupName'       = "$primaryRegionResourceGroupNamePrefix-trafficmanager"
        'vmssResourceGroupName'                 = "$primaryRegionResourceGroupNamePrefix-vmss"
        'w10clientResourceGroupName'            = "$primaryRegionResourceGroupNamePrefix-w10client"
        'wordpressResourceGroupName'            = "$primaryRegionResourceGroupNamePrefix-wordpress"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}