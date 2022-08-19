function Deploy-AzureAppServices {
    param(
        [object] $armParameters
    )

    # Deploy Azure App Services
    ##################################################
    Write-ScriptSection "Initializing App Services Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.appServiceResourceGroupName

    # Create the Azure App Services Resource Group
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure App Services Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure App Services' $armParameters $resourceGroupName -bicep

    Write-Status "Finished Azure App Services Deployment"  
}