# Azure Firewall (Optional)

- [Azure Firewall Documentation](https://docs.microsoft.com/en-us/azure/firewall/overview "Azure Firewall Documentation")

## Description

The Azure Firewall deployment creates an Azure Firewall in the shared services virtual network. Application Rules are created to only allow HTTP and HTTPS access to microsoft.com and github.com. For cost savings, there is a series of deallocate and allocate commands that can be used to shut down the Azure Firewall when not in use. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_firewall.json
- azure_firewall.parameters.json
- allocate_and_deallocate.ps1

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following the deployment verify the creation of the Azure Firewall.

## Additional Notes

The following commands execute a deallocation and an allocation on the Azure Firewall.

### Allocate Firewall

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

### Deallocate Firewall

  Login-AzAccount
  $resourceGroup = 'rg-alias-region-networking'
  $firewallName = 'fw-alias-region-01'
  $firewall = Get-AzFirewall -Name $firewallName -ResourceGroupName $resourceGroup
  $firewall.Deallocate()
  Set-AzFirewall -AzureFirewall $firewall
