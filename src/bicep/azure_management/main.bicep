// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The App ScaleDown job schedule guid')
param automationJobScheduleAppServiceScaleDownName string = newGuid()

@description('The App ScaleUp job schedule guid')
param automationJobScheduleAppServiceScaleUpName string = newGuid()

@description('The VM Allocation job schedule guid')
param automationJobScheduleVirtualMachineAllocateName string = newGuid()

@description('The VM deallocation job schedule guid')
param automationJobScheduleVirtualMachineDeallocateName string = newGuid()

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The current time.')
param currentTime string = utcNow('yyyy-MM-ddTHH:mm:ss')

@description('The name of the application environment.')
@allowed([
  'dev'
  'prod'
  'test'
])
param environment string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  environment: environment
  owner: ownerName
}

// Variables - Log Analytics
//////////////////////////////////////////////////
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var logAnalyticsWorkspaceRetentionInDays = 30
var logAnalyticsWorkspaceSolutions = [
  {
    name: 'ContainerInsights(${logAnalyticsWorkspaceName})'
    galleryName: 'ContainerInsights'
  }
  {
    name: 'KeyVaultAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'KeyVaultAnalytics'
  }
  {
    name: 'VMInsights(${logAnalyticsWorkspaceName})'
    galleryName: 'VMInsights'
  }
]

// Variables - Storage Account
//////////////////////////////////////////////////
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')
var storageAccountProperties = {
  accessTier: 'Hot'
  httpsOnly: true
  kind: 'StorageV2'
  sku: 'Standard_GRS'
}

// Variables - Event Hub
//////////////////////////////////////////////////
var eventHubName = 'evh-${appEnvironment}-diagnostics'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var eventHubNamespaceProperties = {
  autoInflate: false
  authorizationRuleName: 'RootManageSharedAccessKey'
  messageRetention: 1
  partitions: 1
  rights: ['Listen', 'Manage', 'Send']
  sku: 'Basic'
  skuCapacity: 1
}

// Variables - Application Insights
//////////////////////////////////////////////////
var applicationInsightsName = 'appinsights-${appEnvironment}'

// Variables - Automation
//////////////////////////////////////////////////
var allocationStartTime = '08:00:00'
var allocationTime = dateTimeAdd('${currentDate}T${allocationStartTime}', dateTimeToEpoch('${currentDate}T${allocationStartTime}') > nowTicks + offsetInSeconds ? 'P0D' : 'P1D')
var automationAccountName = 'aa-${appEnvironment}'
var automationAccountPrincipalIdType = 'ServicePrincipal'
var automationAccountProperties = {
  identityType: 'SystemAssigned'
  keySource: 'Microsoft.Automation'
  publicNetworkAccess: false
  sku: 'Basic'
}
var automationRunbooks = [
  {
    frequency: 'Day'
    interval: 1
    jobScheduleName: automationJobScheduleAppServiceScaleDownName
    logProgress: true
    logVerbose: true
    runbookName: 'runbook-app-service-scale-down'
    runbookType: 'PowerShell'
    scheduleName: 'runbook-schedule-app-service-scale-down'
    startTime: deallocationTime
    timeZone: 'Etc/UTC'
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/joshuawaddell/issue/189-Refactoring-and-Standardization-of-Names-Terms-Types-etc-after-v20-Merge/scripts/automation_runbooks/app_service_scale_down.ps1'
  }
  {
    frequency: 'Day'
    interval: 1
    jobScheduleName: automationJobScheduleAppServiceScaleUpName
    logProgress: true
    logVerbose: true
    runbookName: 'runbook-app-service-scale-up'
    runbookType: 'PowerShell'
    scheduleName: 'runbook-schedule-app-service-scale-up'
    startTime: allocationTime
    timeZone: 'Etc/UTC'
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/joshuawaddell/issue/189-Refactoring-and-Standardization-of-Names-Terms-Types-etc-after-v20-Merge/scripts/automation_runbooks/app_service_scale_up.ps1'
  }
  {
    frequency: 'Day'
    interval: 1
    jobScheduleName: automationJobScheduleVirtualMachineAllocateName
    logProgress: true
    logVerbose: true
    runbookName: 'runbook-virtual-machine-allocate'
    runbookType: 'PowerShell'
    scheduleName: 'runbook-schedule-virtual-machine-allocate'
    startTime: allocationTime
    timeZone: 'Etc/UTC'
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/joshuawaddell/issue/189-Refactoring-and-Standardization-of-Names-Terms-Types-etc-after-v20-Merge/scripts/automation_runbooks/virtual_machine_allocate.ps1'
  }
  {
    frequency: 'Day'
    interval: 1
    jobScheduleName: automationJobScheduleVirtualMachineDeallocateName
    logProgress: true
    logVerbose: true
    runbookName: 'runbook-virtual-machine-deallocate'
    runbookType: 'PowerShell'
    scheduleName: 'runbook-schedule-virtual-machine-deallocate'
    startTime: deallocationTime
    timeZone: 'Etc/UTC'
    uri: 'https://raw.githubusercontent.com/azuredemoenvironment/ade/joshuawaddell/issue/189-Refactoring-and-Standardization-of-Names-Terms-Types-etc-after-v20-Merge/scripts/automation_runbooks/virtual_machine_deallocate.ps1'    
  }
]
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
var deallocationStopTime = '21:00:00'
var deallocationTime = dateTimeAdd('${currentDate}T${deallocationStopTime}', dateTimeToEpoch('${currentDate}T${deallocationStopTime}') > nowTicks + offsetInSeconds ? 'P0D' : 'P1D')
var nowTicks = dateTimeToEpoch(currentTime)
var offsetInSeconds = 300

