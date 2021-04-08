function Deploy-AzureActivityLog {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Activity Log' $armParameters -resourceLevel 'sub' -bicep
}