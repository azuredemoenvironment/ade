function Set-AzureContainerInstancesToStopped {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Stopped (for Cost Savings)"

    $containerGroupResourceGroup = $armParameters.wordpressResourceGroupName

    $containerGroups = @(
        'containerGroup-mysql',
        'containerGroup-share',
        'containerGroup-wordpress'
    )
    
    $containerGroups | ForEach-Object {
        Write-Log "Stopping $_"

        az container stop --resource-group $containerGroupResourceGroup --name $_
        Confirm-LastExitCode

    }

    Write-Log "Finished Setting Azure Container Instances to Stopped (for Cost Savings)"
}