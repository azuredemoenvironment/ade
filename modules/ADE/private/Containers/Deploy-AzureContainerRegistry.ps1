function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Registry' $armParameters -resourceGroupName $armParameters.containerRegistryResourceGroupName
}