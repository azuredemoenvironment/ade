function Deploy-AzureManagement {
    param(
        [object] $armParameters
    )

    # Deploy Azure Management
    ##################################################
    Write-ScriptSection "Initializing Management Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.managementResourceGroupName

    # Create the Azure Management Resource Group
    ##################################################
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Management Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Management' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Management Deployment"
}
