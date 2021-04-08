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
        Write-Host "* Azure CLI Configuration:"
        Write-Host "** You are logged into the az CLI (run az login from a terminal)"
        Write-Host "** You have selected a subscription to deploy to (run az account set --subscription SUBSCRIPTION_NAME from a terminal)"
        Write-Host "** You have the latest version of the az CLI"
        Write-Host "** You have added the application insights az Extensions (az extension add -n application-insights)"
        Write-Host "* Azure PowerShell Cmdlet Configuration:"
        Write-Host "** You are logged into the cmdlets (run Connect-AzAccount from a PowerShell session)"
        Write-Host "** You have selected a subscription to deploy to (run Set-AzContext -Subscription 'Subscription Name' from a PowerShell session)"
        Write-Host "* You have docker and its CLI tools installed locally"
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

    Write-ScriptSection "Starting Deployments"

    # ORDER MATTERS!!
    
    Deploy-AzureMonitor $armParameters
    Deploy-AzurePolicy $armParameters    
    Deploy-AzureIdentity $armParameters
    Deploy-AzureKeyVault $armParameters $secureResourcePassword $secureCertificatePassword $wildcardCertificatePath
    Deploy-AzureNetworking $armParameters    
    Deploy-AzureNsgFlowLogs $armParameters    
    # Deploy-StorageFirewallRules $armParameters    

    # Deploy-AzureVirtualMachineJumpbox $armParameters

    # Deploy-AzureVirtualMachineNTier $armParameters
    # Deploy-AzureVirtualMachineScaleSets $armParameters
    # Deploy-AzureVirtualMachineWindows10Client $armParameters

    

    # Deploy-AzureContainerRegistry $armParameters
        # Dedicated Resource Group
        # Include deployment of images to registry
    # Deploy-AzureContainerInstances $armParameters
        # Dedicated Resource Group
        # Load Testing
    # Deploy-AzureSQL-ADEApp $armParameters
        # Dedicated Resource Group
    # Deploy-AzureAppServicePlan $armParameters
        # Dedicated Resource Group

    # Parallel
    # Deploy-AzureVirtualMachine-ADEApp $armParameters
        # Dedicated Resource Group
        
    # Parallel
    # Deploy-InspectorGadgetAppService $armParameters

    # Parallel
    # Deploy-AzureAppService-ADEApp $armParameters
        # Dedicated Resource Group
        # adefrontend (public)
        # adeapigateway (public)
        # adeuserservice
        # adedataingestorservice
        # adedatareporterservice

    # Parallel
    # Deploy-AzureKubernetesService-ADEApp $armParameters
        # Dedicated Resource Group

    #Serial
    # Deploy-AzureApplicationGateway $armParameters
        # Dedicated Resource Group
    # Deploy-AzureFrontDoor $armParameters
        # Dedicated Resource Group
    
    # Deploy-AzureAppServicePlanScaleDown $armParameters 
    # Deploy-AzureAlerts $armParameters
        # Existing Resource Group
    # Deploy-AzureDns $armParameters
        # Existing Resource Group

    # Deploy-AzureTrafficManager $armParameters
    # Deploy-AzureCognitiveServices $armParameters

    Write-ScriptSection "Finished Azure Development Environment Deployments"
}
