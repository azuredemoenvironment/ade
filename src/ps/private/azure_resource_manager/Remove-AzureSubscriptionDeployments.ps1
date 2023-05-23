function Remove-AzureSubscriptionDeployments {
    
    Write-ScriptSection "Removing Azure Subscription Deployments"

    $subscriptionDeploymentsToRemove = @(
        "automationRoleAssignmentDeployment"
        "activityLogDeployment"
        "budgetDeployment"
        "policyDeployment"
    )

    $subscriptionDeploymentsToRemove | ForEach-Object {
        $subscriptionDeploymentExists = Confirm-AzureResourceExists 'subscription deployment' $_
        if (-not $subscriptionDeploymentExists) {
            Write-Log "The subscription deployment $_ does not exist; skipping."
            return
        }
        
        Write-Log "Removing $_ Subscription Deployment"

        az deployment sub delete -n $_ -y
        Confirm-LastExitCode

        Write-Log "Removed $_ Subscription Deployment"
    }

    Write-ScriptSection "Finished Removing Azure Subscription Deployments"
}