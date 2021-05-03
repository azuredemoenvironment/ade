// parameters
param defaultPrimaryRegion string
param adminUserName string
param adminPassword string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork002Name string
param privateEndpointSubnetName string
param adeAppSqlServerName string
param adeAppSqlDatabaseName string
param adeAppSqlServerPrivateEndpointName string
param azureSQLPrivateDnsZoneName string

// variables
var environmentName = 'production'
var functionName = 'sql'
var costCenterName = 'it'

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
// private dns zone - azure sql
resource azureSQLPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureSQLPrivateDnsZoneName
}

// resource - sql server - adeAppSqlServer
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: adeAppSqlServerName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
  resource sqlServerFirewallRules 'firewallRules' = {
    name: 'AllowWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

// resource - sql database - adeAppSqlDatabase
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: adeAppSqlServer
  name: adeAppSqlDatabaseName
  location: defaultPrimaryRegion
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

// resource - sql database - diagnostic settings - adeAppSqlServerDatabase
resource adeAppSqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppSqlDatabase
  name: '${adeAppSqlDatabase.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
  location: defaultPrimaryRegion
  properties: {
    subnet: {
      id: virtualNetwork002::privateEndpointSubnet.id
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

// resource - prviate endpoint dns group - private endpoint - sql server - adeAppSqlServer
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
          privateDnsZoneId: azureSQLPrivateDnsZone.id
        }
      }
    ]
  }
}
