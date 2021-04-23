function Deploy-AzureDemoEnvironment {
    param(
        [object] $armParameters,
        [SecureString] $secureResourcePassword,
        [SecureString] $secureCertificatePassword,
        [object] $wildcardCertificatePath
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

    # Core Services
    ###################################
    Deploy-AzureMonitor $armParameters
    Deploy-AzurePolicy $armParameters
    Deploy-AzureIdentity $armParameters
    Deploy-AzureKeyVault $armParameters $secureResourcePassword $secureCertificatePassword $wildcardCertificatePath
    Deploy-AzureNetworking $armParameters
    Deploy-AzureNsgFlowLogs $armParameters

    # Data Services
    ###################################
    Deploy-AdeDatabase $armParameters
    # Dedicated Resource Group

    # Compute Infrastructure
    ###################################
    Deploy-AzureVirtualMachines $armParameters
    Deploy-AzureContainerRegistry $armParameters
    # Deploy-AzureContainerInstances $armParameters
    # Dedicated Resource Group
    # Load Testing
    Deploy-AzureAppServicePlan $armParameters

    # ADE App App Services
    ###################################
    # Parallel
    # Deploy-InspectorGadgetAppService $armParameters

    # Parallel
    Deploy-AdeAzureAppServices $armParameters
    # Dedicated Resource Group
    # adefrontend (public)
    # adeapigateway (public)
    # adeuserservice
    # adedataingestorservice
    # adedatareporterservice

    # ADE App Kubernetes
    ###################################
    # Parallel
    # Deploy-AzureKubernetesService-ADEApp $armParameters
    # Dedicated Resource Group

    # Frontend Load Balancers
    ###################################
    # Deploy-AzureApplicationGateway $armParameters
    # Dedicated Resource Group
    # Deploy-AzureFrontDoor $armParameters
    # Dedicated Resource Group
    
    # Service Cleanup
    ###################################
    # Deploy-AzureAppServicePlanScaleDown $armParameters 

    # Additional Core Services
    ###################################
    # Deploy-AzureAlerts $armParameters
    # Existing Resource Group
    # Deploy-AzureDns $armParameters
    # Existing Resource Group

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-ScriptSection "Finished Azure Demo Environment Deployments in $elapsedSeconds seconds"
}
