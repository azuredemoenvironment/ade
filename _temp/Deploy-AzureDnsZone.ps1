function Deploy-AzureDnsZone {
    param(
        [string] $resourceGroup,
        [string] $zoneName
    )

    $resourceExists = Confirm-AzureResourceExists 'dns zone' $resourceGroup $zoneName

    if ($resourceExists) {
        Write-Log "$zoneName already exists; skipping creation."
    }
    else {
        Write-Log "Configuring $zoneName Zone"
        az network dns zone create -g $resourceGroup -n $zoneName
        Confirm-LastExitCode

        Write-Log "Sleeping for 120 seconds to allow propagation."
        Start-Sleep -Seconds 120
    }
}