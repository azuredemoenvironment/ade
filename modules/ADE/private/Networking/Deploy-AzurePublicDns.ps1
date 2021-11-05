function Deploy-AzurePublicDns {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing Azure DNS Deployment"

    Deploy-ArmTemplate 'Azure Public Dns' $armParameters -resourceLevel 'sub' -bicep

    Write-Status "Finished Azure DNS Deployment"
}