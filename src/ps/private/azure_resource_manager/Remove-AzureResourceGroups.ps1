function Remove-AzureResourceGroups {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Resource Groups"

    # ORDER MATTERS!!!
    $resourceGroupsToRemove = @(
        $armParameters.appServiceResourceGroupName
        $armParameters.virtualMachineResourceGroupName
        $armParameters.databaseResourceGroupName
        $armParameters.containerResourceGroupName
        $armParameters.networkingResourceGroupName
        # $armParameters.securityResourceGroupName
        # $armParameters.managementResourceGroupName
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