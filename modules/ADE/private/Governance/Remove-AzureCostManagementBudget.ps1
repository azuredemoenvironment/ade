function Remove-AzureCostManagementBudget {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Cost Management Budget"
    
    $consumptionBudgetName = $armParameters.activityLogDiagnosticsName
    az consumption budget delete -n $consumptionBudgetName -y
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removing Azure Cost Management Budget"
}