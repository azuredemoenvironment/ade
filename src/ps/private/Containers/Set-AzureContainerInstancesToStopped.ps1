function Set-AzureContainerInstancesToStopped {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Stopped (for Cost Savings)"

    $containerGroups = @(
        @{ Name = $armParameters.loadTestingGatlingContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingGrafanaContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingInfluxDbContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.loadTestingRedisContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName }
    )
    
    $containerGroups | ForEach-Object {
        $name = $_.Name
        $rg = $_.ResourceGroup
        
        Write-Log "Stopping $name in resource group $rg"

        az container stop --resource-group $rg --name $name
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Stopped (for Cost Savings)"
}