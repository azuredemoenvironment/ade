// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param inspectorGadgetResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// variables
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
// resource - application insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: applicationInsightsName
}
// variables
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vnetIntegrationSubnetName = 'snet-vnetIntegration'
// resource - virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource vnetIntegrationSubnet 'subnets@2020-07-01' existing = {
    name: vnetIntegrationSubnetName
  }
}
// variables
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
// resource - sql server
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlServerName
}
// variables - inspectorGadgetSql
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
// resource - sql database
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}
// variables - private dns zone - azure app services
var azureAppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'

// module - app service plan
// variables
var appServicePlanName = 'plan-ade-${aliasRegion}-001'
// module deployment
module appServicePlanModule 'azure_app_service_plan.bicep' = {
  scope: resourceGroup(appServicePlanResourceGroupName)
  name: 'appServicePlanDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    appServicePlanName: appServicePlanName
  }
}

// module - inspectorGadgetAppService
// variables
var inspectorGadgetAppServiceName = replace('app-${aliasRegion}-inspectorgadget', '-', '')
var webAppRepoURL = 'https://github.com/jelledruyts/InspectorGadget/'
// module deployment
module inspectorGadgetAppService 'azure_app_services_inspectorgadget.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    applicationInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    webAppRepoURL: webAppRepoURL
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}
