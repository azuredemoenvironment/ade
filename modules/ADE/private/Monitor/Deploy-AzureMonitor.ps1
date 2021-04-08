function Deploy-AzureMonitor {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Monitor' $armParameters -resourceGroupName $armParameters.monitorResourceGroupName -bicep

}