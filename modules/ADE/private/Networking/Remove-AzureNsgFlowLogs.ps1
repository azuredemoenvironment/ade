function Remove-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    $location = $armParameters.defaultPrimaryRegion
    $nsgFlowLogEntries = @(
        'azureBastion'
        'management'
        'directoryServices'
        'developer'
        'ntierWeb'
        'ntierDB'
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