// Variables - Activity Log
//////////////////////////////////////////////////
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'

// Variables - Azure Policy
//////////////////////////////////////////////////
var auditVirtualMachinesWithoutDisasterRecoveryConfiguredGuid = '/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56'
var initiativeDefinitionName = 'policy-${appEnvironment}-adeinitiative'
var initiativeDefinitionEnforcementMode = 'Default'

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule 'log_analytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsWorkspaceRetentionInDays: logAnalyticsWorkspaceRetentionInDays
    logAnalyticsWorkspaceSolutions: logAnalyticsWorkspaceSolutions
    tags: tags
  }
}

// Module - Storage Account
//////////////////////////////////////////////////
module storageAccountModule 'storage_account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountProperties: storageAccountProperties
    storageAccountName: storageAccountName
    tags: tags
  }
}

// Module - Event Hub
//////////////////////////////////////////////////
module eventHubDiagnosticsModule 'event_hub.bicep' = {
  name: 'eventHubDiagnosticsDeployment'
  params: {
    eventHubName: eventHubName
    eventHubNamespaceName: eventHubNamespaceName
    eventHubNamespaceProperties: eventHubNamespaceProperties
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Module - Application Insights
//////////////////////////////////////////////////
module applicationInsightsModule './application_insights.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    applicationInsightsName: applicationInsightsName
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountId: storageAccountModule.outputs.storageAccountId
    tags: tags
  }
}

// Module - Automation
//////////////////////////////////////////////////
module automationModule 'automation.bicep' = {
  name: 'automationDeployment'
  params: {
    automationAccountName: automationAccountName
    automationAccountProperties: automationAccountProperties
    automationRunbooks: automationRunbooks
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountId: storageAccountModule.outputs.storageAccountId
    tags: tags
  }
}

// Module - Automation - Role Assignment
//////////////////////////////////////////////////
module automationRoleAssignmentModule 'automation_role_assignment.bicep' = {
  scope: subscription()
  name: 'automationRoleAssignmentDeployment'
  params: {
    automationAccountPrincipalId: automationModule.outputs.automationAccountPrincipalId
    automationAccountPrincipalIdType: automationAccountPrincipalIdType
    contributorRoleDefinitionId: contributorRoleDefinitionId
  }
}

// Module - Activity Log
//////////////////////////////////////////////////
module activityLogModule './activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    activityLogDiagnosticSettingsName: activityLogDiagnosticSettingsName
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountId: storageAccountModule.outputs.storageAccountId
  }
}

// Module - Policy
// //////////////////////////////////////////////////
module policyModule 'policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    auditVirtualMachinesWithoutDisasterRecoveryConfigured: auditVirtualMachinesWithoutDisasterRecoveryConfiguredGuid
    initiativeDefinitionEnforcementMode: initiativeDefinitionEnforcementMode
    initiativeDefinitionName: initiativeDefinitionName

  }
}
