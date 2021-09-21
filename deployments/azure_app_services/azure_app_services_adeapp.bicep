// parameters
param defaultPrimaryRegion string
param aliasRegion string
param logAnalyticsWorkspaceId string
param appConfigConnectionString string
param vnetIntegrationSubnetId string
param privateEndpointSubnetId string
param azureContainerRegistryName string
param azureContainerRegistryURL string
param azureContainerRegistryCredentials string
param azureAppServicePrivateDnsZoneId string
param appServicePlanId string
param adeAppName string
param usePrivateEndpoint bool

// variables
var tags = {
  environment: 'production'
  function: 'App'
  costCenter: 'it'
}

var adeAppServiceName = replace('app-ade-${aliasRegion}-ade-${adeAppName}', '-', '')
var adeAppContainerImageName = 'ade-${adeAppName}'
var adeAppPrivateEndpointName = 'pl-ade-${aliasRegion}-ade-${adeAppName}'

// resource - app service
resource adeAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppContainerImageName}'
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
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_BaseExtensions'
          value: '~1'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${azureContainerRegistryURL}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: azureContainerRegistryName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: azureContainerRegistryCredentials
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
}

// resource - app service networking
resource adeAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings
resource adeAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppService
  name: '${adeAppService.name}-diagnostics'
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
}

// resource - private endpoint - app service
resource adeAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = if (usePrivateEndpoint) {
  name: adeAppPrivateEndpointName
  location: defaultPrimaryRegion
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppPrivateEndpointName
        properties: {
          privateLinkServiceId: adeAppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// resource - prviate endpoint dns group - private endpoint - app service
resource adeAppServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = if (usePrivateEndpoint) {
  name: '${adeAppServicePrivateEndpoint.name}/dnsgroupname'
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
}

// outputs
output adeAppServiceName string = adeAppService.name
output adeAppContainerImageName string = adeAppContainerImageName
output adeAppPrivateEndpointName string = adeAppServicePrivateEndpoint.name
output adeAppDockerWebHookUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
