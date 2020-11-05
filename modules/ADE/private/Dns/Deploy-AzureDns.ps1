function Deploy-AzureDns {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Initializing Azure DNS Deployment"

    # Shared Variables
    $aliasRegion = $armParameters.aliasRegion
    $dnsResourceGroup = $armParameters.dnsResourceGroupName
    $rootDomainName = $armParameters.rootDomainName

    New-ResourceGroup $dnsResourceGroup $armParameters.defaultPrimaryRegion

    # TODO: we cannot automatically create the zone right now because nameservers need to be established with the domain name
    # Deploy-AzureDnsZone $dnsResourceGroup $rootDomainName
    # Write-Log "Finished Configuring $rootDomainName Zone"

    Write-Log 'Configuring Virtual Machine DNS Entries'
    $virtualMachines = @('jumpbox', 'developer', 'lb-vmss')

    $virtualMachines | ForEach-Object {
        Write-Log "Configuring $_"

        $resourceGroup = "rg-$aliasRegion-$_".replace('lb-', '')
        $ipAddressName = "pip-$aliasRegion-$($_)01"
        $ipAddressValue = az network public-ip show -g $resourceGroup -n $ipAddressName --query ipAddress
        Confirm-LastExitCode

        $recordSet = $_.replace('lb-', '')

        Deploy-AzureDnsARecord $dnsResourceGroup $rootDomainName $recordSet $ipAddressValue

        Write-Log "Finished Configuring $_"
    }

    Write-Log 'Configuring Application Gateway DNS Entries'
    $apps = @(
        'imageresizer'
        'wordpress'
        'sqltodo'
        'ntier'
    )

    $applicationGatewayResourceGroup = $armParameters.applicationGatewayResourceGroupName
    $applicationGatewayIpAddressName = $armParameters.applicationGatewayPublicIPAddressName
    $applicationGatewayIpAddressValue = az network public-ip show -g $applicationGatewayResourceGroup -n $applicationGatewayIpAddressName --query ipAddress
    Confirm-LastExitCode

    $apps | ForEach-Object {
        $recordSet = $_

        Write-Log "Configuring $_"

        Deploy-AzureDnsARecord $dnsResourceGroup $rootDomainName $recordSet $applicationGatewayIpAddressValue

        Write-Log "Finished Configuring $_"
    }

    Write-Log 'Configuring Traffic Manager (Hello World) DNS Entries'
    $trafficManagerResourceGroup = $armParameters.trafficManagerResourceGroupName
    $trafficManagerProfileName = $armParameters.trafficManagerProfileName
    $trafficManagerProfileId = az network traffic-manager profile show -g $trafficManagerResourceGroup -n $trafficManagerProfileName --query id
    $trafficManagerRecordSet = 'helloworld'
        
    Deploy-AzureDnsCnameRecord $dnsResourceGroup $rootDomainName $trafficManagerRecordSet $trafficManagerProfileId

    Write-Status "Finished Azure DNS Deployment"
}