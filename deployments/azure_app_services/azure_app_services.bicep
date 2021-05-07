// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param containerRegistryResourceGroupName string
param adminUserName string
param adminPassword string

// existing resources
// log analytics workspace
// variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// application insights
// variables
var applicationInsightsName = 'appinsights-ade-${aliasRegion}-001'
// resource
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: applicationInsightsName
}
// virtual network - virtual network 002
// variables
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vnetIntegrationSubnetName = 'snet-vnetIntegration'
var privateEndpointSubnetName = 'snet-privateEndpoint'
// resource
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource vnetIntegrationSubnet 'subnets@2020-07-01' existing = {
    name: vnetIntegrationSubnetName
  }
  resource privateEndpointSubnet 'subnets@2020-07-01' existing = {
    name: privateEndpointSubnetName
  }
}
// sql server - inspectorgadget
// variables
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
// resource 
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlServerName
}
// sql database - inspector gadget
// variables
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
// resource
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}
// container registry
// variables
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
// resource
resource azureContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: azureContainerRegistryName
}
// sql server - adeappsql
// variables
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
// resource 
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlServerName
}
// sql database - adeappsql
// variables
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
// resource
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlDatabaseName
}
// private dns zone - app services
// variables
var azureAppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
// resource
resource azureAppServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureAppServicePrivateDnsZoneName
}

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
var inspectorGadgetAppServiceName = replace('app-ade-${aliasRegion}-inspectorgadget', '-', '')
var webAppRepoURL = 'https://github.com/jelledruyts/InspectorGadget/'
// // module deployment
module inspectorGadgetAppServiceModule 'azure_app_services_inspectorgadget.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    inspectorGadgetSqlServerName: inspectorGadgetSqlServerName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}

// module - adeApp
// variables
var adeAppFrontEndAppServiceName = replace('app-ade-${aliasRegion}-ade-frontend', '-', '') // public
var adeAppApiGatewayAppServiceName = replace('app-ade-${aliasRegion}-ade-apigateway', '-', '') // public
var adeAppUserServiceAppServiceName = replace('app-ade-${aliasRegion}-ade-userservice', '-', '')
var adeAppDataIngestorServiceAppServiceName = replace('app-ade-${aliasRegion}-ade-dataingestorservice', '-', '')
var adeAppDataReporterServiceAppServiceName = replace('app-ade-${aliasRegion}-ade-datareporterservice', '-', '')
var adeAppFrontEndAppServiceImageName = 'ade-frontend:latest'
var adeAppApiGatewayAppServiceImageName = 'ade-apigateway:latest'
var adeAppUserServiceAppServiceImageName = 'ade-userservice:latest'
var adeAppDataIngestorServiceAppServiceImageName = 'ade-dataingestorservice'
var adeAppDataReporterServiceAppServiceImageName = 'ade-datareporterservice'
var adeAppUserServiceAppServicePrivateEndpointName = 'pl-ade-${aliasRegion}-ade-userservice'
var adeAppDataIngestorServiceAppServicePrivateEndpointName = 'pl-ade-${aliasRegion}-ade-dataingestorservice'
var adeAppDataReporterServiceAppServicePrivateEndpointName = 'pl-ade-${aliasRegion}-ade-datareporterservice'
// module deployment
module adeAppAppServiceModule 'azure_app_services_adeapp.bicep' = {
  scope: resourceGroup(adeAppAppServicesResourceGroupName)
  name: 'adeAppAppServiceDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    azureContainerRegistryName: azureContainerRegistryName
    azureContainerRegistryURL: azureContainerRegistry.properties.loginServer
    azureContainerRegistryCredentials: first(listCredentials(azureContainerRegistry.id, azureContainerRegistry.apiVersion).passwords).value
    adeAppSqlServerFQDN: adeAppSqlServer.properties.fullyQualifiedDomainName
    adeAppSqlServerName: adeAppSqlServerName
    adeAppSqlDatabaseName: adeAppSqlDatabase.name
    azureAppServicePrivateDnsZoneId: azureAppServicePrivateDnsZone.id
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    adeAppFrontEndAppServiceName: adeAppFrontEndAppServiceName
    adeAppApiGatewayAppServiceName: adeAppApiGatewayAppServiceName
    adeAppUserServiceAppServiceName: adeAppUserServiceAppServiceName
    adeAppDataIngestorServiceAppServiceName: adeAppDataIngestorServiceAppServiceName
    adeAppDataReporterServiceAppServiceName: adeAppDataReporterServiceAppServiceName
    adeAppFrontEndAppServiceImageName: adeAppFrontEndAppServiceImageName
    adeAppApiGatewayAppServiceImageName: adeAppApiGatewayAppServiceImageName
    adeAppUserServiceAppServiceImageName: adeAppUserServiceAppServiceImageName
    adeAppUserServiceAppServicePrivateEndpointName: adeAppUserServiceAppServicePrivateEndpointName
    adeAppDataIngestorServiceAppServicePrivateEndpointName: adeAppDataIngestorServiceAppServicePrivateEndpointName
    adeAppDataReporterServiceAppServicePrivateEndpointName: adeAppDataReporterServiceAppServicePrivateEndpointName
    adeAppDataIngestorServiceAppServiceImageName: adeAppDataIngestorServiceAppServiceImageName
    adeAppDataReporterServiceAppServiceImageName: adeAppDataReporterServiceAppServiceImageName
  }
}

// module - adeAppWebHooks
// variables
// module deployment
module adeAppWebHooksModule 'azure_app_service_adeapp_webhooks.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'adeAppWebHooksDeployment'
  params: {
    defaultPrimaryRegion: defaultPrimaryRegion
    azureContainerRegistryName: azureContainerRegistryName
    adeAppFrontEndAppServiceName: adeAppFrontEndAppServiceName
    adeAppApiGatewayAppServiceName: adeAppApiGatewayAppServiceName
    adeAppUserServiceAppServiceName: adeAppUserServiceAppServiceName
    adeAppDataIngestorServiceAppServiceName: adeAppDataIngestorServiceAppServiceName
    adeAppDataReporterServiceAppServiceName: adeAppDataReporterServiceAppServiceName
    adeAppFrontEndAppServiceImageName: adeAppFrontEndAppServiceImageName
    adeAppApiGatewayAppServiceImageName: adeAppApiGatewayAppServiceImageName
    adeAppUserServiceAppServiceImageName: adeAppUserServiceAppServiceImageName
    adeAppDataIngestorServiceAppServiceImageName: adeAppDataIngestorServiceAppServiceImageName
    adeAppDataReporterServiceAppServiceImageName: adeAppDataReporterServiceAppServiceImageName
    adeAppFrontEndAppServiceUri: adeAppAppServiceModule.outputs.adeAppFrontEndAppServiceUri
    adeAppApiGatewayAppServiceUri: adeAppAppServiceModule.outputs.adeAppApiGatewayAppServiceUri
    adeAppUserServiceAppServiceUri: adeAppAppServiceModule.outputs.adeAppUserServiceAppServiceUri
    adeAppDataIngestorServiceAppServiceUri: adeAppAppServiceModule.outputs.adeAppDataIngestorServiceAppServiceUri
    adeAppDataReporterServiceAppServiceUri: adeAppAppServiceModule.outputs.adeAppDataReporterServiceAppServiceUri
  }
}
