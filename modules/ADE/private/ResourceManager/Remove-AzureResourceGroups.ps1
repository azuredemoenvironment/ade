function Remove-AzureResourceGroups {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Resource Groups"

    # ORDER MATTERS!!!
    $resourceGroupsToRemove = @(
        $armParameters.applicationGatewayResourceGroupName
        $armParameters.trafficManagerResourceGroupName
        $armParameters.inspectorGadgetResourceGroupName
        $armParameters.adeAppAppServicesResourceGroupName
        $armParameters.appServicePlanResourceGroupName
        $armParameters.aksResourceGroupName   
        $armParameters.vmssResourceGroupName
        $armParameters.ntierResourceGroupName
        $armParameters.w10clientResourceGroupName
        $armParameters.jumpboxResourceGroupName
        $armParameters.adeAppLoadTestingResourceGroupName
        $armParameters.adeAppSqlResourceGroupName
        $armParameters.containerRegistryResourceGroupName
        $armParameters.networkingResourceGroupName
        $armParameters.appConfigResourceGroupName
        $armParameters.identityResourceGroupName
    )

    $resourceGroupsToRemove | ForEach-Object {
        $resourceGroupExists = Confirm-AzureResourceExists 'group' $_
        if (-not $resourceGroupExists) {
            Write-Log "The resource group $_ does not exist; skipping."
            return
        }
        
        Write-Log "Removing $_ Resource Group"

        az group delete -n $_ -y
        Confirm-LastExitCode

        Write-Log "Removed $_ Resourced Group"
    }

    Write-ScriptSection "Finished Removing Azure Resource Groups"
}