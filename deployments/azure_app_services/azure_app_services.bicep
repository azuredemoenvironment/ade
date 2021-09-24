// target scope
targetScope = 'subscription'

// parameters
param azureRegion string
param aliasRegion string
param appServicePlanResourceGroupName string
param adeAppAppServicesResourceGroupName string
param adeAppSqlResourceGroupName string
param inspectorGadgetResourceGroupName string
param containerRegistryResourceGroupName string
param appConfigResourceGroupName string
param adminUserName string
param adminPassword string

// service name variables
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vnetIntegrationSubnetName = 'snet-ade-${aliasRegion}-vnetIntegration'
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var azureContainerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var azureAppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var appConfigName = 'appcs-ade-${aliasRegion}-001'

// existing resources

// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// resource - virtual network - virtual network 002
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

// resource - sql server - inspectorgadget
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlServerName
}

// resource - sql database - inspector gadget
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}

// resource - container registry
resource azureContainerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: azureContainerRegistryName
}

// resource - sql server - adeappsql
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlServerName
}

// resource - sql database - adeappsql
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlDatabaseName
}

// resource - private dns zone - app services
resource azureAppServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureAppServicePrivateDnsZoneName
}

// resource - app config
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// module - app service plan

// variables
var appServicePlanName = 'plan-ade-${aliasRegion}-001'
// module deployment
module appServicePlanModule 'azure_app_service_plan.bicep' = {
  scope: resourceGroup(appServicePlanResourceGroupName)
  name: 'appServicePlanDeployment'
  params: {
    azureRegion: azureRegion
    appServicePlanName: appServicePlanName
  }
}

// module - inspectorGadgetAppService
// variables
var inspectorGadgetAppServiceName = replace('app-ade-${aliasRegion}-inspectorgadget', '-', '')
var inspectorGadgetDockerImage = 'DOCKER|jelledruyts/inspectorgadget:latest'

// module deployment
module inspectorGadgetAppServiceModule 'azure_app_services_inspectorgadget.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    azureRegion: azureRegion
    adminUserName: adminUserName
    adminPassword: adminPassword
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    inspectorGadgetDockerImage: inspectorGadgetDockerImage
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
  }
}

// module - adeApp
// variables
var adeApps = [
  {
    name: 'Frontend'
    usePrivateEndpoint: false
  }
  {
    name: 'ApiGateway'
    usePrivateEndpoint: false
  }
  {
    name: 'UserService'
    usePrivateEndpoint: true
  }
  {
    name: 'DataIngestorService'
    usePrivateEndpoint: true
  }
  {
    name: 'DataReporterService'
    usePrivateEndpoint: true
  }
  {
    name: 'EventIngestorService'
    usePrivateEndpoint: true
  }
]

var appConfigConnectionString = first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
var azureContainerRegistryCredentials = first(listCredentials(azureContainerRegistry.id, azureContainerRegistry.apiVersion).passwords).value

// module deployment
module adeAppServicesModule 'azure_app_services_adeapp.bicep' = [for adeApp in adeApps: {
  scope: resourceGroup(adeAppAppServicesResourceGroupName)
  name: 'ade${adeApp.name}AppServicesDeployment'
  params: {
    azureRegion: azureRegion
    aliasRegion: aliasRegion
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    appConfigConnectionString: appConfigConnectionString
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    azureContainerRegistryName: azureContainerRegistryName
    azureContainerRegistryURL: azureContainerRegistry.properties.loginServer
    azureContainerRegistryCredentials: azureContainerRegistryCredentials
    azureAppServicePrivateDnsZoneId: azureAppServicePrivateDnsZone.id
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    adeAppName: toLower(adeApp.name)
    usePrivateEndpoint: adeApp.usePrivateEndpoint
  }
}]

// module - adeAppWebHooks
// variables
// module deployment
module adeAppWebHooksModule 'azure_app_service_adeapp_webhooks.bicep' = [for (adeApp, i) in adeApps: {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'ade${adeApp.name}AppWebHooksDeployment'
  params: {
    azureRegion: azureRegion
    azureContainerRegistryName: azureContainerRegistryName
    adeAppServiceName: adeAppServicesModule[i].outputs.adeAppServiceName
    adeAppContainerImageName: adeAppServicesModule[i].outputs.adeAppContainerImageName
    adeAppDockerWebHookUri: adeAppServicesModule[i].outputs.adeAppDockerWebHookUri
  }
}]

// module - app config - app services
module azureAppServicesAdeAppConfig './azure_app_services_adeapp_app_config.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    aliasRegion: aliasRegion
    appConfigName: appConfigName
    backendServices: adeApps
  }
}
