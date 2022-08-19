function Deploy-AzureVirtualMachines {
    param(
        [object] $armParameters
    )

    # Deploy Azure Virtual Machines
    ##################################################
    Write-ScriptSection "Initializing Virtual Machines Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.virtualMachineResourceGroupName

    # Create the Azure Virtual Machines Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Virtual Machines Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Virtual Machines' $armParameters $resourceGroupName -bicep

    Write-Status "Finished Azure Virtual Machines Deployment"  
}