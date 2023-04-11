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
        [bool] $overwriteParameterFiles,
        [bool] $skipConfirmation
    )
    
    # Initial Parameter Setup
    $workload = "ade-$alias"
    # TODO: This needs to be based on user input
    $environment = "prod"
    $azureRegionShortName = Get-RegionShortName $azureRegion
    $appEnvironment = "$workload-$environment-$azureRegionShortName".ToLowerInvariant()
    $acrName = "acr-$appEnvironment".replace('-', '')
    $certificateBase64String = ''
    if ($secureCertificatePassword -ne $null -and $wildcardCertificatePath -eq $null) {
        $certificateBase64String = Convert-WildcardCertificateToBase64String $secureCertificatePassword $wildcardCertificatePath
    }
    $ownerName = $(az account show --query "user.name" --output tsv)
    $plainTextResourcePassword = ''
    if ($secureResourcePassword -ne $null) {
        $plainTextResourcePassword = ConvertFrom-SecureString -SecureString $secureResourcePassword -AsPlainText
    }
    $sourceAddressPrefix = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content    

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'appEnvironment'                           = $appEnvironment
        'azurePairedRegion'                        = $azurePairedRegion
        'azureRegion'                              = $azureRegion
        'contactEmailAddress'                      = $email
        'deployFirewall'                           = 'true'
        'environment'                              = $environment
        'module'                                   = $module
        'overwriteParameterFiles'                  = $overwriteParameterFiles 
        'rootDomainName'                           = $rootDomainName
        'scriptsBaseUri'                           = $scriptsBaseUri
        'skipConfirmation'                         = $skipConfirmation

        # Generated Parameters        
        'adminUserName'                            = $resourceUserName
        'certificateBase64String'                  = $certificateBase64String
        'localNetworkGatewayAddressPrefix'         = $localNetworkRange
        'logAnalyticsWorkspaceName'                = "log-$appEnvironment"
        'ownerName'                                = $ownerName
        'resourcePassword'                         = $plainTextResourcePassword
        'sourceAddressPrefix'                      = $sourceAddressPrefix
        'sslCertificateName'                       = $rootDomainName

        # Required for Deploy-AzureAppServicePlanScaleDown.ps1
        'appServicePlanName'                       = "plan-$appEnvironment"

        # Required for Deploy-AzureContainerRegistry.ps1
        'acrName'                                  = $acrName
        'containerRegistryLoginServer'             = "$acrName.azurecr.io"

        # Required for Deploy-AzureGovernance.ps1               
        'keyVaultKeyName'                          = "containerRegistry"
        'keyVaultName'                             = "kv-$appEnvironment"

        # Required for Remove-AzureActivityLogDiagnostics.ps1
        'activityLogDiagnosticsName'               = "subscriptionActivityLog"

        # Required for Remove-AzureCostManagementBudget.ps1
        'adeBudgetName'                            = "budget-$appEnvironment-monthly"

        # Required for Remove-AzurePolicyAssignmentsAndDefinitions.ps1
        'adeInitiativeDefinition'                  = "policy-$appEnvironment-adeinitiative"

        # Required for Set-AzureContainerInstancesToStarted.ps1 and Set-AzureContainerInstancesToStopped.ps1
        'loadTestingGatlingContainerGroupName'  = "ci-$appEnvironment-loadtesting-gatling"
        'loadTestingGrafanaContainerGroupName'  = "ci-$appEnvironment-loadtesting-grafana"
        'loadTestingInfluxDbContainerGroupName' = "ci-$appEnvironment-loadtesting-influxdb"
        'loadTestingRedisContainerGroupName'    = "ci-$appEnvironment-loadtesting-redis"
        
        # Required for Set-AzureFirewallToAllocated.ps1 and Set-AzureFirewallToDeallocated.ps1
        'azureFirewallPublicIpAddressName'         = "pip-$appEnvironment-fw"
        'azureFirewallName'                        = "fw-$appEnvironment"        
        'hubVirtualNetworkName'                    = "vnet-$appEnvironment"

        # Required for Set-AzureVmssToAllocated.ps1 and Set-AzureVmssToAllocated.ps1
        'adeAppVmssName'                           = "vmss-$appEnvironment-adeapp-vmss"
        'adeWebVmssName'                           = "vmss-$appEnvironment-adeweb-vmss"

        # Required for Set-AzureVirtualMachinesToAllocated.ps1 and Set-AzureVirtualMachinesToDellocated.ps1
        'adeWebVm01Name'                           = "vm-$appEnvironment-adeweb01"
        'adeWebVm02Name'                           = "vm-$appEnvironment-adeweb02"
        'adeWebVm03Name'                           = "vm-$appEnvironment-adeweb03"
        'adeAppVm01Name'                           = "vm-$appEnvironment-adeapp01"
        'adeAppVm02Name'                           = "vm-$appEnvironment-adeapp02"
        'adeAppVm03Name'                           = "vm-$appEnvironment-adeapp03"
  
        # Resource Group Names
        'adeAppAksNodeResourceGroupName'           = "rg-$appEnvironment-adeappaks-node"
        'adeAppAksResourceGroupName'               = "rg-$appEnvironment-adeappaks"
        # 'adeAppServicesResourceGroupName'        = "rg-$appEnvironment-adeappweb"
        # 'adeAppLoadTestingResourceGroupName'     = "rg-$appEnvironment-adeapploadtesting"
        # 'adeAppSqlResourceGroupName'             = "rg-$appEnvironment-adeappdb"
        # 'adeAppVmResourceGroupName'              = "rg-$appEnvironment-adeappvm"
        # 'adeAppVmssResourceGroupName'            = "rg-$appEnvironment-adeappvmss"    
        'applicationGatewayResourceGroupName'      = "rg-$appEnvironment-applicationgateway"
        # 'appServicePlanResourceGroupName'        = "rg-$appEnvironment-appserviceplan"
        'appServiceResourceGroupName'              = "rg-$appEnvironment-appservice"    
        # 'containerRegistryResourceGroupName'     = "rg-$appEnvironment-containerregistry"
        'containerResourceGroupName'               = "rg-$appEnvironment-container"
        "databaseResourceGroupName"                = "rg-$appEnvironment-database"
        'dnsResourceGroupName'                     = "rg-$appEnvironment-dns"
        'identityResourceGroupName'                = "rg-$appEnvironment-identity"     
        # 'inspectorGadgetResourceGroupName'       = "rg-$appEnvironment-inspectorgadget"
        # 'jumpboxResourceGroupName'               = "rg-$appEnvironment-jumpbox"   
        'managementResourceGroupName'              = "rg-$appEnvironment-management"
        'networkingResourceGroupName'              = "rg-$appEnvironment-networking"
        'networkWatcherResourceGroupName'          = "NetworkWatcherRG"
        # 'proximityPlacementGroupResourceGroupName' = "rg-$appEnvironment-ppg"
        'securityResourceGroupName'                = "rg-$appEnvironment-security"
        'virtualMachineResourceGroupName'          = "rg-$appEnvironment-virtualmachine"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.securityResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}