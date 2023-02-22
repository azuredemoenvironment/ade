// Parameters
//////////////////////////////////////////////////
@description('The allocation dateTime in UTC')
param allocationStartTime string 

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

@description('The deallocation dateTime in UTC')
param deallocationStartTime string 

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The name of the application environment.')
@allowed([
  'dev'
  'prod'
  'test'
])
param environment string

@description('The list of allowed locations for resource deployment. Used in Azure Policy module.')
param listOfAllowedLocations array

@description('The list of allowed virtual machine SKUs. Used in Azure Policy module.')
param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
]

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the owner of the deployment.')
param ownerName string

// Variables
//////////////////////////////////////////////////
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'
var allowedLocations = '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
var allowedLocationsForResourceGroups = '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
var allowedVirtualMachineSizeSkus = '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
var applicationInsightsName = 'appinsights-${appEnvironment}-001'
var auditVirtualMachinesWithoutDisasterRecoveryConfigured = '/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56'
var automationAccountName = 'aa-${appEnvironment}-001'
var automationAccountSku = 'Basic'
var automationRunbookAppServiceScaleDownName = 'runbook-app-service-scale-down'
var automationRunbookAppServiceScaleUpName = 'runbook-app-service-scale-up'
var automationRunbookVirtualMachineAllocateName = 'runbook-virtual-machine-allocate'
var automationRunbookVirtualMachineDeallocateName = 'runbook-virtual-machine-deallocate'
var automationScheduleAppServiceScaleDownName = 'runbook-schedule-app-service-scale-down'
var automationScheduleAppServiceScaleUpName = 'runbook-schedule-app-service-scale-up'
var automationScheduleVirtualMachineAllocateName = 'runbook-schedule-virtual-machine-allocate'
var automationScheduleVirtualMachineDeallocateName = 'runbook-schedule-virtual-machine-deallocate'
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
var eventHubMessageRetention = 1
var eventHubName = 'diagnostics'
var eventHubNamespaceAutoInflate = false
var eventHubNamespaceName = 'evh-${appEnvironment}-diagnostics'
var eventHubNamespaceSku = 'Basic'
var eventHubNamespaceSkuCapacity = 1
var eventHubPartitions = 1
var initiativeDefinitionName = 'policy-${appEnvironment}-adeinitiative'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}-001'
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
var storageAccountAccessTier = 'Hot'
var storageAccountKind = 'StorageV2'
var storageAccountName = replace('sa-${appEnvironment}-diags', '-', '')
var storageAccountSku = 'Standard_LRS'
var tags = {
  deploymentDate: deploymentDate
  environment: environment
  owner: ownerName
}

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

// Module - Storage Account - Diagnostics
//////////////////////////////////////////////////
module storageAccountDiagnosticsModule 'storage_account.bicep' = {
  name: 'storageAccountDiagnosticsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountAccessTier: storageAccountAccessTier
    storageAccountKind: storageAccountKind
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    tags: tags
  }
}

// Module - Event Hub
//////////////////////////////////////////////////
module eventHubDiagnosticsModule 'event_hub.bicep' = {
  name: 'eventHubDiagnosticsDeployment'
  params: {
    eventHubMessageRetention: eventHubMessageRetention
    eventHubName: eventHubName
    eventHubNamespaceAutoInflate: eventHubNamespaceAutoInflate
    eventHubNamespaceName: eventHubNamespaceName
    eventHubNamespaceSku: eventHubNamespaceSku
    eventHubNamespaceSkuCapacity: eventHubNamespaceSkuCapacity
    eventHubPartitions: eventHubPartitions
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
    storageAccountId: storageAccountDiagnosticsModule.outputs.storageAccountId
    tags: tags
  }
}

// Module - Automation Account
//////////////////////////////////////////////////
module automationAccountModule 'automation.bicep' = {
  name: 'automationAccountDeployment'
  params: {
    automationAccountName: automationAccountName
    automationAccountSku: automationAccountSku
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountId: storageAccountDiagnosticsModule.outputs.storageAccountId
    tags: tags
  }
}

// Module - Automation Runbooks
//////////////////////////////////////////////////
module automationRunbooksModule 'automation_runbooks.bicep' = {
  name: 'automationRunbooksDeployment'
  params: {
    allocationStartTime: allocationStartTime
    automationAccountName: automationAccountName
    automationJobScheduleAppServiceScaleDownName: automationJobScheduleAppServiceScaleDownName
    automationJobScheduleAppServiceScaleUpName: automationJobScheduleAppServiceScaleUpName
    automationJobScheduleVirtualMachineAllocateName: automationJobScheduleVirtualMachineAllocateName
    automationJobScheduleVirtualMachineDeallocateName: automationJobScheduleVirtualMachineDeallocateName
    automationRunbookAppServiceScaleDownName: automationRunbookAppServiceScaleDownName
    automationRunbookAppServiceScaleUpName: automationRunbookAppServiceScaleUpName
    automationRunbookVirtualMachineAllocateName: automationRunbookVirtualMachineAllocateName
    automationRunbookVirtualMachineDeallocateName: automationRunbookVirtualMachineDeallocateName
    automationScheduleAppServiceScaleDownName: automationScheduleAppServiceScaleDownName
    automationScheduleAppServiceScaleUpName: automationScheduleAppServiceScaleUpName
    automationScheduleVirtualMachineAllocateName: automationScheduleVirtualMachineAllocateName
    automationScheduleVirtualMachineDeallocateName: automationScheduleVirtualMachineDeallocateName
    deallocationStartTime: deallocationStartTime
    location: location
  }
}

// Module - Automation Role Assignment
//////////////////////////////////////////////////
module automationRoleAssignmentModule 'automation_role_assignment.bicep' = {
  name: 'automationRoleAssignmentDeployment'
  params: {
    automationAccountPrincipalId: automationAccountModule.outputs.automationAccountPrincipalId
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
    storageAccountId: storageAccountDiagnosticsModule.outputs.storageAccountId
  }
}

// Module - Policy
//////////////////////////////////////////////////
module policyModule 'policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    allowedLocations: allowedLocations
    allowedLocationsForResourceGroups: allowedLocationsForResourceGroups
    allowedVirtualMachineSizeSkus: allowedVirtualMachineSizeSkus
    auditVirtualMachinesWithoutDisasterRecoveryConfigured: auditVirtualMachinesWithoutDisasterRecoveryConfigured
    initiativeDefinitionName: initiativeDefinitionName
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
  }
}
