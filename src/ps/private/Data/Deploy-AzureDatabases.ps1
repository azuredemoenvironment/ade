function Deploy-AzureDatabases {
    param(
        [object] $armParameters
    )

    # Deploy Azure Databases
    ##################################################
    Write-ScriptSection "Initializing Database Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.databaseResourceGroupName

    # Create the Azure Database Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Database Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Databases' $armParameters $resourceGroupName  -bicep

    Write-Status "Finished Azure Networking Deployment"
}