// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the admin user.')
param adminUserName string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var adeAppSqlDatabaseName = 'sqldb-${appEnvironment}-adeapp'
var adeAppSqlServerName = 'sql-${appEnvironment}-adeapp'
var adeAppSqlServerPrivateEndpointName = 'pl-${appEnvironment}-adeappsql'
var inspectorGadgetSqlDatabaseName = 'sqldb-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-${appEnvironment}-inspectorgadgetsql'
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'appcs-${appEnvironment}-001'
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'kv-${appEnvironment}-001'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Private Dns Zone
resource azureSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-002'
  resource adeAppSqlSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeAppSql'
  }
  resource inspectorGadgetSqlSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-inspectorGadgetSql'
  }
}

// Module - Sql -  App
//////////////////////////////////////////////////
module adeAppSqlModule 'sql_adeapp.bicep' = {
  name: 'adeAppSqlDeployment'
  params: {
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
    adeAppSqlSubnetId: virtualNetwork002::adeAppSqlSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    azureSqlPrivateDnsZoneId: azureSqlPrivateDnsZone.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Sql - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetSqlModule 'sql_inspectorgadget.bicep' = {
  name: 'inspectorGadgetSqlDeployment'
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
    tags: tags
  }
}

// Module - App Config -  App - Sql Database
//////////////////////////////////////////////////
module adeAppSqlAppConfigModule './sql_adeapp_app_config.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'adeAppSqlAppConfigDeployment'
  params: {
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerAdministratorLogin: adeAppSqlModule.outputs.adeAppSqlServerAdministratorLogin
    adeAppSqlServerFqdn: adeAppSqlModule.outputs.adeAppSqlServerFqdn
    adminPassword: keyVault.getSecret('resourcePassword')
    appConfigName: appConfig.name    
  }
}
