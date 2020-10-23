function Set-AzureVmssToAllocated {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Write-ScriptSection "Setting Azure VMSS to Allocated"
    az vmss start -g $armParameters.vmssResourceGroupName -n $armParameters.vmssName
    Confirm-LastExitCode

    Write-Log "Finished Setting Azure VMSS to Allocated"
}