// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The name of the Database Resource Group.')
param databaseResourceGroupName string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var appConfigConnectionString = first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
var appConfigName = 'appcs-${appEnvironment}-001'
var appServicePlanName = 'plan-${appEnvironment}-001'
var inspectorGadgetAppServiceName = replace('app-${appEnvironment}-inspectorgadget', '-', '')
var inspectorGadgetDockerImage = 'DOCKER|jelledruyts/inspectorgadget:latest'
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Variable Arrays
//////////////////////////////////////////////////
var appServices = [
  {
    name: replace('app-${appEnvironment}-ade-frontend', '-', '')
    appShortName: 'frontend'
    containerImageName: 'ade-frontend'
    privateEndpointName: 'pl-${appEnvironment}-ade-frontend'
    usePrivateEndpoint: false
  }
  {
    name: replace('app-${appEnvironment}-ade-apigateway', '-', '')
    appShortName: 'apigateway'
    containerImageName: 'ade-apigateway'
    privateEndpointName: 'pl-${appEnvironment}-ade-apigateway'
    usePrivateEndpoint: false
  }
  {
    name: replace('app-${appEnvironment}-ade-userservice', '-', '')
    appShortName: 'userservice'
    containerImageName: 'ade-userservice'
    privateEndpointName: 'pl-${appEnvironment}-ade-userservice'
    subnetId: virtualNetwork002::userServiceSubnet.id
    usePrivateEndpoint: true
  }
  {
    name: replace('app-${appEnvironment}-ade-dataingestorservice', '-', '')
    appShortName: 'dataingestorservice'
    containerImageName: 'ade-dataingestorservice'
    privateEndpointName: 'pl-${appEnvironment}-ade-dataingestorservice'
    subnetId: virtualNetwork002::dataIngestorServiceSubnet.id
    usePrivateEndpoint: true
  }
  {
    name: replace('app-${appEnvironment}-ade-datareporterservice', '-', '')
    appShortName: 'datareporterservice'
    containerImageName: 'ade-datareporterservice'
    privateEndpointName: 'pl-${appEnvironment}-ade-datareporterservice'
    subnetId: virtualNetwork002::dataReporterServiceSubnet.id
    usePrivateEndpoint: true
  }
  {
    name: replace('app-${appEnvironment}-ade-eventingestorservice', '-', '')
    appShortName: 'eventingestorservice'
    containerImageName: 'ade-eventingestorservice'
    privateEndpointName: 'pl-${appEnvironment}-ade-eventingestorservice'
    subnetId: virtualNetwork002::eventIngestorServiceSubnet.id
    usePrivateEndpoint: true
  }
]

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'appcs-${appEnvironment}-001'
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: replace('acr-${appEnvironment}-001', '-', '')
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'evh-${appEnvironment}-diagnostics/RootManageSharedAccessKey'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'kv-${appEnvironment}-001'
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: 'log-${appEnvironment}-001'
}

// Existing Resource - Private Dns Zone
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'privatelink.azurewebsites.net'
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Existing Resource - Sql Database - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: 'sqldb-${appEnvironment}-inspectorgadget'
}

// Existing Resource - Sql Server - Inspectorgadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: 'sql-${appEnvironment}-inspectorgadget'
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-002'
  resource dataIngestorServiceSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-dataIngestorService'
  }
  resource dataReporterServiceSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-dataReporterService'
  }
  resource eventIngestorServiceSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-eventIngestorService'
  }
  resource userServiceSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-userService'
  }
  resource vnetIntegrationSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-vnetIntegration'
  }
}

// Module - App Service Plan
//////////////////////////////////////////////////
module appServicePlanModule 'app_service_plan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    appServicePlanName: appServicePlanName
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - App Service - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetAppServiceModule 'app_service_inspectorgadget.bicep' = {
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    inspectorGadgetAppServiceName: inspectorGadgetAppServiceName
    inspectorGadgetDockerImage: inspectorGadgetDockerImage
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
  }
}

// Module - App Service - Ade App
//////////////////////////////////////////////////
module adeAppServicesModule 'app_service_adeapp.bicep' = {
  name: 'adeAppServicesDeployment'
  params: {
    appServices: appServices
    appConfigConnectionString: appConfigConnectionString
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    appServicePrivateDnsZoneId: appServicePrivateDnsZone.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    containerRegistryURL: containerRegistry.properties.loginServer
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    vnetIntegrationSubnetId: virtualNetwork002::vnetIntegrationSubnet.id
  }
}

// Module - Webhooks - Ade App(s)
//////////////////////////////////////////////////
module adeAppWebHooksModule 'azure_app_service_adeapp_webhooks.bicep' = {
  scope: resourceGroup(containerResourceGroupName)
  name: 'adeAppWebHooksDeployment'
  params: {
    appServices: appServices
    containerRegistryName: containerRegistry.name
    appDockerWebHookUris: adeAppServicesModule.outputs.appDockerWebHookUris
    location:location
  }
}

// Module - App Config - Ade App(s)
//////////////////////////////////////////////////
module appConfigAppServices './azure_app_config_app_services.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    appServices: appServices
    appConfigName: appConfigName
  }
}
