# Azure Cognitive Services

- [Azure Cognitive Services Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/ "Azure Cognitive Services Documentation")
- [Azure Cognitive Services Computer Vision Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/computer-vision/index "Azure Cognitive Services Computer Vision Documentation")
- [Azure Cognitive Services Text Analytics Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/text-analytics/index "Azure Cognitive Services Text Analytics Documentation")

## Description

The Azure Cognitive Services deployment creates instances of Computer Vision and Text Analytics services. Diagnostic settings are enabled for all resources utilizing Azure Log Analytics for log and metric storage.

## Files Used

- azure_cognitive_services.json
- azure_cognitive_services.parameters.json

The values for all parameters will be automatically generated based on the values provided at script execution.

## Post-Deployment

Following deployment, execute the following tasks:

- Record the Azure Cognitive Services Computer Vision Endpoint and API Key
- Record the Azure Cognitive Services Text Analytics Endpoint and API Key

To find the Cognitive Services Computer Vision Endpoint and API Key, in the Azure Portal, navigate to Cognitive Services, select "ComputerVision" from the Cognitive Services blade, select "Quick Start" and copy the Endpoint and Key1 value.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](https://raw.githubusercontent.com/Mitaric/AzureDemoEnvironment/master/images/computervision.JPG "Computer Vision Endpoint and Key")

To find the Cognitive Services Computer Vision Endpoint and API Key, in the Azure Portal, navigate to Cognitive Services, select "Text Analytics" from the Cognitive Services blade, select "Quick Start" and copy the Endpoint and Key1 value.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](https://raw.githubusercontent.com/Mitaric/AzureDemoEnvironment/master/images/textanalytics.JPG "Text Analytics Endpoint and Key")
