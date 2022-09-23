function Deploy-AzureAppServicePlanAutoScaleUp {
    param(
        [object] $armParameters
    )
        
    Write-ScriptSection "Initializing Azure App Service Plan Morning Scale Up Deployment"

    #scale up app service plan from basic to p1 v2
    $appServicePlanResourceGroupName = $armParameters.appServicePlanResourceGroupName
    $appServicePlanName = $armParameters.appServicePlanName
    az appserviceplan update -g $appServicePlanResourceGroupName -n $appServicePlanName --sku P1V2
    Confirm-LastExitCode

    Write-ScriptSection "Finished Azure App Service Plan Morning Scale Up Deployment"
}