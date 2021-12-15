function Remove-AzureCostManagementBudget {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Cost Management Budget"
    
    $consumptionBudgetName = $armParameters.adeBudgetName
    az consumption budget delete --budget-name $consumptionBudgetName
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removing Azure Cost Management Budget"
}