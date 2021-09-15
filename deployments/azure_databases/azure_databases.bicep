// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param appConfigResourceGroupName string
param networkingResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param adminUserName string
param adminPassword string

// service name variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
var azureSQLPrivateDnsZoneName = 'privatelink.database.windows.net'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var adeAppSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-adeappsql'
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-inspectorgadgetsql'

// existing resources

// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// resource - virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource privateEndpointSubnet 'subnets@2020-07-01' existing = {
    name: privateEndpointSubnetName
  }
}

// resource - private dns zone - azure sql
resource azureSQLPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSQLPrivateDnsZoneName
}

// resource - app config
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// module - adeAppSql
module adeAppSqlModule './azure_databases_adeapp_sql.bicep' = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: 'adeAppSqlDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    appConfigResourceGroupName: appConfigResourceGroupName
    appConfigName: appConfig.name
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    azureSQLPrivateDnsZoneId: azureSQLPrivateDnsZone.id
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
  }
}

// module - inspectorGadgetSql
module inspectorGadgetSqlModule './azure_databases_inspectorgadget_sql.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetSqlDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    azureSQLPrivateDnsZoneId: azureSQLPrivateDnsZone.id
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabaseName
    inspectorGadgetSqlServerPrivateEndpointName: inspectorGadgetSqlServerPrivateEndpointName
  }
}
