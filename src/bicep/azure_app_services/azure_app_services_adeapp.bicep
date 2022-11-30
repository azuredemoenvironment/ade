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

// Resource - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppService 'Microsoft.Web/sites@2022-03-01' = [for (adeAppAppService, i) in adeAppAppServices: {
  name: adeAppAppService.adeAppAppServiceName
  location: location
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    virtualNetworkSubnetId: vnetIntegrationSubnetId
    vnetRouteAllEnabled: true
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
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}]

// Resource - App Service - Diagnostic Settings - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (adeAppAppService, i) in adeAppAppServices: {
  scope: adeAppService[i]
  name: '${adeAppAppService.adeAppAppServiceName}-diagnostics'
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
        category: 'AppServiceFileAuditLogs'
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

// Resource - Private Endpoint - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = [for (adeAppAppService, i) in adeAppAppServices: if (adeAppAppService.usePrivateEndpoint) {
  name: adeAppAppService.privateEndpointName
  location: location
  properties: {
    subnet: {
      id: adeAppAppService.subnetId
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

// Resource - Private Endpoint Dns Group - Private Endpoint - App Service - ADE App(s)
//////////////////////////////////////////////////
resource adeAppServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = [for (adeAppAppService, i) in adeAppAppServices: if (adeAppAppService.usePrivateEndpoint) {
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
output adeAppDockerWebHookUris array = [for adeAppAppService in adeAppAppServices: {
  // Should not return secrets, but we need it in this case
  adeAppDockerWebHookUri: '/docker/hook'
}]
