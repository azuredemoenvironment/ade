# Azure Policy

- [Azure Policy Documentation](https://azure.microsoft.com/en-us/services/azure-policy/ "Azure Policy Documentation")

## Description

The Azure Policy deployment creates a cusomt Initiative Definition, and assigns the Initiative Definition at the subscription scope without any exclusions. The custom Initiative Definition sets the following policy assignments:

- Allowed locations for resource groups
- Allowed locations
- Allowed virtual machine size skus
- Audit virtual machines without disaster recovery configured

Two Initiative Definitions are also assigned at the scubscription scope:

- Enable Azure Monitor for VMs
- Enable Azure Monitor for Virtual Machine Scale Sets

## Files Used

- azure_policy.json
- azure_policy.parameters.json

The default values of the Policy Definitions are detailed below. Adjustments to the values of the Policy Definitions can be made by editing the azure_policy.parameters.json file in the cloned repository.

- Allowed Resource Group Locations and Allowed Resource Locations
  - eastus
  - westus

- Allowed Virtual Machine SKUs
  - Standard_B1ls
  - Standard_B1ms
  - Standard_B1s
  - Standard_B2ms
  - Standard_B2s
  - Standard_B4ms
  - Standard_B4s
  - Standard_D2s_v3
  - Standard_D4s_v3

## Post Deployment

Following the deployment, verify the creation of the custom Initiative Definition, and the assignment of the three Initiative Definitions.
