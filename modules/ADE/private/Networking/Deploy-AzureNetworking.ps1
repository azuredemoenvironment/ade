function Deploy-AzureNetworking {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Networking' $armParameters -resourceLevel 'sub' -bicep
}