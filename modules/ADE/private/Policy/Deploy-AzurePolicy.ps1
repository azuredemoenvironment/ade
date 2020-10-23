function Deploy-AzurePolicy {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Policy' $armParameters -resourceLevel 'sub'
}