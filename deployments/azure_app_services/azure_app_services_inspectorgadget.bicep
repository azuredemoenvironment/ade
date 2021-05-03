// parameters
param defaultPrimaryRegion string
param adminUserName string
param adminPassword string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param applicationInsightsName string
param networkingResourceGroupName string
param virtualNetwork002Name string
param vnetIntegrationSubnetName string
param inspectorGadgetResourceGroupName string
param inspectorGadgetSqlServerName string
param inspectorGadgetSqlDatabaseName string
param inspectorGadgetAppServiceName string
param appServicePlanId string

// variables
var webAppRepoURL = 'https://github.com/jelledruyts/InspectorGadget/'
var environmentName = 'production'
var functionName = 'sql'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// application insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: applicationInsightsName
}
// virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource vnetIntegrationSubnet 'subnets@2020-07-01' existing = {
    name: vnetIntegrationSubnetName
  }
}
// sql server
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlServerName
}
// sql database
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}

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
          value: applicationInsights.properties.InstrumentationKey
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
          value: 'Data Source=tcp:${inspectorGadgetSqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${inspectorGadgetSqlDatabase.name};User Id=${adminUserName}@${inspectorGadgetSqlServer.properties.fullyQualifiedDomainName};Password=${adminPassword};'
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
    subnetResourceId: virtualNetwork002::vnetIntegrationSubnet.id
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
    workspaceId: logAnalyticsWorkspace.id
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
