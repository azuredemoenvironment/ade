function Deploy-AzureVirtualMachineScaleSets {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure VMSS' $armParameters -resourceGroupName $armParameters.vmssResourceGroupName
}