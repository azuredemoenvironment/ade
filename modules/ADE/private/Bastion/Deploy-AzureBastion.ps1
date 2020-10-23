function Deploy-AzureBastion {
    param(
        [object] $armParameters
    )

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Bastion' $armParameters -resourceGroupName $armParameters.bastionResourceGroupName
}