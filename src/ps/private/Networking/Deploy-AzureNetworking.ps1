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

    # Create the Azure Management Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Management Bicep template at the Resource Group scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Networking' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Networking Deployment"
}