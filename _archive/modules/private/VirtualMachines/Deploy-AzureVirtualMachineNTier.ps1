function Deploy-AzureVirtualMachineNTier {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Virtual Machine NTier' $armParameters -resourceGroupName $armParameters.ntierResourceGroupName
}