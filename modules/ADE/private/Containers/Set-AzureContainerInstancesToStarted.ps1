function Set-AzureContainerInstancesToStarted {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Started"

    $aliasRegion = $armParameters.aliasRegion
    $containerGroupResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName

    $containerGroups = @(
        "ci-ade-$aliasRegion-adeloadtesting-redis",
        "ci-ade-$aliasRegion-adeloadtesting-influxdb",
        "ci-ade-$aliasRegion-adeloadtesting-grafana",
        "ci-ade-$aliasRegion-adeloadtesting-gatling"
    )
    
    $containerGroups | ForEach-Object {
        Write-Log "Starting $_"

        az container start --resource-group $containerGroupResourceGroup --name $_
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Started"
}