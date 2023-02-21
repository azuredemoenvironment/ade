// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The Base64 encoded certificate for Azure resources.')
param certificateBase64String string


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
param location string = deployment().location

@description('The password for Azure resources.')
param resourcePassword string

@description('The allocation dateTime in UTC')
param allocationStartTime string 

@description('The deAllocation dateTime in UTC')
param deallocationStartTime string 

@description('The VM deallocation job schedule guid')
param vmDeallocationLinkScheduleGuid string = newGuid() //because of an existing issue, guid solves the deployment issue with job schedule

@description('The VM Allocation job schedule guid')
param vmAllocationLinkScheduleGuid string = newGuid() //because of an existing issue, guid solves the deployment issue with job schedule\

@description('The App ScaleDown job schedule guid')
param appScaleDownLinkScheduleGuid string = newGuid() //because of an existing issue, guid solves the deployment issue with job schedule

@description('The App ScaleUp job schedule guid')
param appScaleUpLinkScheduleGuid string = newGuid() //because of an existing issue, guid solves the deployment issue with job schedule


// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfig'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkWatcherResourceGroupName = 'NetworkWatcherRG'
var azureAutomationResourceGroupName = 'rg-ade-${aliasRegion}-automation'
// Resources
var activityLogDiagnosticSettingsName = 'subscriptionactivitylog'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-applicationgateway'
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
var containerRegistryManagedIdentityName = 'id-ade-${aliasRegion}-containerregistry'
var diagnosticsEventHubName = 'diagnostics'
var diagnosticsEventHubNamespaceName = 'evh-ade-${aliasRegion}-diagnostics'
var diagnosticsStorageAccount = {
  accessTier: 'Cool'
  kind: 'StorageV2'
  name: replace('sa-ade-${aliasRegion}-diags', '-', '')
  sku: 'Standard_LRS'
}
var initiativeDefinitionName = 'policy-ade-${aliasRegion}-adeinitiative'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var nsgFlowLogsStorageAccount = {
  accessTier: 'Hot'
  kind: 'StorageV2'
  name: replace('sa-ade-${aliasRegion}-nsgflow', '-', '')
  sku: 'Standard_LRS'
}
//Sim added all the automation variables
var azureAutomationName = 'aa-ade-${aliasRegion}-001'
var azureAutomationAppScaleUpRunbook = 'appscaleuprunbook-ade-${aliasRegion}-001'
var azureAutomationAppScaleDownRunbook = 'appscaledownrunbook-ade-${aliasRegion}-001'
var azureAutomationAppScaleDownSchedule = 'appscaledownrunbookschedule-ade-${aliasRegion}-001'
var azureAutomationAppScaleUpSchedule = 'appscaleuprunbookschedule-ade-${aliasRegion}-001'
var appScaleDownLinkSchedule = appScaleDownLinkScheduleGuid
var appScaleUpLinkSchedule = appScaleUpLinkScheduleGuid
var azureAutomationVmStopRunbook = 'vmstoprunbook-ade-${aliasRegion}-001'
var azureAutomationVmStartRunbook = 'vmstartrunbook-ade-${aliasRegion}-001'
var azureAutomationVmDeallocationSchedule = 'vmstoprunbookschedule-ade-${aliasRegion}-001'
var vmDeallocationLinkSchedule = vmDeallocationLinkScheduleGuid
var azureAutomationVmAllocationSchedule = 'vmstartrunbookschedule-ade-${aliasRegion}-001'
var vmAllocationLinkSchedule = vmAllocationLinkScheduleGuid
//this role is needed for azure automation account to stop/start the VMs
var virtualMachineContributorId =resourceId('Microsoft.Authorization/roleDefinitions','9980e02c-c2be-4d73-94e8-173b1dc7cf3c')

//this role is needed for azure automation account to autoscale app services plan
var ContributorId =resourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')


// Resource Group - App Configuration
//////////////////////////////////////////////////
resource appConfigResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appConfigResourceGroupName
  location: azureRegion
}

