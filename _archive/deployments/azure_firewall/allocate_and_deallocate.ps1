# Deallocate Firewall
Login-AzAccount
$resourceGroup = 'rg-alias-region-networking'
$firewallName = 'fw-alias-region-01'
$firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $resourceGroup
$firewall.Deallocate()
Set-AzFirewall -AzureFirewall $firewall

# Allocate Firewall
Login-AzAccount
$resourceGroup = 'rg-alias-region-networking'
$firewallName = 'fw-alias-region-01'
$firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $resourceGroup
$virtualNetwork01Name = 'vnet-alias-region-01'
$virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup -Name $virtualNetwork01Name
$firewallPublicIPAddressName = 'pip-alias-region-fw01'
$publicIPAddress = Get-AzPublicIpAddress -Name $firewallPublicIPAddressName -ResourceGroupName $resourceGroup
$firewall.Allocate($virtualNetwork,$publicIPAddress)
Set-AzFirewall -AzureFirewall $firewall
