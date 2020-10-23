# Azure Alerts

- [Azure Alerts Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-overview "Azure Alerts Documentation")

## Description

The Azure Alerts deployment creates a series Azure Monitor Action Groups and Azure Monitor Alert Rules for the following:

- Azure Service Health Log Alert
- Virtual Machine Administrative Actions Log Alert
- Virtual Machine CPU Utilization Metric Alert
- Virtual Network Administrative Actions Log Alert

_Note - Alerts have been created in a disabled state._

## Files Used

- azure_alerts.json
- azure_alerts.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the Action Groups and the Alert Rules.
