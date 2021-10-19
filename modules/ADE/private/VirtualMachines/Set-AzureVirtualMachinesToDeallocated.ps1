function Set-AzureVirtualMachinesToDeallocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Virtual Machines to Deallocated (for Cost Savings)"

    $virtualMachines = @(
        @{ Name = $armParameters.jumpboxName; ResourceGroup = $armParameters.jumpboxResourceGroupName },
        @{ Name = $armParameters.nTierWeb01Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.nTierWeb02Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.nTierWeb03Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.nTierApp01Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.nTierApp02Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.nTierApp03Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.w10clientName; ResourceGroup = $armParameters.w10clientResourceGroupName }
    )
    
    $virtualMachines | ForEach-Object {
        $name = $_.Name
        $rg = $_.ResourceGroup

        Write-Log "Deallocating $name in resource group $rg"

        az vm deallocate --resource-group $rg --name $name --no-wait
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Virtual Machines to Deallocated (for Cost Savings)"
}