function Deploy-AzureAppServices {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Services' $armParameters -resourceLevel 'sub' -bicep
}