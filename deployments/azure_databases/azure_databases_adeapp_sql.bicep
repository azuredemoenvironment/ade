// parameters
param azureRegion string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param appConfigResourceGroupName string
param appConfigName string
param privateEndpointSubnetId string
param azureSQLPrivateDnsZoneId string
param adeAppSqlServerName string
param adeAppSqlDatabaseName string
param adeAppSqlServerPrivateEndpointName string

// variables
var environmentName = 'production'
var functionName = 'sql'
var costCenterName = 'it'

// resource - sql server - adeAppSqlServer
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: adeAppSqlServerName
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

// resource - sql database - adeAppSqlDatabase
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: adeAppSqlServer
  name: adeAppSqlDatabaseName
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

// module - app config - sql database
module azureDatabasesAdeAppSqlAppConfigModule './azure_databases_adeapp_sql_app_config.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'azureDatabasesAdeAppSqlAppConfigDeployment'
  params: {
    appConfigName: appConfigName
    sqlServerConnectionString: 'Data Source=tcp:${adeAppSqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adeAppSqlServer.properties.administratorLogin}@${adeAppSqlServer.properties.fullyQualifiedDomainName};Password=${adminPassword};'
  }
}

// resource - sql database - diagnostic settings - adeAppSqlServerDatabase
resource adeAppSqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppSqlDatabase
  name: '${adeAppSqlDatabase.name}-diagnostics'
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

// resource - private endpoint - adeAppSqlServer
resource adeAppSqlServerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: adeAppSqlServerPrivateEndpointName
  location: azureRegion
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

// resource - private endpoint dns group - private endpoint - sql server - adeAppSqlServer
resource azureSQLprivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${adeAppSqlServerPrivateEndpoint.name}/dnsgroupname'
  dependsOn: [
    adeAppSqlServerPrivateEndpoint
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
