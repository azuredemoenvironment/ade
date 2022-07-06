// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App Sql Database.')
param adeAppSqlDatabaseName string

@description('The name of the ADE App Sql Server.')
param adeAppSqlServerName string

@description('The name of the ADE App Sql Server Private Endpoint.')
param adeAppSqlServerPrivateEndpointName string

@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The name of the App Config instance.')
param appConfigName string

@description('The name of the App Config instance Resource Group.')
param appConfigResourceGroupName string

@description('The ID of the Azure Sql Private Dns Zone.')
param azureSqlPrivateDnsZoneId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Private Endpoint Subnet.')
param privateEndpointSubnetId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'sql'
  costCenter: 'it'
}

// Resource - Sql Server - ADE App
//////////////////////////////////////////////////
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: adeAppSqlServerName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// Resource - Sql Database - ADE App
//////////////////////////////////////////////////
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: adeAppSqlServer
  name: adeAppSqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 40
  }
  properties: {
    collation: 'Sql_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    zoneRedundant: true
    autoPauseDelay: 60
    minCapacity: 5
  }
}

// Module - App Config - ADE App Sql Database
//////////////////////////////////////////////////
module azureDatabasesAdeAppSqlAppConfigModule './azure_databases_adeapp_sql_app_config.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'azureDatabasesAdeAppSqlAppConfigDeployment'
  params: {
    appConfigName: appConfigName
    sqlServerConnectionString: 'Data Source=tcp:${adeAppSqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adeAppSqlServer.properties.administratorLogin}@${adeAppSqlServer.properties.fullyQualifiedDomainName};Password=${adminPassword};'
  }
}

// Resource - Sql Database - Diagnostic Settings - ADE App
//////////////////////////////////////////////////
resource adeAppSqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppSqlDatabase
  name: '${adeAppSqlDatabase.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'SqlInsights'
        enabled: true
      }
      {
        category: 'AutomaticTuning'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
      }
      {
        category: 'Errors'
        enabled: true
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
      }
      {
        category: 'Timeouts'
        enabled: true
      }
      {
        category: 'Blocks'
        enabled: true
      }
      {
        category: 'Deadlocks'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
  }
}

// Resource - Private Endpoint - ADE App Sql Server
//////////////////////////////////////////////////
resource adeAppSqlServerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: adeAppSqlServerPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppSqlServerPrivateEndpointName
        properties: {
          privateLinkServiceId: adeAppSqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// Resource - Private Endpoint Dns Group - Private Endpoint - ADE App Sql Server
//////////////////////////////////////////////////
resource azureSqlprivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${adeAppSqlServerPrivateEndpoint.name}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: azureSqlPrivateDnsZoneId
        }
      }
    ]
  }
}
