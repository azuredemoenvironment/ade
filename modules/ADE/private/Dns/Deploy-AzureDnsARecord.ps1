function Deploy-AzureDnsARecord {
    param(
        [string] $resourceGroup,
        [string] $zoneName,
        [string] $recordName,
        [string] $ipAddress
    )

    $resourceExists = Confirm-AzureResourceExists 'dns a record' $resourceGroup $zoneName $recordName

    if ($resourceExists) {
        Write-Log "$recordName.$zoneName already exists; skipping creation."
    }
    else {
        Write-Log "Adding A Record for $recordName.$zoneName"
        az network dns record-set a add-record -g $resourceGroup -z $zoneName -n $recordName --ipv4-address $ipAddress
        Confirm-LastExitCode
    }
}