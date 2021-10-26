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
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-inspectorgadgetsql'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
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
  resource privateEndpointSubnet 'subnets@2020-07-01' existing = {
    name: privateEndpointSubnetName
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
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appConfigName: appConfig.name
    appConfigResourceGroupName: appConfigResourceGroupName
    azureSqlPrivateDnsZoneId: azureSqlPrivateDnsZone.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
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
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabaseName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlServerPrivateEndpointName: inspectorGadgetSqlServerPrivateEndpointName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
  }
}
