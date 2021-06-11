// parameters
param defaultPrimaryRegion string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param applicationInsightsConnectionString string
param vnetIntegrationSubnetId string
param privateEndpointSubnetId string
param azureContainerRegistryName string
param azureContainerRegistryURL string
param azureContainerRegistryCredentials string
param adeAppSqlServerName string
param adeAppSqlServerFQDN string
param adeAppSqlDatabaseName string
param appServicePlanId string
param azureAppServicePrivateDnsZone string
param adeAppFrontEndAppServiceName string
param adeAppApiGatewayAppServiceName string
param adeAppUserServiceAppServiceName string
param adeAppDataIngestorServiceAppServiceName string
param adeAppDataReporterServiceAppServiceName string
param adeAppFrontEndAppServiceImageName string
param adeAppApiGatewayAppServiceImageName string
param adeAppUserServiceAppServiceImageName string
param adeAppDataIngestorServiceAppServiceImageName string
param adeAppDataReporterServiceAppServiceImageName string

// parameter arrays
param appServiceNames array = [
  adeAppFrontEndAppServiceName
  adeAppApiGatewayAppServiceName
  adeAppUserServiceAppServiceName
  adeAppDataIngestorServiceAppServiceName
  adeAppDataReporterServiceAppServiceName
]
param appServiceImageNames array = [
  adeAppFrontEndAppServiceImageName
  adeAppApiGatewayAppServiceImageName
  adeAppUserServiceAppServiceImageName
  adeAppDataIngestorServiceAppServiceImageName
  adeAppDataReporterServiceAppServiceImageName
]
param appServiceConfigurations array = [
  {
    name: adeAppFrontEndAppServiceName
    image: adeAppFrontEndAppServiceImageName
  }
  {
    name: adeAppApiGatewayAppServiceName
    image: adeAppApiGatewayAppServiceImageName
  }
  {
    name: adeAppUserServiceAppServiceName
    image: adeAppUserServiceAppServiceImageName
  }
  {
    name: adeAppDataIngestorServiceAppServiceName
    image: adeAppDataIngestorServiceAppServiceImageName
  }
  {
    name: adeAppDataReporterServiceAppServiceName
    image: adeAppDataReporterServiceAppServiceImageName
  }
]
param appServiceCustomAppSettings array = [
  {
    appSettings: {
      ADE__APIGATEWAYURI: 'http://${adeAppApiGatewayAppServiceName}.azurewebsites.net'
    }
  }
  {
    appSettings: {
      ADE__USERSERVICEURI: 'http://${adeAppUserServiceAppServiceName}.azurewebsites.net'
      ADE__DATAINGESTORSERVICEURI: 'http://${adeAppDataIngestorServiceAppServiceName}.azurewebsites.net'
      ADE__DATAREPORTERSERVICEURI: 'http://${adeAppDataReporterServiceAppServiceName}.azurewebsites.net'
    }
  }
  {
    appSettings: {
      ADE__SQLSERVERCONNECTIONSTRING: 'Data Source=tcp:${adeAppSqlServerFQDN},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adminUserName}@${adeAppSqlServerFQDN};Password=${adminPassword};'
    }
  }
  {
    appSettings: {
      ADE__SQLSERVERCONNECTIONSTRING: 'Data Source=tcp:${adeAppSqlServerFQDN},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adminUserName}@${adeAppSqlServerFQDN};Password=${adminPassword};'
    }
  }
  {
    appSettings: {
      ADE__SQLSERVERCONNECTIONSTRING: 'Data Source=tcp:${adeAppSqlServerFQDN},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adminUserName}@${adeAppSqlServerFQDN};Password=${adminPassword};'
    }
  }
]

// variables
var defaultAppSettings = [
  {
    name: 'APPINSIGHTS_CONNECTIONSTRING'
    value: applicationInsightsConnectionString
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
var unionAppSettings = union(appServiceCustomAppSettings, defaultAppSettings)
var environmentName = 'production'
var functionName = 'appApp'
var costCenterName = 'it'

// resource - app service
resource appService 'Microsoft.Web/sites@2020-12-01' = [for appServiceConfiguration in appServiceConfigurations: {
  name: appServiceConfiguration.name
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${azureContainerRegistryURL}/${appServiceConfiguration.image}'
      appSettings: [
        {
          name: 'APPINSIGHTS_CONNECTIONSTRING'
          value: applicationInsightsConnectionString
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
}]

// resource - app service - app settings
resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-12-01' = [for (appServiceConfiguration, i) in appServiceConfigurations: {
  name: '${appService[i].name}/appSettings'
  properties: appServiceConfiguration.appSettings
}]

// resource - app service - networking
resource appServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = [for (appServiceConfiguration, i) in appServiceConfigurations: {
  name: '${appService[i].name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}]

// resource - app service - diagnostics settings
resource appServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = [for (appServiceConfiguration, i) in appServiceConfigurations: {
  scope: appService[i]
  name: '${appServiceConfiguration.name}-diagnostics'
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

// outputs
output adeAppServiceUris array = [for appServiceName in appServiceNames: {
  name: '${appServiceName.name}Uri'
  resourceId: '${list(resourceId('Microsoft.Web/sites/config', appServiceName.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'
}]

output adeAppFrontEndAppServiceUri string = '${list(resourceId('Microsoft.Web/sites/config', adeAppFrontEndAppService.name, 'publishingcredentials'), '2019-08-01').properties.scmUri}/docker/hook'

recomendation from Alex Frankel
output url string = '${list(resourceId('Microsoft.Web/sites/config', webappName, 'publishingcredentials'), app.apiVersion).properties.scmUri}/docker/hook'
