function Set-AzureContainerInstancesToStopped {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Stopped (for Cost Savings)"

    $aliasRegion = $armParameters.aliasRegion
    $containerGroupResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName

    $containerGroups = @(
        "ci-ade-$aliasRegion-adeloadtesting-redis",
        "ci-ade-$aliasRegion-adeloadtesting-influxdb",
        "ci-ade-$aliasRegion-adeloadtesting-grafana",
        "ci-ade-$aliasRegion-adeloadtesting-gatling"
    )
    
    $containerGroups | ForEach-Object {
        Write-Log "Stopping $_"

        az container stop --resource-group $containerGroupResourceGroup --name $_
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Stopped (for Cost Savings)"
}