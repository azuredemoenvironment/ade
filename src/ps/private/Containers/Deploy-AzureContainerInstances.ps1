function Deploy-AzureContainerInstances {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Instances' $armParameters -resourceLevel 'sub' -bicep
}