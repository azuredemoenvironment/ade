function Disable-HighCostAzureServices {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing Azure Demo Environment Deallocation"

    Set-AzureFirewallToDeallocated $armParameters
    Set-AzureVmssToDeallocated $armParameters
    Set-AzureKubernetesServicesClusterToStopped $armParameters
    Set-AzureContainerInstancesToStopped $armParameters

    Write-ScriptSection "Finished Azure Demo Environment Deallocation"
}