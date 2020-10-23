# Azure App Service (Hello World) (Secondary Region)

- [Azure App Service Plan Documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans "Azure App Service Plan Documentation")
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/ "Azure App Service Documentation")
- [Azure App Service Deployment Slot Documentation](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots "Azure App Service Deployment Slot Documentation")
- [Azure Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview "Azure Application Insights Documentation")

## Description

The Azure App Service Hello World secondary Region deployment creates a simple App Service with four additional deployment slots to the existing App Service Plan in the secondary region.  This App Service acts as an Azure Traffic Manager Endpoint. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.  Application Insights is configured for application monitoring.

## Files Required

- azure_app_service_helloworld_secondary_region.json
- azure_app_service_helloworld_secondary_region.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment access the App service to verify functionality.
