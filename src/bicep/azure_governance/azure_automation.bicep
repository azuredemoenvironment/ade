// Parameters
//////////////////////////////////////////////////

@description('The name of the Azure Automation.')
param azureAutomationName string

@description('The name of the Azure Automation App Scale Down Runbook.')
param azureAutomationAppScaleDownRunbookName string

@description('The name of the Azure Automation App Scale Down Schedule.')
param azureAutomationAppScaleDownScheduleName string

@description('The name of the Azure Automation App Scale Down Job.')
param appScaleDownLinkScheduleName string

@description('The name of the Azure Automation App Scale Up Runbook.')
param azureAutomationAppScaleUpRunbookName string

@description('The name of the Azure Automation App Scale Up Schedule.')
param azureAutomationAppScaleUpScheduleName string

@description('The name of the Azure Automation App Scale Up Job.')
param appScaleUpLinkScheduleName string

@description('The name of the Azure Automation VM Deallocation Runbook.')
param azureAutomationVmStopRunbookName string

@description('The name of the Azure Automation VM Deallocation Schedule.')
param azureAutomationVmDeallocationScheduleName string

@description('The name of the Azure Automation VM Deallocation Job.')
param vmDeallocationLinkScheduleName string

@description('The name of the Azure Automation VM Allocation Runbook.')
param azureAutomationVmStartRunbookName string

@description('The name of the Azure Automation VM Allocation Schedule.')
param azureAutomationVmAllocationScheduleName string

@description('The name of the Azure Automation VM Allocation Job.')
param vmAllocationLinkScheduleName string

@description('The allocation dateTime in UTC')
param allocationStartTime string 

@description('The deallocation dateTime in UTC')
param deallocationStartTime string 


@description('The location for all resources.')
param location string

// @description('The managed identity name')
// param automationAccountManagedIdentityPrincipalIdName string


// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'automation'
  costCenter: 'it'
}

//Azure Automation Account Creation
resource azureAutomation 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: azureAutomationName
  location:location
  tags: tags
  identity: {
   type: 'SystemAssigned'
    // userAssignedIdentities: {
    //   '${automationAccountManagedIdentityPrincipalIdName}':{}
    // }
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
  output AutAccountPrincipalId string = azureAutomation.identity.principalId


//AppScaleDownRunbook

resource azureAutomationAppScaleDownRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: azureAutomationAppScaleDownRunbookName
  location: location
  parent: azureAutomation
  properties: {
   runbookType: 'PowerShell'
   logVerbose: true
   logProgress: true
   publishContentLink: {
    uri:'https://raw.githubusercontent.com/azuredemoenvironment/ade/sjkaursb93/217-azure-runbook-scaleupdown/scripts/azure_automation/azure_apps_vertical_scaledown.ps1'
   }
}
}
  
//AppScaleDownSchedule
resource azureAutomationAppScaleDownSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: azureAutomationAppScaleDownScheduleName
  parent: azureAutomation
  properties: {
    timeZone: 'Etc/UTC'
    startTime: deallocationStartTime
    interval: 1
    frequency: 'Day'   
  } 

}

//AppScaleDownScheduleWithRunbook
resource appScaleDownLinkSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: appScaleDownLinkScheduleName
  parent: azureAutomation
    properties: {
      runbook: {
        name: azureAutomationAppScaleDownRunbookName
      }
      schedule: {
        name: azureAutomationAppScaleDownScheduleName
      }
    
  }

}

//AppScaleUpRunbook

  resource azureAutomationAppScaleUpRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
    name: azureAutomationAppScaleUpRunbookName
    location: location
    parent: azureAutomation
    properties: {
     runbookType: 'PowerShell'
     logVerbose: true
     logProgress: true
     publishContentLink: {
      uri:'https://raw.githubusercontent.com/azuredemoenvironment/ade/sjkaursb93/217-azure-runbook-scaleupdown/scripts/azure_automation/azure_apps_vertical_scaleup.ps1'
     }
    }
}
 

//AppScaleUpSchedule
resource azureAutomationAppScaleUpSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: azureAutomationAppScaleUpScheduleName
  parent: azureAutomation
  properties: {
    timeZone: 'Etc/UTC'
    startTime: allocationStartTime
    interval: 1
    frequency: 'Day'   
  } 

}

//AppScaleUpScheduleWithRunbook
resource appScaleUpLinkSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: appScaleUpLinkScheduleName
  parent: azureAutomation
    properties: {
      runbook: {
        name: azureAutomationAppScaleUpRunbookName
      }
      schedule: {
        name: azureAutomationAppScaleUpScheduleName
      }
    
  }

}
   
//VmDeAllocationRunbook
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

//VmDeallocationScheduleWithRunbook
resource vmDeallocationLinkSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: vmDeallocationLinkScheduleName
  parent: azureAutomation
    properties: {
      runbook: {
        name: azureAutomationVmStopRunbookName
      }
      schedule: {
        name: azureAutomationVmDeallocationScheduleName
      }
    
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

//VmAllocationSchedule
resource azureAutomationVmAllocationSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: azureAutomationVmAllocationScheduleName
  parent: azureAutomation
  properties: {
    timeZone: 'Etc/UTC'
    startTime: allocationStartTime
    interval: 1
    frequency: 'Day'   
  } 

}


//VmAllocationScheduleWithRunbook
resource vmAllocationLinkSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: vmAllocationLinkScheduleName
  parent: azureAutomation
    properties: {
      runbook: {
        name: azureAutomationVmStartRunbookName
      }
      schedule: {
        name: azureAutomationVmAllocationScheduleName
      }
    
  }

}
  
