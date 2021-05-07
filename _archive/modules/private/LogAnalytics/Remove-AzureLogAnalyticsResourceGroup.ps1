function Remove-AzureLogAnalyticsResourceGroup {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Log Analytics Resource Group"

    $logAnalyticsWorkspaceResourceGroupName = $armParameters.logAnalyticsWorkspaceResourceGroupName
    if (Confirm-AzureResourceExists 'group' $logAnalyticsWorkspaceResourceGroupName) {
        az group delete -n $logAnalyticsWorkspaceResourceGroupName -y
        Confirm-LastExitCode
    }

    Write-ScriptSection "Finished Removing Azure Log Analytics Resource Group"
}