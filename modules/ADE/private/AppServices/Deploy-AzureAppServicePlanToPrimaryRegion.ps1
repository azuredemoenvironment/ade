function Deploy-AzureAppServicePlanToPrimaryRegion {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service Plan Primary Region' $armParameters -resourceGroupName $armParameters.primaryRegionAppServicePlanResourceGroupName
}