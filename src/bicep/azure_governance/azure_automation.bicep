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

@description('The name of the Azure Automation Runbook Schedule.')
param azureAutomationVmDeallocationScheduleName string

@description('The name of the Azure Automation Runbook Job.')
param azureAutomationDeallocationJobName string

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
  
//appscaleuprunbook

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
  
//appscaledownrunbook

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
  
   
//vmdeallocation
resource azureAutomationVmStopRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: azureAutomationVmStopRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
   publishContentLink: {
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/main/src/ps/private/VirtualMachines/Set-AzureVirtualMachinesToDeallocated.ps1'
   }
}
}
  
//VmAllocation
resource azureAutomationVmStartRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: azureAutomationVmStartRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
   publishContentLink: {
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/main/src/ps/private/VirtualMachines/Set-AzureVirtualMachinesToAllocated.ps1'
   }
}
}
  
//VmDeallocationSchedule
resource azureAutomationVmDeallocationSchedule 'Microsoft.Automation/automationAccounts/schedules@2020-01-13-preview' = {
  name: azureAutomationVmDeallocationScheduleName
  parent: azureAutomation
  properties: {
    timeZone: 'Etc/UTC'
    startTime: '2022-10-07T21:30:00+00:00' // do this as a parameter in powershell
    interval:1
    frequency: 'Day'   
  }

}

//VmDeallocationScheduleWithRunbook
resource azureAutomationDeallocationJob 'Microsoft.Automation/automationAccounts/jobSchedules@2020-01-13-preview' = {
  name: azureAutomationDeallocationJobName
  parent: azureAutomation
    properties: {
      parameters: {}
    runbook: {
      name: azureAutomationVmDeallocationScheduleName
    }
    schedule: {
      name: azureAutomationVmDeallocationScheduleName
    }
  }

}
