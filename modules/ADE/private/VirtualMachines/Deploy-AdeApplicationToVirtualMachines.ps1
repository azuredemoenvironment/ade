function Deploy-AdeApplicationToVirtualMachines {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Virtual Machines App Deployment' $armParameters -resourceLevel 'sub' -bicep

}