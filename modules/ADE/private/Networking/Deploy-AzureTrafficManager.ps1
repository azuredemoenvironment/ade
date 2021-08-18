function Deploy-AzureTrafficManager {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Traffic Manager' $armParameters -resourceGroupName $armParameters.trafficManagerResourceGroupName
}