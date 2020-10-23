function Deploy-AzureKubernetesServices {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Kubernetes Services' $armParameters -resourceGroupName $armParameters.aksResourceGroupName
}