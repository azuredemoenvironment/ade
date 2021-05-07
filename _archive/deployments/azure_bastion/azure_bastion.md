# Azure Bastion

- [Azure Bastion Documentation](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview "Azure Bastion Documentation")

## Description

The Azure Bastion deployment creates an Azure Bastion on the Azure Bastion Subnet in the shared services virtual network for remote access to virtual machine workloads.  Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_bastion.json
- azure_bastion.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the Azure Basion.
