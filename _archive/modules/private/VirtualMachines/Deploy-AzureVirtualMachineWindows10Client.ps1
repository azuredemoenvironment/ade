function Deploy-AzureVirtualMachineWindows10Client {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Virtual Machine Windows 10 Client' $armParameters -resourceGroupName $armParameters.w10clientResourceGroupName
}