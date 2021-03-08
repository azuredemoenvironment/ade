# Azure Private Link (Inspector Gadget)

- [Azure Private Link Documentation](https://docs.microsoft.com/en-us/azure/private-link/private-link-overview "Azure Private Link Documentation")
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/ "Azure App Service Documentation")
- [Azure Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview "Azure Application Insights Documentation")
- [Azure SQL Documentation](https://docs.microsoft.com/en-us/azure/sql-database/ "Azure SQL Documentation")

## Description

- This deployment is based off of the Inspector Gadget application found here:
  <https://github.com/jelledruyts/InspectorGadget>

The Azure Private Link Inspector Gadget deployment builds a fully functional
two-tier application utilizing an Azure App Service and Azure SQL. Additionally,
this deployment uses Azure Private Link (Private Endpoints) for both the Azure
App Service and the Azure SQL Database. Regional VNET Integration is also
enabled for the Azure App Service. The application is access privately from
within the Virtual Network, or externally via an Application Gateway. The
application flow is as follows:

Internet --> Azure Application Gateway --> Azure App Service Private Endpoint
--> Azure App Service --> Regional VNET Integration --> Azure SQL Private
Endpoint --> Azure SQL Database

## Files Used

- azure_private_link_inspectorgadget.json
- azure_private_link_inspectorgadget.parameters.json

The values for all parameters will be automatically generated based on the
values provided at script execution.

## Post-Deployment

Following deployment access the App Service and test the functionality.
