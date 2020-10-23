# Azure Identity

- [Azure User Assigned Managed Identity Documentation](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-cli-windows-vm# "Azure User Assigned Managed Identity Documentation")
- [Azure Service Principal Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals "Azure Service Principal Documentation")

## Description

The Azure Identity deployment creates a series of User Assigned Managed Identities and Service Principals used in subsequent deployments. Additionaly, these Managed Identities are assigned rights within an Azure Key Vault, and the Service Principals are assigned RBAC roles over specific resources. The following resources are created

- User Assigned Managed Identity for Azure Container Registry
- User Assigned Managed Identity for Azure Application Gateway
- Service Principal for use with the REST API
- Service Principal for Azure Container Registry
- Service Principal for GitHub Actions

## Files Used

- azure_identity.azcli

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the Managed Identities, Service Principals, and verify the KeyVault Secrets and Access Policies.