// Resource Group - Identity
//////////////////////////////////////////////////
resource identityResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: identityResourceGroupName
  location: azureRegion
}


// Resource Group - Key Vault
//////////////////////////////////////////////////
resource keyVaultResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: keyVaultResourceGroupName
  location: azureRegion
}

// Resource Group - Monitor
//////////////////////////////////////////////////
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: monitorResourceGroupName
  location: azureRegion
}

// Resource Group - Network Watcher
//////////////////////////////////////////////////
resource networkWatcherResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: networkWatcherResourceGroupName
  location: azureRegion
}

//Resource Group - Azure Automation
////////////////////////////////////////////////
resource azureAutomationResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: azureAutomationResourceGroupName
  location: azureRegion
}

 
// Module - Network Watcher
//////////////////////////////////////////////////
module networkWatcherModule 'azure_network_watcher.bicep' = {
  scope: resourceGroup(networkWatcherResourceGroupName)
  name: 'networkWatcherDeployment'
  dependsOn: [
    networkWatcherResourceGroup
  ]
  params: {
    location: location
  }
}

// Module - Log Analytics Workspace
//////////////////////////////////////////////////
module logAnalyticsModule './azure_log_analytics.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'logAnalyticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// Module - Storage Account - Diagnostics
//////////////////////////////////////////////////
module storageAccountDiagnosticsModule './azure_storage_accounts.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountDiagnosticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountAccessTier: diagnosticsStorageAccount.accessTier
    storageAccountKind: diagnosticsStorageAccount.kind
    storageAccountName: diagnosticsStorageAccount.name
    storageAccountSku: diagnosticsStorageAccount.sku
  }
}

// Module - Storage Account - NSG Flow Logs
//////////////////////////////////////////////////
module storageAccountNsgFlowLogsModule './azure_storage_accounts.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'storageAccountNsgFlowLogsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    storageAccountAccessTier: nsgFlowLogsStorageAccount.accessTier
    storageAccountKind: nsgFlowLogsStorageAccount.kind
    storageAccountName: nsgFlowLogsStorageAccount.name
    storageAccountSku: nsgFlowLogsStorageAccount.sku
  }
}

// Module - Event Hub
//////////////////////////////////////////////////
module eventHubDiagnosticsModule './azure_event_hub.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'eventHubDiagnosticsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    eventHubName: diagnosticsEventHubName
    eventHubNamespaceName: diagnosticsEventHubNamespaceName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId   
  }
}

// Module - App Configuration
//////////////////////////////////////////////////
module appConfigModule './azure_app_config.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigDeployment'
  dependsOn: [
    appConfigResourceGroup
  ]
  params: {
    appConfigName: appConfigName
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId    
  }
}

