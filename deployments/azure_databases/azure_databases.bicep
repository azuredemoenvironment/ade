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
// variables - log analytics workspace
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// variables - virtual network - virtual network 002
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var privateEndpointSubnetName = 'snet-privateEndpoint'
// variables - private dns zone - azure sql
var azureSQLPrivateDnsZoneName = 'privatelink.database.windows.net'

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
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    privateEndpointSubnetName: privateEndpointSubnetName
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlDatabaseName: adeAppSqlDatabaseName
    adeAppSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
    azureSQLPrivateDnsZoneName: azureSQLPrivateDnsZoneName
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
    monitorResourceGroupName: monitorResourceGroupName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    networkingResourceGroupName: networkingResourceGroupName
    virtualNetwork002Name: virtualNetwork002Name
    privateEndpointSubnetName: privateEndpointSubnetName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabaseName
    inspectorGadgetSqlServerPrivateEndpointName: adeAppSqlServerPrivateEndpointName
    azureSQLPrivateDnsZoneName: azureSQLPrivateDnsZoneName
  }
}
