# Azure Traffic Manager

- [Azure Traffic Manager Documentation](https://docs.microsoft.com/en-us/azure/traffic-manager/ "Azure Traffic Manager Documentation")

## Description

The Azure Traffic Manager deployment creates an Azure Traffice Manager Profile and two Traffic Manager Endpoints configured in a Performance based configuration.  The two Traffic Manager Endpoints are the Primary and Secondary Region 'HelloWorld' App Services deployed in previous deployments.

## Files Used

- azure_traffic_manager.json
- azure_traffic_manager.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following the deployment, verify the creation of the Traffic Manager Profile, the Traffic Manager Endpoints, Diagnostics Settings, and connect to the App Services via the Traffic Manager URL.
