// Parameters
//////////////////////////////////////////////////
@description('The allocation dateTime in UTC')
param allocationStartTime string 

@description('The name of the Automation Account.')
param automationAccountName string

@description('The job schedule of the Azure Automation Runbook for App Service scale down.')
param automationJobScheduleAppServiceScaleDownName string

@description('The job schedule of the Azure Automation Runbook for App Service scale Up.')
param automationJobScheduleAppServiceScaleUpName string

@description('The job schedule of the Azure Automation Runbook for Virtual Machine Allocate.')
param automationJobScheduleVirtualMachineAllocateName string

@description('The job schedule of the Azure Automation Runbook for Virtual Machine Deallocate.')
param automationJobScheduleVirtualMachineDeallocateName string

@description('The name of the Azure Automation Runbook for App Service scale down.')
param automationRunbookAppServiceScaleDownName string

@description('The name of the Azure Automation Runbook for App Service scale Up.')
param automationRunbookAppServiceScaleUpName string

@description('The name of the Azure Automation Runbook for Virtual Machine Allocate.')
param automationRunbookVirtualMachineAllocateName string

@description('The name of the Azure Automation Runbook for Virtual Machine Deallocate.')
param automationRunbookVirtualMachineDeallocateName string

@description('The schedule of the Azure Automation Runbook for App Service scale down.')
param automationScheduleAppServiceScaleDownName string

@description('The schedule of the Azure Automation Runbook for App Service scale Up.')
param automationScheduleAppServiceScaleUpName string

@description('The schedule of the Azure Automation Runbook for Virtual Machine Allocate.')
param automationScheduleVirtualMachineAllocateName string

@description('The schedule of the Azure Automation Runbook for Virtual Machine Deallocate.')
param automationScheduleVirtualMachineDeallocateName string

@description('The deallocation dateTime in UTC')
param deallocationStartTime string 

@description('The location for all resources.')
param location string

// Resource - Automation Runbook - App Service Scale Down
//////////////////////////////////////////////////
resource automationRunbookAppServiceScaleDown 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: '${automationAccountName}/${automationRunbookAppServiceScaleDownName}'
  location: location
  properties: {
    runbookType: 'PowerShell'
    logVerbose: true
    logProgress: true
    publishContentLink: {
      uri:'https://raw.githubusercontent.com/azuredemoenvironment/ade/scripts/automation_runbooks/app_service_scale_down.ps1'
    }
  }
}

// Resource - Automation Schedule - App Service Scale Down
//////////////////////////////////////////////////
resource automationScheduleAppServiceScaleDown 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: '${automationAccountName}/${automationScheduleAppServiceScaleDownName}'  
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: deallocationStartTime
    timeZone: 'Etc/UTC'
  }
}

// Resource - Automation Job Schedule - App Service Scale Down
//////////////////////////////////////////////////
resource automationJobScheduleAppServiceScaleDown 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: '${automationAccountName}/${automationJobScheduleAppServiceScaleDownName}'
  properties: {
    runbook: {
      name: automationRunbookAppServiceScaleDownName
    }
    schedule: {
      name: automationScheduleAppServiceScaleDownName
    }
  }
}

// Resource - Automation Runbook - App Service Scale Up
//////////////////////////////////////////////////
resource automationRunbookAppServiceScaleUp 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: '${automationAccountName}/${automationRunbookAppServiceScaleUpName}'
  location: location
  properties: {
    runbookType: 'PowerShell'
    logVerbose: true
    logProgress: true
    publishContentLink: {
      uri:'https://raw.githubusercontent.com/azuredemoenvironment/ade/scripts/automation_runbooks/app_service_scale_up.ps1'
    }
  }
}

// Resource - Automation Schedule - App Service Scale Up
//////////////////////////////////////////////////
resource automationScheduleAppServiceScaleUp 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: '${automationAccountName}/${automationScheduleAppServiceScaleUpName}'
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: allocationStartTime
    timeZone: 'Etc/UTC'
  }
}

// Resource - Automation Job Schedule - App Service Scale Up
//////////////////////////////////////////////////
resource automationJobScheduleAppServiceScaleUp 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: '${automationAccountName}/${automationJobScheduleAppServiceScaleUpName}'
  properties: {
    runbook: {
      name: automationRunbookAppServiceScaleUpName
    }
    schedule: {
      name: automationScheduleAppServiceScaleUpName
    }
  }
}

// Resource - Automation Runbook - Virtual Machine Allocate
//////////////////////////////////////////////////
resource automationRunbookVirtualMachineAllocate 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: '${automationAccountName}/${automationRunbookVirtualMachineAllocateName}'
  location: location
  properties: {
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/scripts/azure_automation/virtual_machine_allocate.ps1'
    }
  }
}

// Resource - Automation Schedule - Virtual Machine Allocate
//////////////////////////////////////////////////
resource automationScheduleVirtualMachineAllocate 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: '${automationAccountName}/${automationScheduleVirtualMachineAllocateName}'
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: allocationStartTime
    timeZone: 'Etc/UTC'
  }
}

// Resource - Automation Job Schedule - Virtual Machine Allocate
//////////////////////////////////////////////////
resource automationJobScheduleVirtualMachineAllocate 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: '${automationAccountName}/${automationJobScheduleVirtualMachineAllocateName}'
  properties: {
    runbook: {
      name: automationRunbookVirtualMachineAllocateName
    }
    schedule: {
      name: automationScheduleVirtualMachineAllocateName
    }
  }
}

// Resource - Automation Runbook - Virtual Machine Deallocate
//////////////////////////////////////////////////
resource automationRunbookVirtualMachineDeallocate 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: '${automationAccountName}/${automationRunbookVirtualMachineDeallocateName}'
  location: location
  properties: {
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/scripts/azure_automation/virtual_machine_deallocate.ps1'
    }
  }
}

// Resource - Automation Schedule - Virtual Machine Deallocate
//////////////////////////////////////////////////
resource automationScheduleVirtualMachineDeallocate 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: '${automationAccountName}/${automationScheduleVirtualMachineDeallocateName}'
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: deallocationStartTime
    timeZone: 'Etc/UTC'
  }
}

// Resource - Automation Job Schedule - Virtual Machine Deallocate
//////////////////////////////////////////////////
resource automationJobScheduleVirtualMachineDeallocate 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: '${automationAccountName}/${automationJobScheduleVirtualMachineDeallocateName}'
  properties: {
    runbook: {
      name: automationRunbookVirtualMachineDeallocateName
    }
    schedule: {
      name: automationScheduleVirtualMachineDeallocateName
    }
  }
}
