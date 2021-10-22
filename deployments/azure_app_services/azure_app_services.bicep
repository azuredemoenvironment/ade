// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppAppServicesResourceGroupName = 'rg-ade-${aliasRegion}-adeappweb'
var adeAppSqlResourceGroupName = 'rg-ade-${aliasRegion}-adeappdb'
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfiguration'
var appServicePlanResourceGroupName = 'rg-ade-${aliasRegion}-appserviceplan'
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var inspectorGadgetResourceGroupName = 'rg-ade-${aliasRegion}-inspectorgadget'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var adeAppAppServices = [
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-frontend', '-', '')
    adeAppName: 'frontend'
    containerImageName: 'ade-frontend'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-frontend'
    usePrivateEndpoint: false
  }
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-apigateway', '-', '')
    adeAppName: 'apigateway'
    containerImageName: 'ade-apigateway'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-apigateway'
    usePrivateEndpoint: false
  }
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-userservice', '-', '')
    adeAppName: 'userservice'
    containerImageName: 'ade-userservice'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-userservice'
    usePrivateEndpoint: true
  }
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-dataingestorservice', '-', '')
    adeAppName: 'dataingestorservice'
    containerImageName: 'ade-dataingestorservice'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-dataingestorservice'
    usePrivateEndpoint: true
  }
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-datareporterservice', '-', '')
    adeAppName: 'datareporterservice'
    containerImageName: 'ade-datareporterservice'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-datareporterservice'
    usePrivateEndpoint: true
  }
  {
    adeAppAppServiceName: replace('app-ade-${aliasRegion}-ade-eventingestorservice', '-', '')
    adeAppName: 'eventingestorservice'
    containerImageName: 'ade-eventingestorservice'
    privateEndpointName: 'pl-ade-${aliasRegion}-ade-eventingestorservice'
    usePrivateEndpoint: true
  }
]
var adeAppSqlDatabaseName = 'sqldb-ade-${aliasRegion}-adeapp'
var adeAppSqlServerName = 'sql-ade-${aliasRegion}-adeapp'
var appConfigConnectionString = first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var appServicePlanName = 'plan-ade-${aliasRegion}-001'
var azureAppServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var inspectorGadgetAppServiceName = replace('app-ade-${aliasRegion}-inspectorgadget', '-', '')
var inspectorGadgetDockerImage = 'DOCKER|jelledruyts/inspectorgadget:latest'
var inspectorGadgetSqlDatabaseName = 'sqldb-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-ade-${aliasRegion}-inspectorgadget'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var privateEndpointSubnetName = 'snet-ade-${aliasRegion}-privateEndpoint'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var vnetIntegrationSubnetName = 'snet-ade-${aliasRegion}-vnetIntegration'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: containerRegistryName
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(keyVaultResourceGroupName)
  name: keyVaultName
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Private Dns Zone - App Services
//////////////////////////////////////////////////
resource azureAppServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureAppServicePrivateDnsZoneName
}

// Existing Resource - Sql Database - Adeappsql
//////////////////////////////////////////////////
resource adeAppSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlDatabaseName
}

// Existing Resource - Sql Database - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}

// Existing Resource - Sql Server - Adeappsql
//////////////////////////////////////////////////
resource adeAppSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(adeAppSqlResourceGroupName)
  name: adeAppSqlServerName
}

// Existing Resource - Sql Server - Inspectorgadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: inspectorGadgetSqlServerName
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
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

// Resource Group - App Service Plan
//////////////////////////////////////////////////
resource appServicePlanResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: appServicePlanResourceGroupName
  location: azureRegion
}

// Resource Group - App Service - ADE App
//////////////////////////////////////////////////
resource adeAppAppServiceResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: adeAppAppServicesResourceGroupName
  location: azureRegion
}

// Module - App Service Plan
//////////////////////////////////////////////////
module appServicePlanModule 'azure_app_service_plan.bicep' = {
  scope: resourceGroup(appServicePlanResourceGroupName)
  name: 'appServicePlanDeployment'
  params: {
    appServicePlanName: appServicePlanName
  }
}

// Module - App Service - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetAppServiceModule 'azure_app_services_inspectorgadget.bicep' = {
  scope: resourceGroup(inspectorGadgetResourceGroupName)
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    inspectorGadgetDockerImage: inspectorGadgetDockerImage
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
  }
}

// Module - App Service - ADE App(s)
//////////////////////////////////////////////////
module adeAppServicesModule 'azure_app_services_adeapp.bicep' = {
  scope: resourceGroup(adeAppAppServicesResourceGroupName)
  name: 'adeAppServicesDeployment'
  dependsOn: [
    adeAppAppServiceResourceGroup
  ]
  params: {
    adeAppAppServices: adeAppAppServices
    appConfigConnectionString: appConfigConnectionString
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    azureAppServicePrivateDnsZoneId: azureAppServicePrivateDnsZone.id
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    privateEndpointSubnetId: virtualNetwork002::privateEndpointSubnet.id
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
  }
}

// Module - Webhooks - ADE App(s)
//////////////////////////////////////////////////
module adeAppWebHooksModule 'azure_app_service_adeapp_webhooks.bicep' = {
  scope: resourceGroup(containerRegistryResourceGroupName)
  name: 'adeAppWebHooksDeployment'
  params: {
    adeAppAppServices: adeAppAppServices
    containerRegistryName: containerRegistryName
    adeAppDockerWebHookUris: adeAppServicesModule.outputs.adeAppDockerWebHookUris
  }
}

// Module - App Config - ADE App(s)
//////////////////////////////////////////////////
module appConfigAppServices './azure_app_config_app_services.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    adeAppAppServices: adeAppAppServices
    appConfigName: appConfigName
  }
}
