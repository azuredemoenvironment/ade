function Set-AzureContainerInstancesToStarted {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Container Instances to Started"

    $containerGroupResourceGroup = $armParameters.wordpressResourceGroupName

    $containerGroups = @(
        'containerGroup-mysql',
        'containerGroup-share',
        'containerGroup-wordpress'
    )
    
    $containerGroups | ForEach-Object {
        Write-Log "Starting $_"

        az container start --resource-group $containerGroupResourceGroup --name $_
        Confirm-LastExitCode
    }

    Write-Log "Finished Setting Azure Container Instances to Started"
}