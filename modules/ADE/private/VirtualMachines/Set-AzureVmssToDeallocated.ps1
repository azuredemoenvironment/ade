function Set-AzureVmssToDeallocated {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Write-ScriptSection "Setting Azure VMSS to Deallocated (for Cost Savings)"
    az vmss deallocate -g $armParameters.vmssResourceGroupName -n $armParameters.vmssName
    Confirm-LastExitCode

    Write-Log "Finished Setting Azure VMSS to Deallocated"
}