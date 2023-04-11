function Set-AzureContainerInstancesToStarted {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Started"

    $containerGroups = @(
        @{ Name = $armParameters.loadTestingGatlingContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingGrafanaContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingInfluxDbContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingRedisContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName }
    )
    
    $containerGroups | ForEach-Object {
        $name = $_.Name
        $rg = $_.ResourceGroup

        Write-Log "Starting $name in resource group $rg"

        az container start --resource-group $rg --name $name
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Started"
}