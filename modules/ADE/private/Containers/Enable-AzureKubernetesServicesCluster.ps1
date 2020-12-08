function Enable-AzureKubernetesServicesCluster {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Enabling Azure Kubernetes Services Cluster"

    az aks start -g $armParameters.aksResourceGroupName -n $armParameters.aksClusterName
    Confirm-LastExitCode
    
    az aks update -g $armParameters.aksResourceGroupName -n $armParameters.aksClusterName --enable-cluster-autoscaler
    Confirm-LastExitCode

    Write-Log "Finished Enabling Azure Kubernetes Services Cluster"
}