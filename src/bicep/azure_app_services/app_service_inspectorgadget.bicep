// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The properties of the App Service.')
param appService object

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The region location of deployment.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Sql Database.')
param sqlDatabaseName string

@description('The Fqdn of the Sql Server.')
param sqlServerFqdn string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - App Service
//////////////////////////////////////////////////
resource app 'Microsoft.Web/sites@2022-09-01' = {
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
          value: 'Data Source=tcp:${sqlServerFqdn},1433;Initial Catalog=${sqlDatabaseName};User Id=${adminUserName}@${sqlServerFqdn};Password=${adminPassword};'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}

// Resource - App Service - Diagnostic Settings
//////////////////////////////////////////////////
resource appServiceDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: app
  name: '${app.name}-diagnostics'
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
}

// Outputs
//////////////////////////////////////////////////
output appServiceCustomDomainVerificationId string = app.properties.customDomainVerificationId
output appServiceDefaultHostName string = app.properties.defaultHostName
output appServiceName string = app.name
