# Azure Kubernetes Services

- [Azure Kubernetes Services](https://docs.microsoft.com/en-us/azure/aks/ "Azure Kubernetes Services")

## Description

The Azure Kubernetes Services deployment creates an Azure Kubernetes Cluster
that will support container based applications in future deployments. The
cluster utilizes a Virtual Machine Scale Set for the compute nodes, and is
integrated into a Virtual Network. Azure Monitor for Containers is enabled for
the cluster utilizing Azure Log Analytics for data storage.

## Files Used

- azure_kubernetes_services.json
- azure_kubernetes_services.parameters.json

The values for all parameters will be automatically generated based on the
values provided at script execution.

## Post-Deployment

Following deployment, verify the deployment of the Azure Kubernetes Services
Cluster and all additional resources.
