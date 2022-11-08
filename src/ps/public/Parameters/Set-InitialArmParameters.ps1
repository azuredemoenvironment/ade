function Set-InitialArmParameters {
    param(
        [string] $alias,
        [string] $email,
        [string] $resourceUserName,
        [string] $rootDomainName,
        [string] $localNetworkRange,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [string] $wildcardCertificatePath,
        [string] $azureRegion,
        [string] $azurePairedRegion,
        [string] $module,
        [string] $scriptsBaseUri,
        [bool] $isDeploying,
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
    #runbook start time parameter
     #Required for autoscaling apps, vms, containerServices
     #convert a specific time to UTC here and then use it in automation
    #$allocationStartTime = ((Get-Date -Hour 8).AddDays(1)).ToUniversalTime() 
    #$deallocationStartTIme = (Get-Date - Hour 19).ToUniversalTime()


    $certificateBase64String = ''
    if ($secureCertificatePassword -ne $null -and $wildcardCertificatePath -ne $null) {
        $certificateBase64String = Convert-WildcardCertificateToBase64String $secureCertificatePassword $wildcardCertificatePath
    }

    if ($isDeploying -and [string]::IsNullOrWhiteSpace($certificateBase64String)) {
        throw "A base64 encoded certificate is required to proceed. Ensure you have wildcard.pfx in the data directory, and have supplied the appropriate certificate password."
    }
    
    $plainTextResourcePassword = ''
    if ($secureResourcePassword -ne $null) {
        $plainTextResourcePassword = ConvertFrom-SecureString -SecureString $secureResourcePassword -AsPlainText
    }

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'aliasRegion'                              = $aliasRegion
        'aliasPairedRegion'                        = $aliasPairedRegion
        'contactEmailAddress'                      = $email
        'scriptsBaseUri'                           = $scriptsBaseUri
        'azureRegion'                              = $azureRegion
        'azurePairedRegion'                        = $azurePairedRegion
        'deployAzureFirewall'                      = 'false'
        'deployVpnGateway'                         = 'false'
        'module'                                   = $module
        'overwriteParameterFiles'                  = $overwriteParameterFiles
        'rootDomainName'                           = $rootDomainName
        'skipConfirmation'                         = $skipConfirmation

        # Generated Parameters        
        'adminUserName'                            = $resourceUserName
        'certificateBase64String'                  = $certificateBase64String
        'localNetworkGatewayAddressPrefix'         = $localNetworkRange
        'logAnalyticsWorkspaceName'                = "log-ade-$aliasRegion-001"
        'resourcePassword'                         = $plainTextResourcePassword
        'sourceAddressPrefix'                      = $sourceAddressPrefix
        'sslCertificateName'                       = $rootDomainName
        #add alphabetically

        # Required for Deploy-AzureAppServicePlanScaleDown.ps1
        'appServicePlanName'                       = "plan-ade-$aliasRegion-001"

        # Required for Deploy-AzureContainerRegistry.ps1
        'acrName'                                  = $acrName
        'containerRegistryLoginServer'             = "$acrName.azurecr.io"

        # Required for Deploy-AzureGovernance.ps1               
        'keyVaultKeyName'                          = "containerRegistry"
        'keyVaultName'                             = "kv-ade-$aliasRegion-001"

        # Required for Remove-AzureActivityLogDiagnostics.ps1
        'activityLogDiagnosticsName'               = "subscriptionActivityLog"

        # Required for Remove-AzureCostManagementBudget.ps1
        'adeBudgetName'                            = "budget-ade-$aliasRegion-monthly"

        # Required for Remove-AzurePolicyAssignmentsAndDefinitions.ps1
        'adeInitiativeDefinition'                  = "policy-ade-$aliasRegion-adeinitiative"

        # Required for Set-AzureContainerInstancesToStarted.ps1 and Set-AzureContainerInstancesToStopped.ps1
        'adeLoadTestingGatlingContainerGroupName'  = "ci-ade-$aliasRegion-adeloadtesting-gatling"
        'adeLoadTestingGrafanaContainerGroupName'  = "ci-ade-$aliasRegion-adeloadtesting-grafana"
        'adeLoadTestingInfluxDbContainerGroupName' = "ci-ade-$aliasRegion-adeloadtesting-influxdb"
        'adeLoadTestingRedisContainerGroupName'    = "ci-ade-$aliasRegion-adeloadtesting-redis"
        
        # Required for Set-AzureFirewallToAllocated.ps1 and Set-AzureFirewallToDeallocated.ps1
        'azureFirewallPublicIpAddressName'         = "pip-ade-$aliasRegion-fw001"
        'azureFirewallName'                        = "fw-ade-$aliasRegion-001"        
        'virtualNetwork001Name'                    = "vnet-ade-$aliasRegion-001"

        # Required for Set-AzureVmssToAllocated.ps1 and Set-AzureVmssToAllocated.ps1
        'adeAppVmssName'                           = "vmss-ade-$aliasRegion-adeapp-vmss"
        'adeWebVmssName'                           = "vmss-ade-$aliasRegion-adeweb-vmss"

        # Required for Set-AzureVirtualMachinesToAllocated.ps1 and Set-AzureVirtualMachinesToDellocated.ps1
        'jumpboxName'                              = "vm-jumpbox01"
        'adeWebVm01Name'                           = "vm-ade-$aliasRegion-adeweb01"
        'adeWebVm02Name'                           = "vm-ade-$aliasRegion-adeweb02"
        'adeWebVm03Name'                           = "vm-ade-$aliasRegion-adeweb03"
        'adeAppVm01Name'                           = "vm-ade-$aliasRegion-adeapp01"
        'adeAppVm02Name'                           = "vm-ade-$aliasRegion-adeapp02"
        'adeAppVm03Name'                           = "vm-ade-$aliasRegion-adeapp03"
  
        # Resource Group Names
        'adeAppAksNodeResourceGroupName'           = "$azureRegionResourceGroupNamePrefix-adeappaks-node"
        'adeAppAksResourceGroupName'               = "$azureRegionResourceGroupNamePrefix-adeappaks"
        'adeAppAppServicesResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-adeappweb"
        'adeAppLoadTestingResourceGroupName'       = "$azureRegionResourceGroupNamePrefix-adeapploadtesting"
        'adeAppSqlResourceGroupName'               = "$azureRegionResourceGroupNamePrefix-adeappdb"
        'adeAppVmResourceGroupName'                = "$azureRegionResourceGroupNamePrefix-adeappvm"
        'adeAppVmssResourceGroupName'              = "$azureRegionResourceGroupNamePrefix-adeappvmss"    
        'appConfigResourceGroupName'               = "$azureRegionResourceGroupNamePrefix-appconfig"
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
        'networkWatcherResourceGroupName'          = "NetworkWatcherRG"
        'proximityPlacementGroupResourceGroupName' = "$azureRegionResourceGroupNamePrefix-ppg"
        'azureAutomationResourceGroupName'         = "$azureRegionResourceGroupNamePrefix-automation"

       


    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.keyVaultResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}