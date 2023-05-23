function Remove-AzureDemoEnvironment {
    param(
        [object] $armParameters,
        [switch] $includeKeyVault
    )
    
    Write-ScriptSection "Initializing Azure Demo Environment Removal"

    if (-not $armParameters.skipConfirmation) {
        Write-Host "This script will automatically remove an Azure Demo Environment instance, removing"
        Write-Host "resource groups that were created during the ADE deploy process. Use this after you"
        Write-Host "have completed your demo to reduce costs."
        Write-Host ""
        Write-Host "By default, the Azure KeyVault resource group is *not* removed, as that requires"
        Write-Host "a special removal procedure that can interfere with a redeployment. Add the"
        Write-Host "-includeKeyVault flag to also remove that."
        Write-Host ""

        $continueWithSetup = Read-Host -prompt "Would you like to proceed with the removal of ADE (y/N)?"
        if ($continueWithSetup -ne 'y') {
            Write-Host "Exiting."
            exit
        }
    }

    # Configuring Variables
    Write-ScriptSection "Starting Removal Process"

    Remove-AzureResourceGroups $armParameters
    Remove-AzureCostManagementBudget $armParameters
    Remove-AzureNsgFlowLogs $armParameters
    Remove-AzureActivityLogDiagnostics $armParameters
    Remove-AzurePolicyAssignmentsAndDefinitions $armParameters
    Remove-AzureDnsRecords $armParameters

    Write-ScriptSection "Finished Removal"
}