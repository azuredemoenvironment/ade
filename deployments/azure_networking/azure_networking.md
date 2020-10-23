# Azure Networking

- [Azure Virtual Network Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview "Azure Virtual Network Documentation")
- [Azure Network Security Group Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview "Azure Network Security Group Documentation")
- [Azure Network Security Group Flow Logs Documentation](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview "Azure Network Security Group Flow Logs Documentation")
- [Azure Route Table Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview "Azure Route Table Documentation")
- [Azure Virtual Network Service Endpoints Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview "Azure Virtual Network Service Endpoints Documentation")

## Description

The Azure Networking deployment creates a series of netowrking resources in a "Shared Services / Service Chaining" configuration. A central virtual network is used for Azure Bastion, Azure Application Gateway, Directory Services, Management, while the other virtual networks are used for virtual machine workloads and containerized workloads. The following networking resources are created:

- Azure Virtual Network with an address prefix of 10.101.0.0/16
- Azure Virtual Network with an address prefix of 10.102.0.0/16
- Azure Virtual Network with an address prefix of 10.103.0.0/16
- Azure Virtual Network Subnets for the following:
  - Azure Firewall
  - Azure Bastion
  - Application Gateway
  - Management (Jump Box)
  - Directory Services
  - Virtual Network Gateway
  - Developer
  - N-Tier Web
  - N-Tier Database
  - Virtual Machine Scale Sets
  - Client Services
  - Azure Kubernetes Service
  - Azure Container Instances
- Azure NAT Gateway for outbound Network Adddress Translation (NAT) from the Management Subnet
- Azure Network Security Groups and Network Security Group Flow Logs for the subnets listed below:
  - Azure Bastion
  - Management (Jump Box)
  - Directory Services
  - Developer
  - N-Tier Web
  - N-Tier Database
  - Virtual Machine Scale Sets
  - Client Services
- Azure Route Table applied to the Client Services Subnet to route 0.0.0.0/16 traffic to the Azure Firewall.
- Service Endpoint configuration to Azure Storage for virtual machine workload subnets
- Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_networking.json
- azure_networking.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following the deployment, verify the creation of your Virtual Network and additional resources.
