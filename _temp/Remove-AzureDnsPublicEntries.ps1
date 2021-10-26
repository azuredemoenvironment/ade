function Remove-AzurePublicDnsEntries {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure DNS Entries"

    $dnsResourceGroup = $armParameters.dnsResourceGroupName
    $zoneName = $armParameters.rootDomainName
    $zoneExists = Confirm-AzureResourceExists 'dns zone' $dnsResourceGroup $zoneName

    if (-not $zoneExists) {
        Write-Log "The $zoneName does not exist; continuing to next steps."
        return
    }

    Write-Log "Removing A Records"
    $aRecords = @(
        'ade-apigateway',    
        'ade-apigateway-app',
        'ade-apigateway-vm',
        'ade-apigateway-vmss',
        'ade-frontend',
        'ade-frontend-app',
        'ade-frontend-vm',
        'ade-frontend-vmss',
        'inspectorgadget'
    )

    $aRecords | ForEach-Object {
        Write-Log "Removing A Record: $_"
        az network dns record-set a delete -g $dnsResourceGroup -z $zoneName -n $_ -y
        Confirm-LastExitCode
    }    

    Write-ScriptSection "Finished Removing Azure DNS Entries"
}