// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The location for all resources.')
param location string = deployment().location

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppSqlResourceGroupName = 'rg-ade-${aliasRegion}-adeappdb'
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfig'
var inspectorGadgetResourceGroupName = 'rg-ade-${aliasRegion}-inspectorgadget'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var adeAppSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-adeappsql'
var adeAppSqlSubnetName = 'snet-ade-${aliasRegion}-adeAppSql'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var eventHubNamespaceAuthorizationRuleName = 'evh-ade-${aliasRegion}-diagnostics/RootManageSharedAccessKey'
var diagnosticsStorageAccountName = replace('sa-ade-${aliasRegion}-diags', '-', '')
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-inspectorgadgetsql'
var inspectorGadgetSqlSubnetName = 'snet-ade-${aliasRegion}-inspectorGadgetSql'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: diagnosticsStorageAccountName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: eventHubNamespaceAuthorizationRuleName
}

// Existing Resource - Private Dns Zone - Azure Sql
resource azureSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSqlPrivateDnsZoneName
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource adeAppSqlSubnet 'subnets@2020-07-01' existing = {
    name: adeAppSqlSubnetName
  }
  resource inspectorGadgetSqlSubnet 'subnets@2020-07-01' existing = {
    name: inspectorGadgetSqlSubnetName
  }
}

// Resource Group - ADE App Sql
//////////////////////////////////////////////////
resource adeAppSqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppSqlResourceGroupName
  location: azureRegion
}

// Resource Group - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: inspectorGadgetResourceGroupName
  location: azureRegion
}

// Module - ADE App Sql
//////////////////////////////////////////////////
module adeAppSqlModule './azure_databases_adeapp_sql.bicep' = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: 'adeAppSqlDeployment'
  dependsOn: [
    adeAppSqlResourceGroup
  ]
  params: {
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
    adeAppSqlSubnetId: virtualNetwork002::adeAppSqlSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appConfigName: appConfig.name
    appConfigResourceGroupName: appConfigResourceGroupName
    azureSqlPrivateDnsZoneId: azureSqlPrivateDnsZone.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Inspector Gadget Sql
//////////////////////////////////////////////////
module inspectorGadgetSqlModule './azure_databases_inspectorgadget_sql.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetSqlDeployment'
  dependsOn: [
    inspectorGadgetResourceGroup
  ]
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    azureSqlPrivateDnsZoneId: azureSqlPrivateDnsZone.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabaseName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlServerPrivateEndpointName: inspectorGadgetSqlServerPrivateEndpointName
    inspectorGadgetSqlSubnetId: virtualNetwork002::inspectorGadgetSqlSubnet.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id    
  }
}
