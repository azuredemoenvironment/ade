// parameters
param azureRegion string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param privateEndpointSubnetId string
param azureSQLPrivateDnsZoneId string
param inspectorGadgetSqlServerName string
param inspectorGadgetSqlDatabaseName string
param inspectorGadgetSqlServerPrivateEndpointName string

// variables
var environmentName = 'production'
var functionName = 'sql'
var costCenterName = 'it'

// resource - sql server - inspectorGadgetSqlServer
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: inspectorGadgetSqlServerName
  location: azureRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// resource - sql database - inspectorGadgetSqlDatabase
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: inspectorGadgetSqlServer
  name: inspectorGadgetSqlDatabaseName
  location: azureRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 40
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    zoneRedundant: true
    autoPauseDelay: 60
    minCapacity: 5
  }
}

// resource - sql database - diagnostic settings - inspectorGadgetSqlDatabase
resource inspectorGadgetSqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: inspectorGadgetSqlDatabase
  name: '${inspectorGadgetSqlDatabase.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AutomaticTuning'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Deadlocks'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'WorkloadManagement'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - private endpoint - sql server - inspectorGadgetSqlServer
resource inspectorGadgetSqlServerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: inspectorGadgetSqlServerPrivateEndpointName
  location: azureRegion
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

// resource - prviate endpoint dns group - private endpoint - sql server - inspectorGadgetSqlServer
resource azureSQLprivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${inspectorGadgetSqlServerPrivateEndpoint.name}/dnsgroupname'
  dependsOn: [
    inspectorGadgetSqlServerPrivateEndpoint
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: azureSQLPrivateDnsZoneId
        }
      }
    ]
  }
}
