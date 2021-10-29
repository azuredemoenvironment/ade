function Set-AzureVirtualMachinesToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Virtual Machines to Allocated"

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

        Write-Log "Allocating $name in resource group $rg"

        az vm start --resource-group $rg --name $name --no-wait
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Virtual Machines to Allocated"
}