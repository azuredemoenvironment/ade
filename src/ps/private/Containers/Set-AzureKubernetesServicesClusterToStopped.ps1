function Set-AzureKubernetesServicesClusterToStopped {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Kubernetes Services Cluster to Stopped (for Cost Savings)"
    
    az aks update -g $armParameters.aksResourceGroupName -n $armParameters.aksClusterName --disable-cluster-autoscaler
    Confirm-LastExitCode

    az aks stop -g $armParameters.aksResourceGroupName -n $armParameters.aksClusterName
    Confirm-LastExitCode

    Write-Log "Finished Setting Azure Kubernetes Services Cluster to Stopped (for Cost Savings)"
}