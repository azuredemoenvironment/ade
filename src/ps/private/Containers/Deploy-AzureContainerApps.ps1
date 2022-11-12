function Deploy-AzureContainerApps {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Apps' $armParameters -resourceLevel 'sub' -bicep
}