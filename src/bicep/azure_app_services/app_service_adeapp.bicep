// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the App Services.')
param appServices array

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - App Service
//////////////////////////////////////////////////
resource app 'Microsoft.Web/sites@2022-09-01' = [for (appService, i) in appServices: {
  name: appService.name
  location: location
  tags: tags
  kind: appService.kind
  properties: {
    httpsOnly: appService.httpsOnly
    serverFarmId: appService.serverFarmId
    virtualNetworkSubnetId: appService.virtualNetworkSubnetId
    vnetRouteAllEnabled: appService.vnetRouteAllEnabled
    siteConfig: {
      linuxFxVersion: appService.linuxFxVersion
      appSettings: [
        {
          name: 'CONNECTIONSTRINGS__APPCONFIG'
          value: appService.appConfigConnectionString
        }
        {
          name: 'Ade__ENVIRONMENT'
          value: 'appservices'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${appService.containerRegistryUrl}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: appService.containerRegistryName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: appService.containerRegistryPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}]

// Resource - App Service - Diagnostic Settings
//////////////////////////////////////////////////
resource appDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (appService, i) in appServices: {
  scope: app[i]
  name: '${appService.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}]

// Resource - Private Endpoint - App Service
//////////////////////////////////////////////////
resource appPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [for (appService, i) in appServices: if (appService.usePrivateEndpoint) {
  name: appService.privateEndpointName
  location: location
  properties: {
    customNetworkInterfaceName: appService.privateEndpointNicName
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          groupId: 'sites'
          memberName: 'sites'
          privateIPAddress: appService.privateEndpointPrivateIpAddress
        }
      }
    ]
    subnet: {
      id: appService.subnetId
    }
    privateLinkServiceConnections: [
      {
        name: appService.privateEndpointName
        properties: {
          privateLinkServiceId: app[i].id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}]

// Resource - Private Endpoint Dns Group - Private Endpoint - App Service
//////////////////////////////////////////////////
resource appPrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [for (appService, i) in appServices: if (appService.usePrivateEndpoint) {
  name: '${appService.privateEndpointName}/dnsgroupname'
  dependsOn: [
    appPrivateEndpoint
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: appService.privateDnsZoneId
        }
      }
    ]
  }
}]

// Outputs
//////////////////////////////////////////////////
output appDockerWebHookUris array = [for (appService, i) in appServices: {
  // Should not return secrets, but we need it in this case
  adeAppDockerWebHookUri: '${list(resourceId('Microsoft.Web/sites/config', appService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
}]
