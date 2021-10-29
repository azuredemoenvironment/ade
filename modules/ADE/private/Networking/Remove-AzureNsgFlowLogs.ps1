function Remove-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    $location = $armParameters.azureRegion
    $nsgFlowLogEntries = @(
        'bastion'
        'management'
        'nTierWeb'
        'nTierApp'
        'vmss'
        'clientServices'
    )

    $nsgFlowLogEntries | ForEach-Object {
        $FlowLogName = $_ + 'SubnetNSGFlowLog'

        Write-Log "Deleting NSG Flow Log $FlowLogName"
        az network watcher flow-log delete --location $location -n $FlowLogName 
        Confirm-LastExitCode
    }
}