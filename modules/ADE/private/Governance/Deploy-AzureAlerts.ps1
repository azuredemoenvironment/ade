function Deploy-AzureAlerts {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Alerts' $armParameters -resourceLevel 'sub' -bicep
}