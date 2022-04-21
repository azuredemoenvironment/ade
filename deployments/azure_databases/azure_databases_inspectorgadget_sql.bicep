// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Azure Sql Private Dns Zone.')
param azureSqlPrivateDnsZoneId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Inspector Gadget Sql Database.')
param inspectorGadgetSqlDatabaseName string

@description('The name of the Inspector Gadget Sql Server.')
param inspectorGadgetSqlServerName string

@description('The name of the Inspector Gadget Sql Server Private Endpoint.')
param inspectorGadgetSqlServerPrivateEndpointName string

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

// Resource - Sql Server - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: inspectorGadgetSqlServerName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Disabled'
    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// Resource - Sql Database - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: inspectorGadgetSqlServer
  name: inspectorGadgetSqlDatabaseName
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

// Resource - Sql Database - Diagnostic Settings - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: inspectorGadgetSqlDatabase
  name: '${inspectorGadgetSqlDatabase.name}-diagnostics'
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

// Resource - Private Endpoint - Sql Server - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: inspectorGadgetSqlServerPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: inspectorGadgetSqlServerPrivateEndpointName
        properties: {
          privateLinkServiceId: inspectorGadgetSqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// Resource - Prviate Endpoint Dns Group - Private Endpoint - Inspector Gadget Sql Server
//////////////////////////////////////////////////
resource azureSqlprivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${inspectorGadgetSqlServerPrivateEndpoint.name}/dnsgroupname'
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
