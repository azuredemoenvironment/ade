# Azure Container Registry

- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro "Azure Container Registry Documentation")

## Description

The Azure Container Registry.json deployment an Azure Container Registry for container storage. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage. RBAC permissions for a Service Principal are set on the registry to pull images from the Container Registry. The azure_container_registry_images.azcli file downloads the following Docker Images (to be used in future deployments), tags them, and uploads them to the Container Registry:

- azure-cli
- mysql:5.6
- wordpress:4.9-apache
- azure-powershell

## Files Used

- azure_container_registry.json
- azure_container_registry.parameters.json
- azure_container_registry_images.azcli

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the Container Registry, verify that the Service Principal has the acrpull role assignment, and verify that the images have been successfully pushed to the repository.
