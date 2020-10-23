function Deploy-AzureDnsCnameRecord {
    param(
        [string] $resourceGroup,
        [string] $zoneName,
        [string] $recordName,
        [string] $hostName
    )

    $resourceExists = Confirm-AzureResourceExists 'dns cname record' $resourceGroup $zoneName $recordName

    if ($resourceExists) {
        Write-Log "$recordName.$zoneName already exists; skipping creation."
    }
    else {
        Write-Log "Adding CNAME Record for $recordName.$rootDomainName"
        az network dns record-set cname create -g $resourceGroup -z $zoneName -n $recordName --target-resource $hostName
        Confirm-LastExitCode
    }
}