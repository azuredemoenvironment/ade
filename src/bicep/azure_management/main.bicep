// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The App ScaleDown job schedule guid.')
param automationJobScheduleAppServiceScaleDownName string = newGuid()

@description('The App ScaleUp job schedule guid.')
param automationJobScheduleAppServiceScaleUpName string = newGuid()

@description('The VM Allocation job schedule guid.')
param automationJobScheduleVirtualMachineAllocateName string = newGuid()

@description('The VM deallocation job schedule guid.')
param automationJobScheduleVirtualMachineDeallocateName string = newGuid()

@description('The Email Address used for Alerts and Notifications.')
param contactEmailAddress string

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

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The start date of the Budget.')
param startDate string = '${utcNow('yyyy-MM')}-01'

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
    name: 'DnsAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'DnsAnalytics'
  }
  {
    name: 'KeyVaultAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'KeyVaultAnalytics'
  }
  {
    name: 'LogicAppsManagement(${logAnalyticsWorkspaceName})'
    galleryName: 'LogicAppsManagement'
  }
  {
    name: 'AzureSQLAnalytics(${logAnalyticsWorkspaceName})'
    galleryName: 'AzureSQLAnalytics'
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
  name: storageAccountName
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
  eventHubName: eventHubName
  eventHubNamespaceName: eventHubNamespaceName
  messageRetention: 1
  partitions: 1
  rights: ['Listen', 'Manage', 'Send']
  sku: 'Basic'
  skuCapacity: 1
}

// Variables - Data Collection Rule
//////////////////////////////////////////////////
var dataCollectionRuleName = 'dcr-${appEnvironment}-vmInsights'

// Variables - Application Insights
//////////////////////////////////////////////////
var applicationInsightsName = 'appinsights-${appEnvironment}'

// Variables - Action Group
//////////////////////////////////////////////////
var actionGroups = [
  {
    name: 'ag-${appEnvironment}-budget'
    enabled: true
    groupShortName: 'ag-budget'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-servicehealth'
    enabled: true
    groupShortName: 'ag-svchealth'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-virtualmachine'
    enabled: true
    groupShortName: 'ag-vm'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
  {
    name: 'ag-${appEnvironment}-virtualnetwork'
    enabled: true
    groupShortName: 'ag-vnet'
    emailReceiversName: 'email'
    emailAddress: contactEmailAddress
    useCommonAlertSchema: true
  }
]

// Variables - Activity Log Alert
//////////////////////////////////////////////////
var activityLogAlerts = [
  {
    name: 'service health'
    description: 'service health'
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupModule.outputs.actionGroupIds[1].actionGroupId
        }
      ]
    }
  }
  {
    name: 'virtual machines - all administrative operations'
    description: 'virtual machines - all administrative operations'
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'resourceType'
          equals: 'microsoft.compute/virtualmachines'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupModule.outputs.actionGroupIds[3].actionGroupId
        }
      ]
    }
  }
  {
    name: 'virtual networks - all administrative operations'
    description: 'virtual networks - all administrative operations'
    enabled: true
    scopes: [
      subscription().id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'resourceType'
          equals: 'Microsoft.Network/virtualNetworks'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupModule.outputs.actionGroupIds[2].actionGroupId
        }
      ]
    }
  }
]

// Variables - Automation
//////////////////////////////////////////////////
var allocationStartTime = '08:00:00'
var allocationTime = dateTimeAdd('${currentDate}T${allocationStartTime}', dateTimeToEpoch('${currentDate}T${allocationStartTime}') > nowTicks + offsetInSeconds ? 'P0D' : 'P1D')
var automationAccountName = 'aa-${appEnvironment}'
var automationAccountPrincipalIdType = 'ServicePrincipal'
var automationAccountProperties = {
  name: automationAccountName
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
    uri: '${scriptsBaseUri}/automation_runbooks/app_service_scale_down.ps1'
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
    uri: '${scriptsBaseUri}/automation_runbooks/app_service_scale_up.ps1'
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
    uri: '${scriptsBaseUri}/automation_runbooks/virtual_machine_allocate.ps1'
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
    uri: '${scriptsBaseUri}/automation_runbooks/virtual_machine_deallocate.ps1'
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
var initiativeDefinitions = [
  {
    name: initiativeDefinitionName
    policyType: 'Custom'
    displayName: initiativeDefinitionName
    description: 'Initiative Definition for the Azure Demo Environment'
    category: ' Initiative'
    policyDefinitions: [
      {
        policyDefinitionId: auditVirtualMachinesWithoutDisasterRecoveryConfiguredGuid
        parameters: {}
      }
    ]
    enforcementMode: 'Default'
  }
]

// Variables - Budget
//////////////////////////////////////////////////
var budgetProperties = {
  name: 'budget-${appEnvironment}-monthly'
  startDate: startDate
  timeGrain: 'Monthly'
  amount: 1500
  category: 'Cost'
  operator: 'GreaterThan'
  enabled: true
  firstThreshold: 10
  secondThreshold: 50
  thirdThreshold: 100
  forecastedThreshold: 150
  contactEmails: contactEmailAddress
  contactGroups: actionGroupModule.outputs.actionGroupIds[0].actionGroupId
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

// Module - Storage Account
//////////////////////////////////////////////////
module storageAccountModule 'storage_account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountProperties: storageAccountProperties
    tags: tags
  }
}

// Module - Event Hub
//////////////////////////////////////////////////
module eventHubDiagnosticsModule 'event_hub.bicep' = {
  name: 'eventHubDiagnosticsDeployment'
  params: {
    eventHubNamespaceProperties: eventHubNamespaceProperties
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Module - Data Collection Rule
//////////////////////////////////////////////////
module dataCollectionRuleModule 'data_collection_rule.bicep' = {
  name: 'dataCollectionRuleDeployment'
  params: {
    dataCollectionRuleName: dataCollectionRuleName
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

// Module - Action Group
//////////////////////////////////////////////////
module actionGroupModule 'action_group.bicep' = {
  name: 'actionGroupsDeployment'
  params: {
    actionGroups: actionGroups
    tags: tags
  }
}

// Module - Activity Log Alert
//////////////////////////////////////////////////
module alertsModule 'activity_log_alert.bicep' = {
  name: 'alertsDeployment'
  params: {
    activityLogAlerts: activityLogAlerts
    tags: tags
  }
}

// Module - Automation
//////////////////////////////////////////////////
module automationModule 'automation.bicep' = {
  name: 'automationDeployment'
  params: {
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
    initiativeDefinitions: initiativeDefinitions

  }
}

// Module - Budget
//////////////////////////////////////////////////
module budgetModule 'budget.bicep' = {
  scope: subscription()
  name: 'budgetDeployment'
  params: {
    budgetProperties: budgetProperties
  }
}
