function Enable-HighCostAzureServices {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing Azure Demo Environment Allocation"

    Set-AzureFirewallToAllocated  $armParameters
    Set-AzureVmssToAllocated $armParameters
    Enable-AzureKubernetesServicesCluster $armParameters
    Set-AzureContainerInstancesToStarted $armParameters

    Write-ScriptSection "Finished Azure Demo Environment Allocation"
}