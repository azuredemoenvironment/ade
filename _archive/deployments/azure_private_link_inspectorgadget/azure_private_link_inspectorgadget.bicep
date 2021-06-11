param location string {
  metadata: {
    description: 'Location For All Resources.'
  }
  default: resourceGroup().location
}
param inspectorGadgetSqlServerName string {
  metadata: {
    description: 'The Name of the SQL Server Instance.'
  }
}
param inspectorGadgetSqlAdminUserName string {
  metadata: {
    description: 'Specifies the SQL Server Administrator User Name.'
  }
}
param inspectorGadgetSqlAdminPassword string {
  metadata: {
    description: 'Specifies the SQL ServerAdministrator Password.'
  }
}
param inspectorGadgetSqlDatabaseName string {
  metadata: {
    description: 'The Name of the Inspector Gadget SQL Database.'
  }
}
param inspectorGadgetAzureSQLPrivateEndpointName string {
  metadata: {
    description: 'The Name of the Inspector Gadget Private Endpoint.'
  }
}
param virtualNetwork03ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 03 Resource Group.'
  }
}
param virtualNetwork03Name string {
  metadata: {
    description: 'The Name of Virtual Network 03.'
  }
}
param privateDnsZoneResourceGroupName string {
  metadata: {
    description: 'The Name of the Private DNS Zone Resource Group'
  }
}
param inspectorGadgetAppInsightsName string {
  metadata: {
    description: 'The Name of the Inspector Gadget App Insights Instance.'
  }
}
param primaryRegionAppServicePlanResourceGroupName string {
  metadata: {
    description: 'The Name of the Primary Region App Service Plan Resource Group.'
  }
}
param primaryRegionAppServicePlanName string {
  metadata: {
    description: 'The Name of the Primary Region App Service Plan.'
  }
}
param inspectorGadgetWebAppName string {
  metadata: {
    description: 'The Name of the Inspector Gadget Web App.'
  }
}
param inspectorGadgetAppServicePrivateEndpointName string {
  metadata: {
    description: 'The Name of the Inspector Gadget Private Endpoint.'
  }
}
param logAnalyticsWorkspaceResourceGroupName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace Resource Group.'
  }
}
param logAnalyticsWorkspaceName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace.'
  }
}

var inspectorGadgetAzureSQLPrivateEndpointSubnetName = 'inspectorGadget-azuresql-privateendpoint'
var inspectorGadgetAzureSQLPrivateEndpointSubnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork03ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork03Name}/subnets/${inspectorGadgetAzureSQLPrivateEndpointSubnetName}'
var azureSQLprivateEndpointDnsGroupName_var = '${inspectorGadgetAzureSQLPrivateEndpointName}/inspectorgadget'
var azureSQLprivateDnsZoneName = 'privatelink.database.windows.net'
var azureSQLprivateDnsZoneId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${privateDnsZoneResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${azureSQLprivateDnsZoneName}'
var appServicePlanId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${primaryRegionAppServicePlanResourceGroupName}/providers/Microsoft.Web/serverfarms/${primaryRegionAppServicePlanName}'
var inspectorGadgetAppServiceVnetIntegrationSubnetName = 'inspectorGadget-appservice-vnetintegration'
var inspectorGadgetAppServiceVnetIntegrationSubnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork03ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork03Name}/subnets/${inspectorGadgetAppServiceVnetIntegrationSubnetName}'
var webAppRepoURL = 'https://github.com/jelledruyts/InspectorGadget/'
var inspectorGadgetWebAppDnsName = '.azurewebsites.net'
var inspectorGadgetAppServicePrivateEndpointSubnetName = 'inspectorGadget-appservice-privateendpoint'
var inspectorGadgetAppServicePrivateEndpointSubnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork03ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork03Name}/subnets/${inspectorGadgetAppServicePrivateEndpointSubnetName}'
var appServicePrivateEndpointDnsGroupName_var = '${inspectorGadgetAppServicePrivateEndpointName}/inspectorgadget'
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var appServicePrivateDnsZoneId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${privateDnsZoneResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${appServicePrivateDnsZoneName}'
var logAnalyticsWorkspaceID = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${logAnalyticsWorkspaceResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}'
var environmentName = 'Production'
var functionName = 'InspectorGadget'
var costCenterName = 'IT'

resource inspectorGadgetSqlServerName_resource 'Microsoft.Sql/servers@2015-05-01-preview' = {
  name: inspectorGadgetSqlServerName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  properties: {
    administratorLogin: inspectorGadgetSqlAdminUserName
    administratorLoginPassword: inspectorGadgetSqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
  dependsOn: []
}

resource inspectorGadgetSqlServerName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2015-05-01-preview' = if (true) {
  name: '${inspectorGadgetSqlServerName_resource.name}/AllowAllWindowsAzureIps'
  location: location
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource inspectorGadgetSqlServerName_inspectorGadgetSqlDatabaseName 'Microsoft.Sql/servers/databases@2017-10-01-preview' = {
  name: '${string(inspectorGadgetSqlServerName)}/${string(inspectorGadgetSqlDatabaseName)}'
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 10
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 1073741824
    zoneRedundant: false
    licenseType: 'LicenseIncluded'
  }
  dependsOn: [
    inspectorGadgetSqlServerName_resource
  ]
}

resource inspectorGadgetSqlServerName_inspectorGadgetSqlDatabaseName_Microsoft_Insights_inspectorGadgetSqlDatabaseName_Diagnostics 'Microsoft.Sql/servers/databases/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${string(inspectorGadgetSqlServerName)}/${string(inspectorGadgetSqlDatabaseName)}/Microsoft.Insights/${inspectorGadgetSqlDatabaseName}-Diagnostics'
  tags: {}
  properties: {
    name: '${inspectorGadgetSqlDatabaseName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AutomaticTuning'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'Deadlocks'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'WorkloadManagement'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
  dependsOn: [
    inspectorGadgetSqlServerName_inspectorGadgetSqlDatabaseName
  ]
}

resource inspectorGadgetAzureSQLPrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: inspectorGadgetAzureSQLPrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: inspectorGadgetAzureSQLPrivateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: inspectorGadgetAzureSQLPrivateEndpointName
        properties: {
          privateLinkServiceId: inspectorGadgetSqlServerName_resource.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource azureSQLprivateEndpointDnsGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: azureSQLprivateEndpointDnsGroupName_var
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: azureSQLprivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    inspectorGadgetAzureSQLPrivateEndpointName_resource
  ]
}

