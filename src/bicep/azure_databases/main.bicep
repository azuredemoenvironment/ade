// Parameters
//////////////////////////////////////////////////
@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the admin user.')
param adminUserName string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

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
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - Sql App
//////////////////////////////////////////////////
var adeAppSqlDatabaseName = 'sqldb-${appEnvironment}-adeapp'
var adeAppSqlServerName = 'sql-${appEnvironment}-adeapp'
var adeAppSqlServerPrivateEndpointName = 'pl-${appEnvironment}-adeappsql'
var adeAppSqlServerPrivateEndpointNicName = 'nic-${appEnvironment}-adeAppSql'
var adeAppSqlProperties = {
  sqlDatabaseName: adeAppSqlDatabaseName
  sqlServerName: adeAppSqlServerName  
  publicNetworkAccess: 'Disabled'
  version: '12.0'
  skuName: 'GP_S_Gen5'
  skuTier: 'GeneralPurpose'
  skuFamily: 'Gen5'
  skuCapacity: 40
  privateEndpointName: adeAppSqlServerPrivateEndpointName
  privateEndpointNicName: adeAppSqlServerPrivateEndpointNicName
  privateEndpointPrivateIpAddress: '10.102.160.4'
  privateEndpointSubnetId: spokeVirtualNetwork::adeAppSqlSubnet.id
  privateDnsZoneId: azureSqlPrivateDnsZone.id
}

// Variables - Inspector Gadget
//////////////////////////////////////////////////
var inspectorGadgetSqlDatabaseName = 'sqldb-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-${appEnvironment}-inspectorgadgetsql'
var inspectorGadgetSqlServerPrivateEndpointNicName = 'nic-${appEnvironment}-inspectorgadgetsql'
var inspectorGadgetSqlProperties = {
  sqlDatabaseName: inspectorGadgetSqlDatabaseName
  sqlServerName: inspectorGadgetSqlServerName
  publicNetworkAccess: 'Disabled'
  version: '12.0'
  skuName: 'GP_S_Gen5'
  skuTier: 'GeneralPurpose'
  skuFamily: 'Gen5'
  skuCapacity: 40
  privateEndpointName: inspectorGadgetSqlServerPrivateEndpointName
  privateEndpointNicName: inspectorGadgetSqlServerPrivateEndpointNicName
  privateEndpointPrivateIpAddress: '10.102.161.4'
  privateEndpointSubnetId: spokeVirtualNetwork::inspectorGadgetSqlSubnet.id
  privateDnsZoneId: azureSqlPrivateDnsZone.id
}

// Variables - Existing Resources
//////////////////////////////////////////////////
var adeAppSqlSubnetName = 'snet-${appEnvironment}-adeAppSql'
var appConfigName = 'appcs-${appEnvironment}'
var azureSqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var inspectorGadgetSqlSubnetName = 'snet-${appEnvironment}-inspectorGadgetSql'
var keyVaultName = 'kv-${appEnvironment}'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')

// Existing Resource - App Configuration
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: appConfigName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Private Dns Zone
resource azureSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSqlPrivateDnsZoneName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Existing Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: spokeVirtualNetworkName
  resource adeAppSqlSubnet 'subnets@2022-09-01' existing = {
    name: adeAppSqlSubnetName
  }
  resource inspectorGadgetSqlSubnet 'subnets@2022-09-01' existing = {
    name: inspectorGadgetSqlSubnetName
  }
}

// Module - Sql - App
//////////////////////////////////////////////////
module adeAppSqlModule 'sql.bicep' = {
  name: 'adeAppSqlDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    sqlProperties: adeAppSqlProperties
    storageAccountId: storageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Sql - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetSqlModule 'sql.bicep' = {
  name: 'inspectorGadgetSqlDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    sqlProperties: inspectorGadgetSqlProperties
    storageAccountId: storageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location    
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - App Configuration - Ade App - Sql Database
//////////////////////////////////////////////////
module adeAppSqlAppConfigurationKeys './sql_app_config.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'adeAppSqlDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    appConfigName: appConfig.name    
    sqlDatabaseName: adeAppSqlDatabaseName
    sqlServerAdministratorLogin: adeAppSqlModule.outputs.sqlServerAdministratorLogin
    sqlServerFqdn: adeAppSqlModule.outputs.sqlServerFqdn
  }
}

// Module - App Configuration - Inspector Gadget - Sql Database
//////////////////////////////////////////////////
module inspectorGadgetSqlAppConfigurationKeys './sql_app_config.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'inspectorGadgetSqlDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    appConfigName: appConfig.name    
    sqlDatabaseName: inspectorGadgetSqlDatabaseName
    sqlServerAdministratorLogin: inspectorGadgetSqlModule.outputs.sqlServerAdministratorLogin
    sqlServerFqdn: inspectorGadgetSqlModule.outputs.sqlServerFqdn
  }
}
