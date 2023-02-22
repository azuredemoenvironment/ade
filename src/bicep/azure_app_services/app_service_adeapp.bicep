// Parameters
//////////////////////////////////////////////////
@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('The ID of the App Service Plan.')
param appServicePlanId string

@description('The array of properties for the Ade App App Services.')
param appServices array

@description('The ID of the Azure App Service Private DNS Zone.')
param appServicePrivateDnsZoneId string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
@secure()
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Virtual Network Integration Subnet.')
param vnetIntegrationSubnetId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'adeApp'
  costCenter: 'it'
}

// Resource - App Service - Ade App
//////////////////////////////////////////////////
resource app 'Microsoft.Web/sites@2022-03-01' = [for (appService, i) in appServices: {
  name: appService.name
  location: location
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    virtualNetworkSubnetId: vnetIntegrationSubnetId
    vnetRouteAllEnabled: true
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryURL}/${appService.containerImageName}'
      alwaysOn: true
      http20Enabled: true
      httpLoggingEnabled: true
      appSettings: [
        {
          name: 'CONNECTIONSTRINGS__APPCONFIG'
          value: appConfigConnectionString
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
          value: 'https://${containerRegistryURL}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistryName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistryPassword
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

// Resource - App Service - Diagnostic Settings - Ade App(s)
//////////////////////////////////////////////////
resource appDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (appService, i) in appServices: {
  scope: app[i]
  name: '${appService.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: diagnosticsStorageAccountId
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

// Resource - Private Endpoint - App Service - Ade App(s)
//////////////////////////////////////////////////
resource appPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = [for (appService, i) in appServices: if (appService.usePrivateEndpoint) {
  name: appService.privateEndpointName
  location: location
  properties: {
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

// Resource - Private Endpoint Dns Group - Private Endpoint - App Service - Ade App(s)
//////////////////////////////////////////////////
resource appPrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = [for (appService, i) in appServices: if (appService.usePrivateEndpoint) {
  name: '${appService.privateEndpointName}/dnsgroupname'
  dependsOn: [
    appPrivateEndpoint
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: appServicePrivateDnsZoneId
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
