function Set-AzureContainerInstancesToStarted {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Started"

    $containerGroups = @(
        @{ Name = $armParameters.adeLoadTestingGatlingContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingGrafanaContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingInfluxDbContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingRedisContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName }
    )
    
    $containerGroups | ForEach-Object {
        Write-Log "Starting $_"

        az container start --resource-group $containerGroupResourceGroup --name $_
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Started"
}