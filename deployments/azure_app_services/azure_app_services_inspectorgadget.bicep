// parameters
param defaultPrimaryRegion string
param adminUserName string
param adminPassword string
param logAnalyticsWorkspaceId string
param applicationInsightsInstrumentationKey string
param inspectorGadgetSqlServerName string
param inspectorGadgetSqlServerFQDN string
param inspectorGadgetSqlDatabaseName string
param inspectorGadgetAppServiceName string
param webAppRepoURL string
param vnetIntegrationSubnetId string
param appServicePlanId string

// variables
var environmentName = 'production'
var functionName = 'sql'
var costCenterName = 'it'

// resource - web app - inspectorGadgetAppService
resource inspectorGadgetAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: inspectorGadgetAppServiceName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false
    siteConfig: {
      appSettings: [
        {
          name: 'PROJECT'
          value: 'WebApp'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
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
          name: 'DefaultSqlConnectionSqlConnectionString'
          value: 'Data Source=tcp:${inspectorGadgetSqlServerFQDN},1433;Initial Catalog=${inspectorGadgetSqlDatabaseName};User Id=${adminUserName}@${inspectorGadgetSqlServerFQDN};Password=${adminPassword};'
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

// resource - web app networking - inspectorGadgetAppService
resource inspectorGadgetAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${inspectorGadgetAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// resource - web app - source controls - inspectorGadgetAppService
resource inspectorGadgetAppServiceSourceControls 'Microsoft.Web/sites/sourcecontrols@2018-02-01' = {
  name: '${inspectorGadgetAppService.name}/web'
  properties: {
    repoUrl: webAppRepoURL
    branch: 'master'
    isManualIntegration: true
  }
}

// resource - web app - inspectorGadgetAppService - diagnostics settings
resource inspectorGadgetAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: inspectorGadgetAppService
  name: '${inspectorGadgetAppService.name}-diagnostics'
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
