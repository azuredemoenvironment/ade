// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the App Service Plan.')
param appServicePlanId string

@description('The ID of the Diagnostics Storage Account.')
param diagnosticsStorageAccountId string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Inspector Gadget App Service.')
param inspectorGadgetAppServiceName string

@description('The Docker Image of the Inspector Gadget App Service.')
param inspectorGadgetDockerImage string

@description('The name of the Inspector Gadget Sql Database.')
param inspectorGadgetSqlDatabaseName string

@description('The FQDN of the Inspector Gadget Sql Server.')
param inspectorGadgetSqlServerFQDN string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Virtual Network Integration Subnet.')
param vnetIntegrationSubnetId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'inspectorGadget'
  costCenter: 'it'
}

// Resource - App Service - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetAppService 'Microsoft.Web/sites@2020-12-01' = {
  name: inspectorGadgetAppServiceName
  location: location
  tags: tags
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: false

    siteConfig: {
      linuxFxVersion: inspectorGadgetDockerImage
      appSettings: [
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

// Resource - App Service - Networking - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetAppServiceNetworking 'Microsoft.Web/sites/config@2020-12-01' = {
  name: '${inspectorGadgetAppService.name}/virtualNetwork'
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
    swiftSupported: true
  }
}

// Resource - App Service - Diagnostic Settings - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetAppServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: inspectorGadgetAppService
  name: '${inspectorGadgetAppService.name}-diagnostics'
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
}
