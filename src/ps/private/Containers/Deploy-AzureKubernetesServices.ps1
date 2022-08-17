function Deploy-AzureKubernetesServices {
    param(
        [object] $armParameters
    )

    # Deploy Azure Kubernetes Services
    ##################################################
    Write-ScriptSection "Initializing Azure Kubernetes Services Deployment"

    # Deploy the Azure Kubernetes Services Bicep template at the subscription scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Kubernetes Services' $armParameters -resourceLevel 'sub' -bicep

    Write-Status "Finished Azure Kubernetes Services Deployment"
}