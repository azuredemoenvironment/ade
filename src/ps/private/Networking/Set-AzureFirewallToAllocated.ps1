function Set-AzureFirewallToAllocated {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Setting Azure Firewall to Allocated"

    $networkingResourceGroupName = $armParameters.networkingResourceGroupName
    $virtualNetwork001Name = $armParameters.virtualNetwork001Name
    $azureFirewallName = $armParameters.azureFirewallName
    $azureFirewallPublicIpAddressName = $armParameters.azureFirewallPublicIpAddressName

    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $networkingResourceGroupName -Name $virtualNetwork001Name
    $azureFirewallPublicIp = Get-AzPublicIpAddress -Name $azureFirewallPublicIpAddressName -ResourceGroupName $networkingResourceGroupName
    $azureFirewall = Get-AzFirewall -Name $azureFirewallName -ResourceGroupName $networkingResourceGroupName
    $azureFirewall.Allocate($virtualNetwork, $azureFirewallPublicIp)

    Set-AzFirewall -AzureFirewall $azureFirewall

    Write-Log "Finished Allocating Azure Firewall"
}