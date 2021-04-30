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

    Deploy-ArmTemplate 'Azure Virtual Machines' $armParameters -resourceGroupName $armParameters.jumpboxResourceGroupName -bicep
}