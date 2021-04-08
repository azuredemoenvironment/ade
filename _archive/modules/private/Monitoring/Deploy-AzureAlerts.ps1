function Deploy-AzureAlerts {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Alerts' $armParameters -resourceGroupName $armParameters.monitorResourceGroupName -bicep
}