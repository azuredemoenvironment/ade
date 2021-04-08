function Deploy-AzureAppServicePlanToSecondaryRegion {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure App Service Plan Secondary Region' $armParameters -resourceGroupName $armParameters.secondaryRegionAppServicePlanResourceGroupName  -region $armParameters.defaultSecondaryRegion
}