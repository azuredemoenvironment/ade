function Deploy-AzureAppServicePlanToPrimaryRegionScaleDown {
    param(
        [object] $armParameters
    )
        
    Write-ScriptSection "Initializing Azure App Service Plan Scale Down Deployment"

    #scale down app service plan from premium 1 v3 to premium 1 v2
    $primaryRegionAppServicePlanResourceGroupName = $armParameters.primaryRegionAppServicePlanResourceGroupName
    $primaryRegionAppServicePlanName = $armParameters.primaryRegionAppServicePlanName
    az appservice plan update -g $primaryRegionAppServicePlanResourceGroupName -n $primaryRegionAppServicePlanName --sku P1V2
    Confirm-LastExitCode

    Write-ScriptSection "Finished Azure App Service Plan Scale Down Deployment"
}