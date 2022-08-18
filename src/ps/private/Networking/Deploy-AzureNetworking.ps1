function Deploy-AzureNetworking {
    param(
        [object] $armParameters
    )

    # Deploy Azure Networking
    ##################################################
    Write-ScriptSection "Initializing Networking Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.networkingResourceGroupName

    # Create the Azure Networking Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Networking Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Networking' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Networking Deployment"
}