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
    
    Deploy-AzureLogAnalytics $armParameters
    Deploy-AzurePolicy $armParameters
    Deploy-AzureActivityLog $armParameters
    Deploy-AzureKeyVault $armParameters $secureResourcePassword $secureCertificatePassword $wildcardCertificatePath
    Deploy-AzureIdentity $armParameters
    Deploy-AzureNetworking $armParameters
    Deploy-AzureVpnGateway $armParameters
    Deploy-VnetPeering $armParameters
    Deploy-AzureStorageAccountVmDiagnostics $armParameters
    Deploy-AzureFirewall $armParameters
    Deploy-StorageFirewallRules $armParameters
    Deploy-AzureBastion $armParameters
    Deploy-AzureVirtualMachineJumpbox $armParameters
    Deploy-AzureVirtualMachineDeveloper $armParameters
    Deploy-AzureVirtualMachineWindows10Client $armParameters
    Deploy-AzureVirtualMachineNTier $armParameters
    Deploy-AzureVirtualMachineScaleSets $armParameters
    Deploy-AzureAlerts $armParameters
    Deploy-AzureContainerRegistry $armParameters
    Deploy-DockerImagesToAzureContainerRegistry $armParameters
    Deploy-AzureContainerInstancesWordPress $armParameters
    Deploy-AzureKubernetesServices  $armParameters
    Deploy-AzureKubernetesServicesVote $armParameters
    Deploy-AzureAppServicePlanToPrimaryRegion $armParameters
    Deploy-AzureAppServicePlanToSecondaryRegion $armParameters
    Deploy-ImageResizerAppService $armParameters
    Deploy-HelloWorldAppServiceToPrimaryRegion $armParameters
    Deploy-HelloWorldAppServiceToSecondaryRegion $armParameters
    Deploy-SqlToDoAppService $armParameters
    Deploy-AzureTrafficManager $armParameters
    Deploy-AzureApplicationGateway $armParameters
    Deploy-AzureDns $armParameters
    Set-AzureAppServiceHostNames $armParameters
    Deploy-AzureCognitiveServices $armParameters 
    Set-AppServiceManagedIdentities $armParameters
    Set-HelloWorldCert $armParameters

    Write-ScriptSection "Finished Azure Development Environment Deployments"
}