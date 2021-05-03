function Remove-AzureMonitorResourceGroup {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Log Analytics Resource Group"

    $monitorResourceGroupName = $armParameters.monitorResourceGroupName
    if (Confirm-AzureResourceExists 'group' $monitorResourceGroupName) {
        az group delete -n $monitorResourceGroupName -y
        Confirm-LastExitCode
    }

    Write-ScriptSection "Finished Removing Azure Monitor Resource Group"
}