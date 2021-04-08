# Azure App Service (Image Resizer)

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/ "Azure App Service Documentation")
- [Azure Function Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview "Azure Function Documentation")
- [Azure App Service Deployment Slot Documentation](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots "Azure App Service Deployment Slot Documentation")
- [Azure Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview "Azure Application Insights Documentation")

## Description

The Azure App Service Image Resizer deployment creates a solution based on the tutorial "Tutorial: Upload Image Data in the Cloud with Azure Storage". Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage. Application Insights is configured for application monitoring. An Azure Application Gateway, created in a future deployment, will sit in front of the App Service. The template creates the following resources:

- Azure App Service (Web App)
- Azure App Service (Function App)
- Azure Storage Accounts

For additional information on this demo, please refer to the documentation links below:

- [Part 1 - Tutorial: Upload Image Data in the Cloud with Azure Storage ](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-upload-process-images?tabs=dotnet "Part 1 - Tutorial: Upload Image Data in the Cloud with Azure Storage ")
- [Part 2 - Tutorial: Automate Resizing Uploaded Images using Event Grid ](https://docs.microsoft.com/en-us/azure/event-grid/resize-images-on-storage-blob-upload-event?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&tabs=dotnet#create-an-event-subscription "Part 2 - Tutorial: Automate Resizing Uploaded Images using Event Grid ")

## Files Used

- azure_app_service_imageresizer.json
- azure_app_service_imageresizer.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment access the App Service and test the functionality by uploading an image
