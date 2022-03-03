// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the ADE App App Services.')
param adeAppAppServices array

@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('The ID of the App Service Plan.')
param appServicePlanId string

@description('The ID of the Azure App Service Private DNS Zone.')
param azureAppServicePrivateDnsZoneId string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Private Endpoint Subnet.')
param privateEndpointSubnetId string

@description('The ID of the Virtual Network Integration Subnet.')
param vnetIntegrationSubnetId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'adeApp'
  costCenter: 'it'
}

// Resource - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppService 'Microsoft.Web/sites@2020-12-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: adeAppAppService.adeAppAppServiceName
  location: location
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryURL}/${adeAppAppService.containerImageName}'
      alwaysOn: true
      http20Enabled: true
      httpLoggingEnabled: true
      appSettings: [
        {
          name: 'CONNECTIONSTRINGS__APPCONFIG'
          value: appConfigConnectionString
        }
        {
          name: 'ADE__ENVIRONMENT'
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
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}]

// Resource - App Service - Networking - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: '${adeAppService[i].name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}]

// Resource - App Service - Diagnostic Settings - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (adeAppAppService, i) in adeAppAppServices: {
  scope: adeAppService[i]
  name: '${adeAppAppService.adeAppAppServiceName}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceFileAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServicePlatformLogs'
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
}]

// Resource - Private Endpoint - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = [for (adeAppAppService, i) in adeAppAppServices: if (adeAppAppService.usePrivateEndpoint) {
  name: adeAppAppService.privateEndpointName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppAppService.privateEndpointName
        properties: {
          privateLinkServiceId: adeAppService[i].id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}]

// Resource - Prviate Endpoint Dns Group - Private Endpoint - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = [for (adeAppAppService, i) in adeAppAppServices: if (adeAppAppService.usePrivateEndpoint) {
  name: '${adeAppAppService.privateEndpointName}/dnsgroupname'
  dependsOn: [
    adeAppServicePrivateEndpoint
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: azureAppServicePrivateDnsZoneId
        }
      }
    ]
  }
}]

// Outputs
//////////////////////////////////////////////////
output adeAppDockerWebHookUris array = [for (adeAppAppService, i) in adeAppAppServices: {
  adeAppDockerWebHookUri: '${list(resourceId('Microsoft.Web/sites/config', adeAppAppService.adeAppAppServiceName, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
}]
