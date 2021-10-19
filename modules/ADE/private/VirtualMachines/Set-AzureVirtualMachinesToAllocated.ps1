function Set-AzureVirtualMachinesToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Virtual Machines to Allocated"

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

        Write-Log "Allocating $name in resource group $rg"

        az vm start --resource-group $rg --name $name --no-wait
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Virtual Machines to Allocated"
}