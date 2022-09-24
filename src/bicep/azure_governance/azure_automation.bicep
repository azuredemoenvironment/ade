// Parameters
//////////////////////////////////////////////////

@description('The name of the Azure Automation.')
param azureAutomationName string

@description('The name of the Azure Automation Runbook.')
param azureAutomationAppScaleUpRunbookName string

@description('The name of the Azure Automation Runbook.')
param azureAutomationAppScaleDownRunbookName string

@description('The name of the Azure Automation Runbook.')
param azureAutomationVmStopRunbookName string

@description('The name of the Azure Automation Runbook.')
param azureAutomationVmStartRunbookName string

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

  resource azureAutomationAppScaleUpRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
    name: azureAutomationAppScaleUpRunbookName
    location: location
    parent: azureAutomation
    properties: {
     runbookType: 'PowerShell'
     logVerbose: true
     logProgress: true
  }
}
  
resource azureAutomationAppScaleDownRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: azureAutomationAppScaleDownRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
}
}
  
   

resource azureAutomationVmStopRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: azureAutomationVmStopRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
}
}
  

resource azureAutomationVmStartRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: azureAutomationVmStartRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
}
}
  