# Azure NSG Flow Logs

- [Azure Network Security Group Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview "Azure Network Security Group Documentation")
- [Azure Network Security Group Flow Logs Documentation](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview "Azure Network Security Group Flow Logs Documentation")

## Description

The Azure NSG Flow Logs deployment enables NSG Flow Log archival to and Azure Storage Account and Azure Log Analytics.  NSG Flow Logs are enabled for the following Network Security Groups.

- Azure Bastion Subnet NSG
- Management Subnet NSG
- Directory Services Subnet NSG
- Developer Subnet NSG
- N-Tier Web Subnet NSG
- N-Tier DB Subnet NSG
- VMSS Subnet NSG
- Client Services Subnet NSG

## Files Used

- azure_nsg_flow_logs.azcli

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post Deployment

Following deployment, verify the creation of the NSG Flow Logs.
