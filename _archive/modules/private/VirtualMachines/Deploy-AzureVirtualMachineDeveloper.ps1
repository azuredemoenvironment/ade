function Deploy-AzureVirtualMachineDeveloper {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Virtual Machine Developer' $armParameters -resourceGroupName $armParameters.developerResourceGroupName
}