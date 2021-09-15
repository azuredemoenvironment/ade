// parameters
param defaultPrimaryRegion string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param appConfigConnectionString string
param vnetIntegrationSubnetId string
param privateEndpointSubnetId string
param azureContainerRegistryName string
param azureContainerRegistryURL string
param azureContainerRegistryCredentials string
param adeAppSqlServerFQDN string
param adeAppSqlDatabaseName string
param azureAppServicePrivateDnsZoneId string
param appServicePlanId string
param adeAppFrontEndAppServiceName string
param adeAppApiGatewayAppServiceName string
param adeAppUserServiceAppServiceName string
param adeAppDataIngestorServiceAppServiceName string
param adeAppDataReporterServiceAppServiceName string
param adeAppApiGatewayAppServiceHostName string
param adeAppFrontEndAppServiceImageName string
param adeAppApiGatewayAppServiceImageName string
param adeAppUserServiceAppServiceImageName string
param adeAppUserServiceAppServicePrivateEndpointName string
param adeAppDataIngestorServiceAppServicePrivateEndpointName string
param adeAppDataReporterServiceAppServicePrivateEndpointName string
param adeAppDataIngestorServiceAppServiceImageName string
param adeAppDataReporterServiceAppServiceImageName string

// variables
var tags = {
  environment: 'production'
  function: 'appApp'
  costCenter: 'it'
}

// resource - app service - adeAppFrontendAppService
resource adeAppFrontEndAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppFrontEndAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppFrontEndAppServiceImageName}'
      appSettings: [
        {
          name: 'AppConfig'
          value: appConfigConnectionString
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

// resource - app service networking - adeAppFrontendAppService
resource adeAppFrontendAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppFrontEndAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings - adeAppFrontendAppService
resource adeAppFrontendAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppFrontEndAppService
  name: '${adeAppFrontEndAppService.name}-diagnostics'
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

// resource - app service - adeAppApiGatewayAppService
resource adeAppApiGatewayAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppApiGatewayAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppApiGatewayAppServiceImageName}'
      appSettings: [
        {
          name: 'AppConfig'
          value: appConfigConnectionString
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

// resource - app service networking - adeAppApiGatewayAppService
resource adeAppApiGatewayAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppApiGatewayAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings - adeAppApiGatewayAppService
resource adeAppApiGatewayAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppApiGatewayAppService
  name: '${adeAppApiGatewayAppService.name}-diagnostics'
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

// resource - app service - adeAppUserServiceAppService
resource adeAppUserServiceAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppUserServiceAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppUserServiceAppServiceImageName}'
      appSettings: [
        {
          name: 'AppConfig'
          value: appConfigConnectionString
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

// resource - app service networking - adeAppUserServiceAppService
resource adeAppUserServiceAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppUserServiceAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings - adeAppUserServiceAppService
resource adeAppUserServiceAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppUserServiceAppService
  name: '${adeAppUserServiceAppService.name}-diagnostics'
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

// resource - private endpoint - app service - adeAppUserServiceAppService
resource adeAppUserServiceAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: adeAppUserServiceAppServicePrivateEndpointName
  location: defaultPrimaryRegion
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppUserServiceAppServicePrivateEndpointName
        properties: {
          privateLinkServiceId: adeAppUserServiceAppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// resource - prviate endpoint dns group - private endpoint - app service - adeAppUserServiceAppService
resource adeAppUserServiceAppServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${adeAppUserServiceAppServicePrivateEndpoint.name}/dnsgroupname'
  dependsOn: [
    adeAppUserServiceAppServicePrivateEndpoint
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

// resource - app service - adeAppDataIngestorServiceAppService
resource adeAppDataIngestorServiceAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppDataIngestorServiceAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppDataIngestorServiceAppServiceImageName}'
      appSettings: [
        {
          name: 'AppConfig'
          value: appConfigConnectionString
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

// resource - app service networking - adeAppDataIngestorServiceAppService
resource adeAppDataIngestorServiceAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppDataIngestorServiceAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings - adeAppDataIngestorServiceAppService
resource adeAppDataIngestorServiceAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppDataIngestorServiceAppService
  name: '${adeAppDataIngestorServiceAppService.name}-diagnostics'
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

// resource - private endpoint - app service - adeAppDataIngestorServiceAppService
resource adeAppDataIngestorServiceAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: adeAppDataIngestorServiceAppServicePrivateEndpointName
  location: defaultPrimaryRegion
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppDataIngestorServiceAppServicePrivateEndpointName
        properties: {
          privateLinkServiceId: adeAppDataIngestorServiceAppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// resource - prviate endpoint dns group - private endpoint - app service - adeAppDataIngestorServiceAppService
resource adeAppDataIngestorServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${adeAppDataIngestorServiceAppServicePrivateEndpoint.name}/dnsgroupname'
  dependsOn: [
    adeAppDataIngestorServiceAppServicePrivateEndpoint
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

// resource - app service - adeAppDataReporterServiceAppService
resource adeAppDataReporterServiceAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: adeAppDataReporterServiceAppServiceName
  location: defaultPrimaryRegion
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${adeAppDataReporterServiceAppServiceImageName}'
      appSettings: [
        {
          name: 'AppConfig'
          value: appConfigConnectionString
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

// resource - app service networking - adeAppDataReporterServiceAppService
resource adeAppDataReporterServiceAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${adeAppDataReporterServiceAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - app service - diagnostics settings - adeAppDataReporterServiceAppService
resource adeAppDataReporterServiceAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: adeAppDataReporterServiceAppService
  name: '${adeAppDataReporterServiceAppService.name}-diagnostics'
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

// resource - private endpoint - app service - adeAppDataReporterServiceAppService
resource adeAppDataReporterServiceAppServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: adeAppDataReporterServiceAppServicePrivateEndpointName
  location: defaultPrimaryRegion
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: adeAppDataReporterServiceAppServicePrivateEndpointName
        properties: {
          privateLinkServiceId: adeAppDataReporterServiceAppService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// resource - prviate endpoint dns group - private endpoint - app service - adeAppDataReporterServiceAppService
resource adeAppDataReporterServicePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: '${adeAppDataReporterServiceAppServicePrivateEndpoint.name}/dnsgroupname'
  dependsOn: [
    adeAppDataReporterServiceAppServicePrivateEndpoint
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
output adeAppFrontEndAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppFrontEndAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
output adeAppApiGatewayAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppApiGatewayAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
output adeAppUserServiceAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppUserServiceAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
output adeAppDataIngestorServiceAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppDataIngestorServiceAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
output adeAppDataReporterServiceAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppDataReporterServiceAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
