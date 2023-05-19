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
    $appGlobalEnvironment = "$workload-$environment-global".ToLowerInvariant()
    $dnsZoneResourceGroupName = "rg-ade-jowaddel-prod-global-dns"
    $acrName = "acr-$appEnvironment".replace('-', '')
    $ownerName = $(az account show --query "user.name" --output tsv)
    $sourceAddressPrefix = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content    
        
    $certificateBase64String = ''
    if ($secureCertificatePassword -ne $null -and $wildcardCertificatePath -ne $null) {
        $certificateBase64String = Convert-WildcardCertificateToBase64String $secureCertificatePassword $wildcardCertificatePath
    }

    $plainTextResourcePassword = ''
    if ($secureResourcePassword -ne $null) {
        $plainTextResourcePassword = ConvertFrom-SecureString -SecureString $secureResourcePassword -AsPlainText
    }

    Write-Log 'Generating ARM Parameters'

    $armParameters = @{
        # Standard Parameters
        'appEnvironment'                           = $appEnvironment
        'appGlobalEnvironment'                     = $appGlobalEnvironment
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
        'dnsZoneResourceGroupName'                 = $dnsZoneResourceGroupName
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

        # Required for Enable-AzureKubernetesServicesCluster.ps1 and Set-AzureKubernetesServicesClusterToStopped.ps1
        'aksClusterName'                           = "aks-$appEnvironment"

        # Required for Remove-AzureActivityLogDiagnostics.ps1
        'activityLogDiagnosticsName'               = "subscriptionactivitylog"

        # Required for Remove-AzureCostManagementBudget.ps1
        'budgetName'                            = "budget-$appEnvironment-monthly"

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
        'appServiceResourceGroupName'              = "rg-$appEnvironment-appservice"    
        'containerResourceGroupName'               = "rg-$appEnvironment-container"
        "databaseResourceGroupName"                = "rg-$appEnvironment-database"
        'managementResourceGroupName'              = "rg-$appEnvironment-management"
        'networkingResourceGroupName'              = "rg-$appEnvironment-networking"
        'networkWatcherResourceGroupName'          = "NetworkWatcherRG"
        'securityResourceGroupName'                = "rg-$appEnvironment-security"
        'virtualMachineResourceGroupName'          = "rg-$appEnvironment-virtualmachine"
    }

    if (Confirm-AzureResourceExists 'keyvault' $armParameters.securityResourceGroupName $armParameters.keyVaultName) {
        Set-AzureKeyVaultResourceId $armParameters
    }

    return $armParameters
}