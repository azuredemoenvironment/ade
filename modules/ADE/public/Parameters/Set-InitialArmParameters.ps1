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
    $currentAccount = az account show | ConvertFrom-Json
    $adSignedInUser = az ad signed-in-user show | ConvertFrom-Json

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'aliasRegion'                           = $aliasRegion
        'aliasPairedRegion'                     = $aliasPairedRegion
        'contactEmailAddress'                   = $email
        'azureRegion'                           = $azureRegion
        'azurePairedRegion'                     = $azurePairedRegion
        'deployAzureFirewall'                   = 'true'
        'deployAzureVpnGateway'                 = 'false'
        'module'                                = $module
        'overwriteParameterFiles'               = $overwriteParameterFiles
        'rootDomainName'                        = $rootDomainName
        'skipConfirmation'                      = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                 = "sa-$aliasRegion-aciwp".replace('-', '')
        'acrName'                               = $acrName        
        'adminUserName'                         = $resourceUserName
        'aksClusterDNSName'                     = "aks-$aliasRegion-01-dns"
        'aksClusterName'                        = "aks-$aliasRegion-01"        
        'azureActiveDirectoryTenantID'          = $currentAccount.tenantId
        'azureActiveDirectoryUserID'            = $adSignedInUser.objectId   
        'containerRegistryLoginServer'          = "$acrName.azurecr.io"    
        'localNetworkGatewayAddressPrefix'      = $localNetworkRange
        'logAnalyticsWorkspaceName'             = "log-ade-$aliasRegion-001"        
        'nTierHostName'                         = "ntier.$rootDomainName"               
        'sourceAddressPrefix'                   = $sourceAddressPrefix        
        'sslCertificateName'                    = $rootDomainName    

        # Required for Deploy-AzureGovernance.ps1
        'monitorResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-monitor"
        'appConfigResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-appconfiguration"
        'identityResourceGroupName'             = "$azureRegionResourceGroupNamePrefix-identity"
        'keyVaultResourceGroupName'             = "$azureRegionResourceGroupNamePrefix-keyvault"
        'activityLogDiagnosticsName'            = "subscriptionActivityLog"
        'adeInitiativeDefinition'               = "policy-ade-$aliasRegion-adeinitiative"
        'applicationGatewayManagedIdentityName' = "id-ade-$aliasRegion-agw"
        'containerRegistryManagedIdentityName'  = "id-ade-$aliasRegion-acr"
        'containerRegistrySPNName'              = "spn-ade-$aliasRegion-acr"          
        'githubActionsSPNName'                  = "spn-ade-$aliasRegion-gha"
        'restAPISPNName'                        = "spn-ade-$aliasRegion-restapi"
        'keyVaultName'                          = "kv-ade-$aliasRegion-001"

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
        'adeAppAppServicesResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-adeappweb"
        'adeAppLoadTestingResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-adeapploadtesting"
        'adeAppSqlResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-adeappdb"
        'aksNodeResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                  = "$azureRegionResourceGroupNamePrefix-aks"        
        'applicationGatewayResourceGroupName'   = "$azureRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-appserviceplan"
        'cognitiveServicesResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-cognitiveservices"
        'containerRegistryResourceGroupName'    = "$azureRegionResourceGroupNamePrefix-containerregistry"
        'dnsResourceGroupName'                  = "$azureRegionResourceGroupNamePrefix-dns"
        'imageResizerResourceGroupName'         = "$azureRegionResourceGroupNamePrefix-imageresizer"
        'inspectorGadgetResourceGroupName'      = "$azureRegionResourceGroupNamePrefix-inspectorgadget"
        'jumpboxResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-jumpbox"   
        'networkingResourceGroupName'           = "$azureRegionResourceGroupNamePrefix-networking"
        'nTierResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-ntier"
        'trafficManagerResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-trafficmanager"
        'vmssResourceGroupName'                 = "$azureRegionResourceGroupNamePrefix-vmss"
        'w10clientResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-w10client"
        'wordpressResourceGroupName'            = "$azureRegionResourceGroupNamePrefix-wordpress"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}