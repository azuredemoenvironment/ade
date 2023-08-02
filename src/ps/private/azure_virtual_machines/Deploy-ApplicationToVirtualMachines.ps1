function Deploy-AdeApplicationToVirtualMachines {
    param(
        [object] $armParameters
    )

    # Deploy Azure Virtual Machines Application Deployment
    ##################################################
    Write-ScriptSection "Initializing Virtual Machines Application Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.virtualMachineResourceGroupName

    # Create the Azure Virtual Machines Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Virtual Machines App Deployment Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Virtual Machines App Deployment' $armParameters $resourceGroupName -bicep

    Write-Status "Finished Azure Virtual Machines Application Deployment" 

}