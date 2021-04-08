# Azure Activity Log

- [Azure Activity Log Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/platform-logs-overview "Azure Activity Log Documentation")

## Description

The Azure Activity Log deployment creates a Global Diagnostics Setting for sending all Azure Activity Logs to Azure Log Analytics. The configuration is set at the subscription level and continues down through the hierarchy to all resources.

## Files Used

- azure_activity_log.json
- azure_activity_log.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post Deployment

Following deployment, verify the creation of the Global Diagnostics Setting under the Subscription.
