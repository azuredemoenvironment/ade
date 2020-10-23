function Deploy-AzureLogAnalytics {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Log Analytics' $armParameters -resourceGroupName $armParameters.logAnalyticsWorkspaceResourceGroupName
}