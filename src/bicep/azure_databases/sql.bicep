// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The properties of the Sql Server and Sql Database.')
param sqlProperties object

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of Resource tags')
param tags object

// Resource - Sql Server
//////////////////////////////////////////////////
resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlProperties.sqlServerName
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: sqlProperties.publicNetworkAccess
    administratorLogin: adminUserName
    administratorLoginPassword: adminPassword
    version: sqlProperties.version
  }
}

// Resource - Sql Database
//////////////////////////////////////////////////
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent: sqlServer
  name: sqlProperties.sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: sqlProperties.skuName
    tier: sqlProperties.skuTier
    family: sqlProperties.skuFamily
    capacity: sqlProperties.skuCapacity
  }
}

// Resource - Sql Database - Diagnostic Settings
//////////////////////////////////////////////////
resource sqlDatabaseDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: sqlDatabase
  name: '${sqlDatabase.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Resource - Private Endpoint
//////////////////////////////////////////////////
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: sqlProperties.privateEndpointName
  location: location
  properties: {
    customNetworkInterfaceName: sqlProperties.privateEndpointNicName
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: sqlProperties.privateIPAddress
        }
      }
    ]
    subnet: {
      id: sqlProperties.privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: sqlProperties.privateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// Resource - Private Endpoint Dns Group - Private Endpoint
//////////////////////////////////////////////////
resource privateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlProperties.privateDnsZoneId
        }
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output sqlServerAdministratorLogin string = sqlServer.properties.administratorLogin
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
