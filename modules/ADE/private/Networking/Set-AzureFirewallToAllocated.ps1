function Set-AzureFirewallToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Allocated"

    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $vnetName = $armParameters.virtualNetwork01Name
    $firewallName = $armParameters.firewallName
    $ipAddressName = $armParameters.firewallPublicIPAddressName

    $vnet = Get-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $vnetName
    $publicIp = Get-AzPublicIpAddress -Name $ipAddressName -ResourceGroupName $networkingResourceGroupName
    $firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $networkingResourceGroupName
    $firewall.Allocate($vnet, $publicIp)

    Write-Log "Finished Allocating Azure Firewall"
}