resource inspectorGadgetAppInsightsName_resource 'Microsoft.Insights/components@2020-02-02-preview' = {
  kind: 'web'
  name: inspectorGadgetAppInsightsName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceID
  }
  dependsOn: []
}

resource inspectorGadgetWebAppName_resource 'Microsoft.Web/sites@2018-02-01' = {
  name: inspectorGadgetWebAppName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
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
          value: reference('Microsoft.insights/components/${inspectorGadgetAppInsightsName}').InstrumentationKey
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
          value: 'Data Source=tcp:${reference('Microsoft.Sql/servers/${inspectorGadgetSqlServerName}').fullyQualifiedDomainName},1433;Initial Catalog=${inspectorGadgetSqlDatabaseName};User Id=${inspectorGadgetSqlAdminUserName}@${reference('Microsoft.Sql/servers/${inspectorGadgetSqlServerName}').fullyQualifiedDomainName};Password=${inspectorGadgetSqlAdminPassword};'
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
      connectionStrings: []
    }
  }
  dependsOn: [
    inspectorGadgetAppInsightsName_resource
  ]
}

resource inspectorGadgetWebAppName_virtualNetwork 'Microsoft.Web/sites/config@2019-08-01' = {
  name: '${inspectorGadgetWebAppName_resource.name}/virtualNetwork'
  properties: {
    subnetResourceId: inspectorGadgetAppServiceVnetIntegrationSubnetId
    swiftSupported: true
  }
}

resource inspectorGadgetWebAppName_web 'Microsoft.Web/sites/sourcecontrols@2018-02-01' = {
  name: '${inspectorGadgetWebAppName_resource.name}/web'
  properties: {
    repoUrl: webAppRepoURL
    branch: 'master'
    isManualIntegration: true
  }
}

resource inspectorGadgetWebAppName_Microsoft_Insights_inspectorGadgetWebAppName_Diagnostics 'Microsoft.Web/sites/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${inspectorGadgetWebAppName}/Microsoft.Insights/${inspectorGadgetWebAppName}-Diagnostics'
  tags: {}
  properties: {
    name: '${inspectorGadgetWebAppName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
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
  dependsOn: [
    inspectorGadgetWebAppName_resource
  ]
}

resource inspectorGadgetWebAppName_inspectorGadgetWebAppName_inspectorGadgetWebAppDnsName 'Microsoft.Web/sites/hostNameBindings@2019-08-01' = {
  name: '${inspectorGadgetWebAppName_resource.name}/${inspectorGadgetWebAppName}${inspectorGadgetWebAppDnsName}'
  location: location
  properties: {
    siteName: inspectorGadgetWebAppName
    hostNameType: 'Verified'
  }
}

resource inspectorGadgetAppServicePrivateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: inspectorGadgetAppServicePrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: inspectorGadgetAppServicePrivateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: inspectorGadgetAppServicePrivateEndpointName
        properties: {
          privateLinkServiceId: inspectorGadgetWebAppName_resource.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource appServiceprivateEndpointDnsGroupName 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  name: appServicePrivateEndpointDnsGroupName_var
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: appServicePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    inspectorGadgetAppServicePrivateEndpointName_resource
  ]
}