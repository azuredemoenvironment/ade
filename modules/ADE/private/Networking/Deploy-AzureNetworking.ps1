function Deploy-AzureNetworking {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Networking' $armParameters -resourceGroupName $armParameters.networkingResourceGroupName
}