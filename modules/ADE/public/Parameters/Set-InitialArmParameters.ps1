function Set-InitialArmParameters {
    param(
        [string] $alias,
        [string] $email,
        [string] $resourceUserName,
        [string] $rootDomainName,
        [string] $localNetworkRange,
        [string] $azureRegion,
        [string] $azurePairedRegion,
        [string] $module,
        [bool] $overwriteParameterFiles,
        [bool] $skipConfirmation
    )
    
    # Initial Parameter Setup
    $azureRegionShortName = Get-RegionShortName $azureRegion
    $azurePairedRegionShortName = Get-RegionShortName $azurePairedRegion
    $aliasRegion = "$alias-$azureRegionShortName".ToLowerInvariant()
    $aliasPairedRegion = "$alias-$azurePairedRegionShortName".ToLowerInvariant()

    $azureRegionResourceGroupNamePrefix = "rg-ade-$aliasRegion"
    $PairedRegionResourceGroupNamePrefix = "rg-ade-$aliasPairedRegion"
    $sourceAddressPrefix = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    $acrName = "acr-ade-$aliasRegion-001".replace('-', '')

    Write-Log 'Gathering User Information from az'
    $adSignedInUser = az ad signed-in-user show | ConvertFrom-Json

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'aliasRegion'                           = $aliasRegion
        'aliasPairedRegion'                     = $aliasPairedRegion
        'contactEmailAddress'                   = $email
        'azureRegion'                           = $azureRegion
        'azurePairedRegion'                     = $azurePairedRegion
        'deployAzureFirewall'                   = 'false'
        'deployVpnGateway'                      = 'false'
        'module'                                = $module
        'overwriteParameterFiles'               = $overwriteParameterFiles
        'rootDomainName'                        = $rootDomainName
        'skipConfirmation'                      = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                 = "sa-$aliasRegion-aciwp".replace('-', '')              
        'adminUserName'                         = $resourceUserName
        'aksClusterDNSName'                     = "aks-$aliasRegion-01-dns"
        'aksClusterName'                        = "aks-$aliasRegion-01"
        'azureActiveDirectoryUserID'            = $adSignedInUser.objectId              
        'localNetworkGatewayAddressPrefix'      = $localNetworkRange
        'logAnalyticsWorkspaceName'             = "log-ade-$aliasRegion-001"        
        'nTierHostName'                         = "ntier.$rootDomainName"               
        'sourceAddressPrefix'                   = $sourceAddressPrefix        
        'sslCertificateName'                    = $rootDomainName    

        # Required for Deploy-AzureAppServicePlanScaleDown.ps1
        'appServicePlanName'                    = "plan-ade-$aliasRegion-001"

        # Required for Deploy-AzureDns.ps1
        'applicationGatewayPublicIPAddressName' = "pip-ade-$aliasRegion-appgw001"

        # Required for Deploy-AzureGovernance.ps1
        'appConfigResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-appconfiguration"
        'identityResourceGroupName'             = "$azureRegionResourceGroupNamePrefix-identity"
        'keyVaultResourceGroupName'             = "$azureRegionResourceGroupNamePrefix-keyvault"
        'monitorResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-monitor"
        'activityLogDiagnosticsName'            = "subscriptionActivityLog"
        'adeInitiativeDefinition'               = "policy-ade-$aliasRegion-adeinitiative"
        'applicationGatewayManagedIdentityName' = "id-ade-$aliasRegion-applicationgateway"
        'containerRegistryManagedIdentityName'  = "id-ade-$aliasRegion-containerregistry"
        'containerRegistrySPNName'              = "spn-ade-$aliasRegion-containerregistry"          
        'githubActionsSPNName'                  = "spn-ade-$aliasRegion-githubactions"
        'restAPISPNName'                        = "spn-ade-$aliasRegion-restapi"
        'keyVaultName'                          = "kv-ade-$aliasRegion-001"

        # Required for Deploy-AzureContainerRegistry.ps1
        'containerRegistryResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-containerregistry"
        'acrName'                               = $acrName
        'containerRegistryLoginServer'          = "$acrName.azurecr.io"

        # Required for Deploy-AzureDatabases.ps1
        'adeAppSqlResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-adeappdb"
        'inspectorGadgetResourceGroupName'      = "$azureRegionResourceGroupNamePrefix-inspectorgadget"

        # Required for Deploy-AzureNetworking.ps1
        'networkingResourceGroupName'           = "$azureRegionResourceGroupNamePrefix-networking"

        # Required for Deploy-AzureVirtualMachines.ps1
        'jumpboxResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-jumpbox"   
        'nTierResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-ntier"
        'vmssResourceGroupName'                 = "$azureRegionResourceGroupNamePrefix-vmss"
        'w10clientResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-w10client"

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
        'adeAppAppServicesResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-adeappweb"
        'adeAppLoadTestingResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-adeapploadtesting"
        'aksNodeResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                  = "$azureRegionResourceGroupNamePrefix-aks"        
        'applicationGatewayResourceGroupName'   = "$azureRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-appserviceplan"
        'cognitiveServicesResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-cognitiveservices"        
        'dnsResourceGroupName'                  = "$azureRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'         = "$azureRegionResourceGroupNamePrefix-imageresizer"        
        'trafficManagerResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-trafficmanager"        
        'wordpressResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-wordpress"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}