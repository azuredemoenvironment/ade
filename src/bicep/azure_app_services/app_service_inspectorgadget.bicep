// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The array of App Service.')
param appServices array

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The name of the Inspector Gadget Sql Database.')
param inspectorGadgetSqlDatabaseName string

@description('The FQDN of the Inspector Gadget Sql Server.')
param inspectorGadgetSqlServerFQDN string

@description('The region location of deployment.')
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
          name: 'DefaultSqlConnectionSqlConnectionString'
          value: 'Data Source=tcp:${inspectorGadgetSqlServerFQDN},1433;Initial Catalog=${inspectorGadgetSqlDatabaseName};User Id=${adminUserName}@${inspectorGadgetSqlServerFQDN};Password=${adminPassword};'
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
resource appServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = [for (appService, i) in appServices: {
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
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}]

// Outputs
//////////////////////////////////////////////////
output appServiceCustomDomainVerificationIds array = [for (appService, i) in appServices: {
  appServiceCustomDomainVerificationId: app[i].properties.customDomainVerificationId
}]
output appServiceNames array = [for (appService, i) in appServices: {
  appServiceName: app[i].name
}]
