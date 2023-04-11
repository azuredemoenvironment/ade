function Deploy-AzureContainerInstances {
    param(
        [object] $armParameters
    )

    # Deploy Azure Container Instances
    ##################################################
    Write-ScriptSection "Initializing Azure Container Instances Deployment"

    # Parameters
    ##################################################
    $resourceGroupName = $armParameters.containerResourceGroupName    

    # Deploy the Azure Container Instances Bicep template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Container Instances' $armParameters $resourceGroupName -bicep

    Write-Status "Finished Azure Container Instances Deployment"
}