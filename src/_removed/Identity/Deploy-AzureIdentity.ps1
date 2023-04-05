function Deploy-AzureIdentity {
    param(
        [object] $armParameters
    )

    # Deploy Azure Identity
    ##################################################
    Write-ScriptSection "Initializing Identity Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.identityResourceGroupName

    # Create the Azure Identity Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Identity Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Identity' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Identity Deployment"
}
