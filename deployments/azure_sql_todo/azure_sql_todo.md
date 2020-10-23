# Azure SQL and App Service (ToDo)

- [Azure SQL Documentation](https://docs.microsoft.com/en-us/azure/sql-database/ "Azure SQL Documentation")
- [Azure App Service Plan Documentation](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans "Azure App Service Plan Documentation")
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/ "Azure App Service Documentation")
- [Azure Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview "Azure Application Insights Documentation")

## Description

The Azure SQL ToDo deployment creates a simple To Do Application using an Azure App Service and an Azure SQL Database.  Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage. Application Insights is configured for application monitoring. An Azure Application Gateway, created in a future deployment, will sit in front of the App Service.  The demo is based on the following tutorial:

- [Tutorial: Build an ASP.NET App in Azure with SQL Database](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-dotnet-sqldatabase "Tutorial: Build an ASP.NET App in Azure with SQL Database")

## Files Used

- azure_sql_todo.json
- azure_sql_todo.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment access the App Service and create a couple of items in the To Do List.
