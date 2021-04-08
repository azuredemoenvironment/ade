function Deploy-AzureAppServicePlanToPrimaryRegion {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service Plan' $armParameters -resourceGroupName $armParameters.appServicePlanResourceGroupName -bicep
}