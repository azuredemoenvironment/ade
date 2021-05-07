function Deploy-AzureResourceGroups {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Resource Groups' $armParameters -resourceLevel 'sub' -bicep

}