// Module - Application Insights
//////////////////////////////////////////////////
module applicationInsightsModule './azure_application_insights.bicep' = {
  scope: resourceGroup(monitorResourceGroupName)
  name: 'applicationInsightsDeployment'
  dependsOn: [
    monitorResourceGroup
  ]
  params: {
    applicationInsightsName: applicationInsightsName
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - App Configuration - Application Insights
//////////////////////////////////////////////////
module appConfigApplicationInsightsModule './azure_app_config_application_insights.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'appConfigApplicationInsightsDeployment'
  params: {
    appConfigName: appConfigModule.outputs.appConfigName
    applicationInsightsConnectionString: applicationInsightsModule.outputs.applicationInsightsConnectionString
  }
}

// Module - Activity Log
//////////////////////////////////////////////////
module activityLogModule './azure_activity_log.bicep' = {
  scope: subscription()
  name: 'activityLogDeployment'
  params: {
    activityLogDiagnosticSettingsName: activityLogDiagnosticSettingsName
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Policy
//////////////////////////////////////////////////
module policyModule './azure_policy.bicep' = {
  scope: subscription()
  name: 'policyDeployment'
  params: {
    azureRegion: azureRegion
    initiativeDefinitionName: initiativeDefinitionName
    listOfAllowedLocations: listOfAllowedLocations
    listOfAllowedSKUs: listOfAllowedSKUs
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
  }
}

// Module - Identity
//////////////////////////////////////////////////
module identityModule 'azure_identity.bicep' = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'identityDeployment'
  dependsOn: [
    identityResourceGroup
  ]
  params: {
    applicationGatewayManagedIdentityName: applicationGatewayManagedIdentityName
    containerRegistryManagedIdentityName: containerRegistryManagedIdentityName
   // automationAccountManagedIdentityName: automationAccountManagedIdentityName
    location: location
  }
}


// Module - Key Vault
//////////////////////////////////////////////////
module keyVaultModule './azure_key_vault.bicep' = {
  scope: resourceGroup(keyVaultResourceGroupName)
   name: 'logAnalyticsDeployment'
  dependsOn: [
    keyVaultResourceGroup
  ]
  params: {
    applicationGatewayManagedIdentityPrincipalID: identityModule.outputs.applicationGatewayManagedIdentityPrincipalId
    certificateBase64String: certificateBase64String
    containerRegistryManagedIdentityPrincipalID: identityModule.outputs.containerRegistryManagedIdentityPrincipalId
    diagnosticsStorageAccountId: storageAccountDiagnosticsModule.outputs.diagnosticsStorageAccountId
    eventHubNamespaceAuthorizationRuleId: eventHubDiagnosticsModule.outputs.eventHubNamespaceAuthorizationRuleId
    keyVaultName: keyVaultName
    location: location
    logAnalyticsWorkspaceId: logAnalyticsModule.outputs.logAnalyticsWorkspaceId
    resourcePassword: resourcePassword
  }
}


module azureAutomationModule 'azure_automation.bicep' = {
  scope: resourceGroup(azureAutomationResourceGroupName)
  name: 'azureAutomationDeployment'
  dependsOn: [
    azureAutomationResourceGroup
  ]
  params: {
    azureAutomationName: azureAutomationName
    allocationStartTime: allocationStartTime
    deallocationStartTime: deallocationStartTime
    azureAutomationAppScaleDownRunbookName: azureAutomationAppScaleDownRunbook
    azureAutomationAppScaleDownScheduleName: azureAutomationAppScaleDownSchedule
    appScaleDownLinkScheduleName: appScaleDownLinkSchedule
    azureAutomationAppScaleUpRunbookName:  azureAutomationAppScaleUpRunbook
    azureAutomationAppScaleUpScheduleName: azureAutomationAppScaleUpSchedule
    appScaleUpLinkScheduleName: appScaleUpLinkSchedule
    azureAutomationVmStartRunbookName: azureAutomationVmStartRunbook
    azureAutomationVmAllocationScheduleName: azureAutomationVmAllocationSchedule
    vmAllocationLinkScheduleName: vmAllocationLinkSchedule
    azureAutomationVmStopRunbookName: azureAutomationVmStopRunbook
    azureAutomationVmDeallocationScheduleName: azureAutomationVmDeallocationSchedule
    vmDeallocationLinkScheduleName: vmDeallocationLinkSchedule
    location: location
    
  }

}
//Assign the virtual machine contributor  role to system identity of automation account (AT Subscription scope). 
//Note: Subscription scope is required the user assigned identity doesn't work
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId,virtualMachineContributorId)
  properties: {
    roleDefinitionId: virtualMachineContributorId
    principalId: azureAutomationModule.outputs.AutAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}

//Assign the web plan contributor  role to system identity of automation account (AT Subscription scope). 
//Note: Subscription scope is required the user assigned identity doesn't work
resource roleAssignmentApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().subscriptionId,ContributorId)
  properties: {
    roleDefinitionId: ContributorId
    principalId: azureAutomationModule.outputs.AutAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}



