function Deploy-AdeAzureAppServices {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Services: ADE App' $armParameters -resourceGroupName $armParameters.adeAppAppServicesResourceGroupName -bicep
}