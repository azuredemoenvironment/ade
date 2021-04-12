function Deploy-AzureVirtualMachineJumpbox {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Virtual Machine Jumpbox' $armParameters -resourceGroupName $armParameters.jumpboxResourceGroupName -bicep
}