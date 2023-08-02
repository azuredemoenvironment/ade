function Remove-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    $location = $armParameters.azureRegion
    $nsgFlowLogEntries = @(
        'app-vm'
        'app-vmss'
        'app-Sql'
        'web-vm'
        'web-vmss'
        'applicationgateway'
        'bastion'
        'dataIngestorservice'
        'dataReporterservice'
        'eventIngestorservice'
        'inspectorgadget-sql'
        'userservice'
        'vnetintegration'
    )

    $nsgFlowLogEntries | ForEach-Object {
        $FlowLogName = $_ + 'SubnetNSGFlowLog'

        Write-Log "Deleting NSG Flow Log $FlowLogName"
        az network watcher flow-log delete --location $location -n $FlowLogName 
        Confirm-LastExitCode
    }
}