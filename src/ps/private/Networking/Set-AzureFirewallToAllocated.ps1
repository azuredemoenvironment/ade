function Set-AzureFirewallToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Allocated"

    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $hubVirtualNetworkName = $armParameters.hubVirtualNetworkName
    $azureFirewallName = $armParameters.azureFirewallName
    $azureFirewallPublicIpAddressName = $armParameters.azureFirewallPublicIpAddressName

    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $hubVirtualNetworkName
    $azureFirewallPublicIp = Get-AzPublicIpAddress -Name $azureFirewallPublicIpAddressName -ResourceGroupName $networkingResourceGroupName
    $azureFirewall = Get-AzFirewall -Name $azureFirewallName -ResourceGroupName $networkingResourceGroupName
    $azureFirewall.Allocate($virtualNetwork, $azureFirewallPublicIp)

    Set-AzFirewall -AzureFirewall $azureFirewall

    Write-Log "Finished Allocating Azure Firewall"
}