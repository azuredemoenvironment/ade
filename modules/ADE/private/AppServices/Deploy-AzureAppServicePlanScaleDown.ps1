function Deploy-AzureAppServicePlanToPrimaryRegionScaleDown {
    param(
        [object] $armParameters
    )
        
    Write-ScriptSection "Initializing Azure App Service Plan Scale Down Deployment"

    #scale down app service plan from premium 1 v3 to premium 1 v2
    $appServicePlanResourceGroupName = $armParameters.appServicePlanResourceGroupName
    $appServicePlanName = $armParameters.appServicePlanName
    az appservice plan update -g $appServicePlanResourceGroupName -n $appServicePlanName --sku P1V2
    Confirm-LastExitCode

    Write-ScriptSection "Finished Azure App Service Plan Scale Down Deployment"
}