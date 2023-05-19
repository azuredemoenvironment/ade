function Deploy-AzureAlerts {
    param(
        [object] $armParameters
    )

    # Deploy the Azure Management Bicep Template at the Subscription Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Alerts' $armParameters -resourceLevel 'sub' -bicep
}