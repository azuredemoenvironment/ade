# Azure Storage Account VM Diagnostics

- [Azure Storage Account Documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview "Azure Storage Account Documentation")
- [Azure Virtual Network Service Endpoints Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview "Azure Virtual Network Service Endpoints Documentation")

## Description

The Azure Storage Account VM Diagnostics deployment creates a single Storage Account used for Virtual Machine Boot Diagnostics. Firewall and Virtual Network settings have been configured to all all subnets containing virtual machines to access this storage account for diagnostics storage. An additional firewall rule is created to allow remote connectivity to manage the Storage Account.

## Files Used

- azure_storage_account_vmdiagnostics.json
- azure_storage_account_vmdiagnostics.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post Deployment

Following deployment, verify the creation of the Storage Account, and it's Firewall Settings.
