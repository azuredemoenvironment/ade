# Azure App Service Plan

- [Azure App Service Plan Documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans "Azure App Service Plan Documentation")

## Description

The Azure App Service Plan Primary Region deployment creates an Azure App
Service Plan in the Primary Region. The App Service Plan is used to host
multiple App Servces (Web Apps, Mobile Apps, API Apps, and Function Apps). The
App Service Plan is initially set at the P1V3 SKU, but lowered to the P1V2 SKU
after deployment. Starting at the P1V3 SKU allows for App Service Regional VNET
Integration and App Service Private Link for Windows App Service Plans.

## Files Used

- azure_app_service_plan_primary_region.json
- azure_app_service_plan_primary_region.parameters.json

The values for all parameters will be automatically generated based on the
values provided at script execution.

## Post-Deployment

Following deployment, verify the creation of the App Service Plan in the Primary
Region.
