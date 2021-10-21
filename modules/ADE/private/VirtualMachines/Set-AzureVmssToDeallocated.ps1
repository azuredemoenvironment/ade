function Set-AzureVmssToDeallocated {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Write-ScriptSection "Setting Azure VMSS to Deallocated (for Cost Savings)"

    $virtualMachineScaleSets = @(
        @{ Name = $armParameters.adeAppVmssName; ResourceGroup = $armParameters.adeAppVmssResourceGroupName },
        @{ Name = $armParameters.adeWebVmssName; ResourceGroup = $armParameters.adeAppVmssResourceGroupName }
    )

    $virtualMachineScaleSets | ForEach-Object {
        $name = $_.Name
        $rg = $_.ResourceGroup

        Write-Log "Allocating $name in resource group $rg"

        az vmss deallocate --resource-group $rg --name $name --no-wait
        Confirm-LastExitCode
    }    

    Write-Log "Finished Setting Azure VMSS to Deallocated"
}