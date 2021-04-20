function Deploy-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Deploying Azure NSG Flow Logs"

    # Standard Names
    $nsgFlowLogStorageAccountResourceGroupName = $armParameters.monitorResourceGroupName
    $nsgFlowLogStorageAccountName = $armParameters.nsgFlowLogsStorageAccountName

    # Shared Tags
    $tag1 = 'environment=production'
    $tag2 = 'function=monitoring and diagnostics'
    $tag3 = 'costCenter=it'

    Write-Status "Creating NSG Flow Logs"
    $location = $armParameters.defaultPrimaryRegion
    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $monitorResourceGroupName = $armParameters.monitorResourceGroupName
    $logAnalyticsWorkspaceName = $armParameters.logAnalyticsWorkspaceName
    $nsgFlowLogStorageAccountID = az storage account show -g $nsgFlowLogStorageAccountResourceGroupName -n $nsgFlowLogStorageAccountName --query id --output tsv
    $logAnalyticsWorkspaceID = az monitor log-analytics workspace show -g $monitorResourceGroupName --workspace-name $logAnalyticsWorkspaceName --query id --output tsv
    
    $nsgFlowLogEntries = @(
        @{ NsgName = $armParameters.azureBastionSubnetNSGName; FlowLogName = 'bastion' }
        @{ NsgName = $armParameters.managementSubnetNSGName; FlowLogName = 'management' }
        @{ NsgName = $armParameters.nTierWebSubnetNSGName; FlowLogName = 'nTierWeb' }
        @{ NsgName = $armParameters.nTierAppSubnetNSGName; FlowLogName = 'nTierApp' }
        @{ NsgName = $armParameters.vmssSubnetNSGName; FlowLogName = 'vmss' }
        @{ NsgName = $armParameters.clientServicesSubnetNSGName; FlowLogName = 'clientServices' }
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