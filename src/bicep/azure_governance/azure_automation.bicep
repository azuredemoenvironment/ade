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
param vmDeallocationLinkScheduleName string

@description('The allocation dateTime in UTC')
param allocationStartTime string 

@description('The deallocation dateTime in UTC')
param deallocationStartTime string 


@description('The location for all resources.')
param location string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'automation'
  costCenter: 'it'
}

resource azureAutomation 'Microsoft.Automation/automationAccounts@2022-08-08' = {
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
   publicNetworkAccess: false
   sku: {
    name: 'basic'
   }

   }
  }

  //Azure Automation Role Assignment
  @description('A new GUID used to identify the role assignment')
   param roleVMNameGuid string = guid('VirtualMachineContributor')
   var VirtualMachineContributor = 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
   resource vmRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: roleVMNameGuid
      properties: {
      principalId: azureAutomation.identity.principalId
      roleDefinitionId: VirtualMachineContributor
      principalType: 'ServicePrincipal'
    }
   }
  
//appscaleuprunbook

  resource azureAutomationAppScaleUpRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
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

resource azureAutomationAppScaleDownRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: azureAutomationAppScaleDownRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
}
}
  
   
//VmDeallocation
resource azureAutomationVmStopRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: azureAutomationVmStopRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
   publishContentLink: {
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/sjkaursb93/217-azure-runbook-scaleupdown/scripts/azure_automation/azure_vms_auto_shutdown.ps1'
   }
}
}
//VmDeallocationSchedule
resource azureAutomationVmDeallocationSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: azureAutomationVmDeallocationScheduleName
  parent: azureAutomation
  properties: {
    timeZone: 'Etc/UTC'
    startTime: deallocationStartTime
    interval: 1
    frequency: 'Day'   
  } 

}
  
//VmAllocation
resource azureAutomationVmStartRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: azureAutomationVmStartRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
   publishContentLink: {
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/sjkaursb93/217-azure-runbook-scaleupdown/scripts/azure_automation/azure_vms_auto_start.ps1'
  }
}
}
  


//VmDeallocationScheduleWithRunbook
resource vmDeallocationLinkSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: vmDeallocationLinkScheduleName
  parent: azureAutomation
  // dependsOn:[
  //   //azureAutomationVmStopRunbook
  //   azureAutomationVmDeallocationSchedule
  // ]
    properties: {
      runbook: {
        name: azureAutomationVmStopRunbookName
      }
      schedule: {
        name: azureAutomationVmDeallocationScheduleName
      }
    
  }

}
