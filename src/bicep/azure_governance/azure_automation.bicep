// Parameters
//////////////////////////////////////////////////

@description('The name of the Azure Automation.')
param azureAutomationName string

@description('The location for all resources.')
param location string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'automation'
  costCenter: 'it'
}

resource azureAutomation 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: azureAutomationName
  location:location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    }
    properties: {
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
   publicNetworkAccess: true
   sku: {
    name: 'basic'
   }

   }
  }
   

