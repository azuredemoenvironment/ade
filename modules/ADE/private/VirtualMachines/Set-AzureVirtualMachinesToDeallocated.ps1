function Set-AzureVirtualMachinesToDeallocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Virtual Machines to Deallocated (for Cost Savings)"

    $virtualMachines = @(
        @{ Name = $armParameters.jumpboxName; ResourceGroup = $armParameters.jumpboxResourceGroupName },
        @{ Name = $armParameters.adeWebVm01Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.adeWebVm02Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.adeWebVm03Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.adeAppVm01Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.adeAppVm02Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName },
        @{ Name = $armParameters.adeAppVm03Name; ResourceGroup = $armParameters.adeAppVmResourceGroupName }
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