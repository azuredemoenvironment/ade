// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param monitorResourceGroupName string
param networkingResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// variables
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
// resource - virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource privateEndpointSubnet 'subnets@2020-07-01' existing = {
    name: privateEndpointSubnetName
  }
}
// variables
var azureSQLPrivateDnsZoneName = 'privatelink.database.windows.net'
// resource - private dns zone - azure sql
resource azureSQLPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSQLPrivateDnsZoneName
}

// module - adeAppSql
// variables
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var adeAppSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-adeappsql'
// module deployment
module adeAppSqlModule './azure_databases_adeapp_sql.bicep' = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: 'adeAppSqlDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    azureSQLPrivateDnsZoneId: azureSQLPrivateDnsZone.id
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
  }
}

// module - inspectorGadgetSql
// variables
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerPrivateEndpointName = 'pl-ade-${aliasRegion}-inspectorgadgetsql'
// module deployment
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
