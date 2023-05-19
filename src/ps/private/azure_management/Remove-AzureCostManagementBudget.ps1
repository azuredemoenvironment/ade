function Remove-AzureCostManagementBudget {
    param (
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure Cost Management Budget"
    $consumptionBudgetName = $armParameters.budgetName
    
    if (Confirm-AzureResourceExists 'budget' $consumptionBudgetName) {
        az consumption budget delete --budget-name $consumptionBudgetName
        Confirm-LastExitCode
    }

    Write-ScriptSection "Finished Removing Azure Cost Management Budget"
}