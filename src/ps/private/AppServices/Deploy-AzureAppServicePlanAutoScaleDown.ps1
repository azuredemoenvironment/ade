function Deploy-AzureAppServicePlanAutoScaleDown {
    param(
        [object] $armParameters
    )
        
    Write-ScriptSection "Initializing Azure App Service Plan Nightly Scale Down Deployment"

    #scale down app service plan from premium 1 v2 to basic
    $appServicePlanResourceGroupName = $armParameters.appServicePlanResourceGroupName
    $appServicePlanName = $armParameters.appServicePlanName
    az appserviceplan update -g $appServicePlanResourceGroupName -n $appServicePlanName --sku B1
    Confirm-LastExitCode

    Write-ScriptSection "Finished Azure App Service Plan Scale Down Deployment"
}