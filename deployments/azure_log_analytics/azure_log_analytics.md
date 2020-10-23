# Azure Log Analytics

- [Azure Log Analytics Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/get-started-portal "Azure Log Analytics Documentation")

## Description

The Azure Log Analytics deployment creates an Azure Automation Account and a Log Analytics Workspace for the following data sources and solutions:

- Azure Activity Log
- Azure Updates
- Virtual Machine Insights
- Container Insights

Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_log_analytics.json
- azure_log_analytics.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post Deployment

Following deployment, access the Log Analytics Workspace and verify configuration.
