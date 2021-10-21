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
        'aliasRegion'                              = $aliasRegion
        'aliasPairedRegion'                        = $aliasPairedRegion
        'contactEmailAddress'                      = $email
        'azureRegion'                              = $azureRegion
        'azurePairedRegion'                        = $azurePairedRegion
        'deployAzureFirewall'                      = 'false'
        'deployVpnGateway'                         = 'false'
        'module'                                   = $module
        'overwriteParameterFiles'                  = $overwriteParameterFiles
        'rootDomainName'                           = $rootDomainName
        'skipConfirmation'                         = $skipConfirmation

        # Generated Parameters
        'aciStorageAccountName'                    = "sa-$aliasRegion-aciwp".replace('-', '')              
        'adminUserName'                            = $resourceUserName
        'aksClusterDNSName'                        = "aks-$aliasRegion-01-dns"
        'aksClusterName'                           = "aks-$aliasRegion-01"
        'azureActiveDirectoryUserID'               = $adSignedInUser.objectId              
        'localNetworkGatewayAddressPrefix'         = $localNetworkRange
        'logAnalyticsWorkspaceName'                = "log-ade-$aliasRegion-001"        
        'nTierHostName'                            = "ntier.$rootDomainName"               
        'sourceAddressPrefix'                      = $sourceAddressPrefix        
        'sslCertificateName'                       = $rootDomainName    

        # Required for Deploy-AzureAppServicePlanScaleDown.ps1
        'appServicePlanName'                       = "plan-ade-$aliasRegion-001"

        # Required for Deploy-AzureDns.ps1
        'applicationGatewayPublicIPAddressName'    = "pip-ade-$aliasRegion-appgw001"

        # Required for Deploy-AzureGovernance.ps1
        'activityLogDiagnosticsName'               = "subscriptionActivityLog"
        'adeInitiativeDefinition'                  = "policy-ade-$aliasRegion-adeinitiative"
        'keyVaultName'                             = "kv-ade-$aliasRegion-001"

        # Required for Deploy-AzureContainerRegistry.ps1
        'acrName'                                  = $acrName
        'containerRegistryLoginServer'             = "$acrName.azurecr.io"

        # Required for Deploy-AzureDatabases.ps1        

        # Required for Deploy-AzureNetworking.ps1        

        # Required for Deploy-AzureVirtualMachines.ps1        

        # Required for Enable-HighCostAzureServices.ps1 and Disable-HighCostAzureServices.ps1
        'azureFirewallPublicIpAddressName'         = "pip-ade-$aliasRegion-fw001"
        'azureFirewallName'                        = "fw-ade-$aliasRegion-001"
        'jumpboxName'                              = "vm-jumpbox01"
        'adeWebVm01Name'                           = "vm-ade-$aliasRegion-adeweb01"
        'adeWebVm02Name'                           = "vm-ade-$aliasRegion-adeweb02"
        'adeWebVm03Name'                           = "vm-ade-$aliasRegion-adeweb03"
        'adeAppVm01Name'                           = "vm-ade-$aliasRegion-adeapp01"
        'adeAppVm02Name'                           = "vm-ade-$aliasRegion-adeapp02"
        'adeAppVm03Name'                           = "vm-ade-$aliasRegion-adeapp03"
        'adeAppVmssName'                           = "vmss-ade-$aliasRegion-adeapp-vmss"
        'adeWebVmssName'                           = "vmss-ade-$aliasRegion-adeweb-vmss"
        'virtualNetwork001Name'                    = "vnet-ade-${aliasRegion}-001"
        
        # Resource Group Names
        'adeAppAppServicesResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-adeappweb"
        'adeAppLoadTestingResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-adeapploadtesting"
        'adeAppSqlResourceGroupName'               = "$azureRegionResourceGroupNamePrefix-adeappdb"
        'adeAppVmResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-adeappvm"
        'adeAppVmssResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-adeappvmss"
        'aksNodeResourceGroupName'                 = "$azureRegionResourceGroupNamePrefix-aks-node"
        'aksResourceGroupName'                     = "$azureRegionResourceGroupNamePrefix-aks"        
        'appConfigResourceGroupName'               = "$azureRegionResourceGroupNamePrefix-appconfiguration"
        'applicationGatewayResourceGroupName'      = "$azureRegionResourceGroupNamePrefix-applicationgateway"
        'appServicePlanResourceGroupName'          = "$azureRegionResourceGroupNamePrefix-appserviceplan"     
        'containerRegistryResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-containerregistry"
        'dnsResourceGroupName'                     = "$azureRegionResourceGroupNamePrefix-dns"
        'identityResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-identity"     
        'inspectorGadgetResourceGroupName'         = "$azureRegionResourceGroupNamePrefix-inspectorgadget"
        'jumpboxResourceGroupName'                 = "$azureRegionResourceGroupNamePrefix-jumpbox"   
        'keyVaultResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-keyvault"
        'monitorResourceGroupName'                 = "$azureRegionResourceGroupNamePrefix-monitor"
        'networkingResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-networking"
        'proximityPlacementGroupResourceGroupName' = "$azureRegionResourceGroupNamePrefix-proximityplacementgroup"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}