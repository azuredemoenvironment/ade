function Remove-AzureResourceGroups {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Resource Groups"

    # ORDER MATTERS!!!
    $resourceGroupsToRemove = @(
        $armParameters.dnsResourceGroupName
        $armParameters.appServiceResourceGroupName
        # $armParameters.inspectorGadgetResourceGroupName
        # $armParameters.adeAppServicesResourceGroupName
        # $armParameters.appServicePlanResourceGroupName         
        $armParameters.adeAppLoadTestingResourceGroupName
        # $armParameters.adeAppVmssResourceGroupName
        # $armParameters.adeAppVmResourceGroupName
        # $armParameters.jumpboxResourceGroupName
        # $armParameters.proximityPlacementGroupResourceGroupName
        $armParameters.virtualMachineResourceGroupName
        # $armParameters.adeAppSqlResourceGroupName
        $armParameters.databaseResourceGroupName
        # $armParameters.containerRegistryResourceGroupName
        $armParameters.containerResourceGroupName
        $armParameters.networkingResourceGroupName
        # $armParameters.keyVaultResourceGroupName
        # $armParameters.appConfigResourceGroupName
        $armParameters.securityResourceGroupName
        $armParameters.identityResourceGroupName
        # $armParameters.monitorResourceGroupName
        $armParameters.managementResourceGroupName
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

        Write-Log "Removed $_ Resource Group"
    }

    Write-ScriptSection "Finished Removing Azure Resource Groups"
}