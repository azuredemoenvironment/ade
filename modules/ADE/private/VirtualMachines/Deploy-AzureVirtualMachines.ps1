function Deploy-AzureVirtualMachines {
    param(
        [object] $armParameters
    )

    $defaultPrimaryRegion = $armParameters.defaultPrimaryRegion
    $nTierResourceGroupName = $armParameters.nTierResourceGroupName
    $vmssResourceGroupName = $armParameters.vmssResourceGroupName
    $w10clientResourceGroupName = $armParameters.w10clientResourceGroupName

    New-ResourceGroup $nTierResourceGroupName $defaultPrimaryRegion
    New-ResourceGroup $vmssResourceGroupName $defaultPrimaryRegion
    New-ResourceGroup $w10clientResourceGroupName $defaultPrimaryRegion

    # Checking if module is supported
    if (-not (Confirm-PartOfModule $armParameters.module @($modules.VirtualMachines, $modules.Networking))) {
        return;
    }

    Deploy-ArmTemplate 'Azure Virtual Machines' $armParameters -resourceGroupName $armParameters.jumpboxResourceGroupName -bicep
}