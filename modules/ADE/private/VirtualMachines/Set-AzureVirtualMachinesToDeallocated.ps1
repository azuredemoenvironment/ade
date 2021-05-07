function Set-AzureVirtualMachinesToDeallocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Virtual Machines to Deallocated (for Cost Savings)"

    $virtualMachines = @(
        @{ Name = $armParameters.jumpboxName; ResourceGroup = $armParameters.jumpboxResourceGroupName },
        @{ Name = 'vm-ntierweb01'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = 'vm-ntierweb02'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = 'vm-ntierweb03'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = 'vm-ntierapp01'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = 'vm-ntierapp02'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = 'vm-ntierapp03'; ResourceGroup = $armParameters.ntierResourceGroupName },
        @{ Name = $armParameters.w10clientName; ResourceGroup = $armParameters.w10clientResourceGroupName }
    )
    
    $virtualMachines | ForEach-Object {
        $name = $_.Name
        $rg = $_.ResourceGroup

        Write-Log "Deallocating $name in resource group $rg"

        az vm deallocate --resource-group $rg --name $name
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Virtual Machines to Deallocated (for Cost Savings)"
}