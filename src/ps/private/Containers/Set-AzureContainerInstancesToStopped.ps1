function Set-AzureContainerInstancesToStopped {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Stopped (for Cost Savings)"

    $containerGroups = @(
        @{ Name = $armParameters.adeLoadTestingGatlingContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingGrafanaContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingInfluxDbContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName },
        @{ Name = $armParameters.adeLoadTestingRedisContainerGroupName; ResourceGroup = $armParameters.adeAppLoadTestingResourceGroupName }
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