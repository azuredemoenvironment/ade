function Deploy-AzureDemoEnvironment {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing Azure Demo Environment Deploy"

    if (-not $armParameters.skipConfirmation) {
        Write-Host "This script will automatically create an Azure Demo Environment, demonstrating many"
        Write-Host "of the Azure Services that are available. A complete solution will be available for"
        Write-Host "use and be accessible to you."
        Write-Host ""
        Write-Host "There are a few small prerequisites required before creating the resources for the"
        Write-Host "environment. Please ensure the following are done *before* continuing the creation process:"
        Write-Host ""
        Write-Host "* You have access to the relevant Azure Subscription"
        Write-Host "* You have a wildcard PFX certificate stored at $wildcardCertificatePath"
        Write-Host "* You have a custom domain configured in Azure DNS"
        Write-Host ""

        $continueWithSetup = Read-Host -prompt "Have you completed these steps and would like to continue (y/N)?"
        if ($continueWithSetup -ne 'y') {
            Write-Host "Exiting."
            exit
        }
    }

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()

    Write-ScriptSection "Starting Azure Demo Environment Deployments"
    
    # # Core Services
    # ###################################
    Deploy-AzureGovernance $armParameters
    Deploy-AzureNetworking $armParameters
    Deploy-AzureContainerRegistry $armParameters
    
    # # Data Services
    # ###################################
    Deploy-AzureDatabases $armParameters

    # # Compute Infrastructure
    # ###################################
    Deploy-AzureVirtualMachines $armParameters
    Deploy-AzureAppServices $armParameters
    Deploy-AzureKubernetesServices $armParameters
    Deploy-AzureContainerInstances $armParameters
    Deploy-AdeApplicationToVirtualMachines $armParameters

    # # Frontend Load Balancers
    # ###################################
    Deploy-AzureFrontendLoadBalancers $armParameters
    
    # # Service Cleanup
    # ###################################
    Deploy-AzureAppServicePlanScaleDown $armParameters
    Set-AzureContainerInstancesToStopped $armParameters

    # # Additional Core Services
    # ###################################
    Deploy-AzureAlerts $armParameters
    Deploy-AzurePublicDns $armParameters

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-ScriptSection "Finished Azure Demo Environment Deployments in $elapsedSeconds seconds"
}
