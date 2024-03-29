function Enable-AzureKubernetesServicesCluster {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Enabling Azure Kubernetes Services Cluster"

    az aks start -g $armParameters.containerResourceGroupName -n $armParameters.aksClusterName
    Confirm-LastExitCode
    
    az aks update -g $armParameters.containerResourceGroupName -n $armParameters.aksClusterName --enable-cluster-autoscaler --min-count 1 --max-count 3
    Confirm-LastExitCode

    Write-Log "Finished Enabling Azure Kubernetes Services Cluster"
}