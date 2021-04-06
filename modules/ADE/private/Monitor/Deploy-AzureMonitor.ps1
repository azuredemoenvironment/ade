function Deploy-AzureMonitor {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Log Analytics' $armParameters -resourceGroupName $armParameters.monitorResourceGroupName -bicep

    Deploy-ArmTemplate 'Azure Application Insights' $armParameters -resourceGroupName $armParameters.monitorResourceGroupName -bicep

    Deploy-ArmTemplate 'Azure Activity Log' $armParameters -resourceLevel 'sub' -bicep
}