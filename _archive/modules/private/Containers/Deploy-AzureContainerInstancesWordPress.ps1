function Deploy-AzureContainerInstancesWordPress {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Instances: WordPress' $armParameters -resourceGroupName $armParameters.wordpressResourceGroupName
}