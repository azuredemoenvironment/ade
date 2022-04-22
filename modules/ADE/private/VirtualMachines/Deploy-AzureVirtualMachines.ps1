function Deploy-AzureVirtualMachines {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Virtual Machines' $armParameters -resourceLevel 'sub' -bicep

}