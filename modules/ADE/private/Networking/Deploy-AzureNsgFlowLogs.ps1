function Deploy-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Deploying Azure NSG Flow Logs"

    # Standard Names
    $nsgFlowLogStorageAccountResourceGroupName = $armParameters.storageResourceGroupName
    $nsgFlowLogStorageAccountName = $armParameters.nsgFlowLogsStorageAccountName

    # Shared Tags
    $tag1 = 'Environment=Production'
    $tag2 = 'Function=Diagnostics'
    $tag3 = 'CostCenter=IT'

    Write-Status "Creating Storage Account $nsgFlowLogStorageAccountName for NSG Flow Logs"
    az storage account create -g $nsgFlowLogStorageAccountResourceGroupName -n $nsgFlowLogStorageAccountName --sku Standard_LRS --kind StorageV2 --access-tier Hot --https-only true --tags $tag1 $tag2 $tag3
    Confirm-LastExitCode


    Write-Status "Creating NSG Flow Logs"
    $location = $armParameters.defaultPrimaryRegion
    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $logAnalyticsWorkspaceResourceGroupName = $armParameters.logAnalyticsWorkspaceResourceGroupName
    $logAnalyticsWorkspaceName = $armParameters.logAnalyticsWorkspaceName
    $nsgFlowLogStorageAccountID = az storage account show -g $nsgFlowLogStorageAccountResourceGroupName -n $nsgFlowLogStorageAccountName --query id --output tsv
    $logAnalyticsWorkspaceID = az monitor log-analytics workspace show -g $logAnalyticsWorkspaceResourceGroupName --workspace-name $logAnalyticsWorkspaceName --query id --output tsv
    
    $nsgFlowLogEntries = @(
        @{ NsgName = $armParameters.azureBastionSubnetNetworkSecurityGroupName; FlowLogName = 'azureBastion' }
        @{ NsgName = $armParameters.managementSubnetNetworkSecurityGroupName; FlowLogName = 'management' }
        @{ NsgName = $armParameters.directoryServicesSubnetNetworkSecurityGroupName; FlowLogName = 'directoryServices' }
        @{ NsgName = $armParameters.developerSubnetNetworkSecurityGroupName; FlowLogName = 'developer' }
        @{ NsgName = $armParameters.nTierWebSubnetNetworkSecurityGroupName; FlowLogName = 'ntierWeb' }
        @{ NsgName = $armParameters.nTierDBSubnetNetworkSecurityGroupName; FlowLogName = 'ntierDB' }
        @{ NsgName = $armParameters.vmssSubnetNetworkSecurityGroupName; FlowLogName = 'vmss' }
        @{ NsgName = $armParameters.clientServicesSubnetNetworkSecurityGroupName; FlowLogName = 'clientServices' }
    )

    $nsgFlowLogEntries | ForEach-Object {
        $NsgName = $_.NsgName
        $FlowLogName = $_.FlowLogName + 'SubnetNSGFlowLog'

        Write-Log "Creating NSG Flow Log $FlowLogName"
        $NsgId = az network nsg show -g $networkingResourceGroupName -n $NsgName --query id --output tsv
        Confirm-LastExitCode

        az network watcher flow-log create --location $location -n $FlowLogName --nsg $NsgId --storage-account $nsgFlowLogStorageAccountID --enabled true --format JSON --log-version 2 --retention 7 --traffic-analytics true --workspace $logAnalyticsWorkspaceID --tags $tag1 $tag2 $tag3
        Confirm-LastExitCode
    }

    Write-Log "Finished Deploying Azure NSG Flow Logs"
}