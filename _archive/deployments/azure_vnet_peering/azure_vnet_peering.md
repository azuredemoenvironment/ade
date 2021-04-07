# Azure VNET Peering

- [Azure Virtual Network Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview "Azure Virtual Network Documentation")
- [Azure Virtual Network Peering Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview "Azure Virtual Network Peering Documentation")

## Description

The Azure VNET Peering deployment configures a hub and spoke peering topology between three virtual networks. The central virtual network is peered to both the virtual machine workloads virtual network and the containerized workloads virtual network. Options are properly set for the workload virtual networks to utilize the Virtual Network Gateway from the central virtual network.

## Files Used

- azure_vnet_peering.azcli

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following the deployment, verify the creation of your Virtual Network Peering within the Azure Portal under the Virtual Networks blade.
