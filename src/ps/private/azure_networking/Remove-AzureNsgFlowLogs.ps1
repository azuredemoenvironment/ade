function Remove-AzureNsgFlowLogs {
    param(
        [object] $armParameters
    )

    $location = $armParameters.azureRegion
    $nsgFlowLogEntries = @(
        'adeApp-vm'
        'adeApp-vmss'
        'adeAppSql'
        'adeWeb-vm'
        'adeWeb-vmss'
        'applicationGateway'
        'bastion'
        'dataIngestorService'
        'dataReporterService'
        'eventIngestorService'
        'inspectorGadgetSql'
        'userService'
        'vnetIntegration'
    )

    $nsgFlowLogEntries | ForEach-Object {
        $FlowLogName = $_ + 'SubnetNSGFlowLog'

        Write-Log "Deleting NSG Flow Log $FlowLogName"
        az network watcher flow-log delete --location $location -n $FlowLogName 
        Confirm-LastExitCode
    }
}