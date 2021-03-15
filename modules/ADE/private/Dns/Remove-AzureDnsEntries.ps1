function Remove-AzureDnsEntries {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Removing Azure DNS Entries"

    $dnsResourceGroup = $armParameters.dnsResourceGroupName
    $zoneName = $armParameters.rootDomainName
    $zoneExists = Confirm-AzureResourceExists 'dns zone' $dnsResourceGroup $zoneName
    # $rootDomainName = $armParameters.rootDomainName

    if (-not $zoneExists) {
        Write-Log "The $zoneName does not exist; continuing to next steps."
        return
    }

    Write-Log "Removing A Records"
    $aRecords = @(
        'inspectorgadget'
        'ntier'
        'sqltodo'
        'wordpress'
        'imageresizer'
        'vmss'
        'developer'
        'jumpbox'
    )

    $aRecords | ForEach-Object {
        Write-Log "Removing A Record: $_"
        az network dns record-set a delete -g $dnsResourceGroup -z $zoneName -n $_ -y
        Confirm-LastExitCode
    }

    Write-Log "Removing CNAME Records"
    $cnameRecords = @(
        'helloworld'   
    )

    $cnameRecords | ForEach-Object {
        Write-Log "Removing CNAME Record: $_"
        az network dns record-set cname delete -g $dnsResourceGroup -z $zoneName -n $_ -y
        Confirm-LastExitCode
    }

    # TODO: we leave the zone since we didn't create it, in the future it would be nice to automate this portion as well
    # Write-Log "Removing $rootDomainName Zone"
    # az network dns zone delete -g $dnsResourceGroup -n $rootDomainName -y
    # Confirm-LastExitCode
    

    Write-ScriptSection "Finished Removing Azure DNS Entries"
}