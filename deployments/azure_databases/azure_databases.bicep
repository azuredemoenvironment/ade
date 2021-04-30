// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables - log analytics
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'

// variables - virtual network - virtual network 002
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var privateEndpointSubnetName = 'snet-privateEndpoint'

// variables - private dns zone - azure sql
var azureSQLPrivateDnsZoneName = 'privatelink.database.windows.net'

// variables - adeAppSql
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var adeAppSqlServerDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var adeAppSqlServerDatabasePrivateEndpointName = 'pl-ade-${aliasRegion}-adeAppSql'

// variables - inspectorGadgetsql
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorGadget'
var inspectorGadgetSqlServerDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorGadget'
var inspectorGadgetSqlServerDatabasePrivateEndpointName = 'pl-ade-${aliasRegion}-inspectorGadgetSql'

// module - resource groups
module resourceGroupsModule './azure_databases_resourcegroups.bicep' = {
  name: 'resourceGroupsDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adeAppSqlResourceGroupName: adeAppSqlResourceGroupName
    inspectorGadgetResourceGroupName: inspectorGadgetResourceGroupName
  }
}

// module - adeAppSql
module adeAppSqlModule './azure_databases_adeapp_sql.bicep' = {
  name: 'adeAppSqlDeployment'
  scope: resourceGroup(adeAppSqlResourceGroupName)
  dependsOn: [
    resourceGroupsModule
  ]
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
    adeAppSqlServerDatabaseName: adeAppSqlServerDatabaseName
    adeAppSqlServerDatabasePrivateEndpointName: adeAppSqlServerDatabasePrivateEndpointName
    azureSQLPrivateDnsZoneName: azureSQLPrivateDnsZoneName
  }
}

// module - inspectorGadgetSql
module inspectorGadgetSqlModule './azure_databases_inspectorgadget_sql.bicep' = {
  name: 'inspectorGadgetSqlDeployment'
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  dependsOn: [
    resourceGroupsModule
  ]
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
    inspectorGadgetSqlServerDatabaseName: inspectorGadgetSqlServerDatabaseName
    inspectorGadgetSqlServerDatabasePrivateEndpointName: adeAppSqlServerDatabasePrivateEndpointName
    azureSQLPrivateDnsZoneName: azureSQLPrivateDnsZoneName
  }
}
