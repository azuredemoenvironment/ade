// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The current date.')
param currentDate string = utcNow('yyyy-MM-dd')

@description('The name of the Database Resource Group.')
param databaseResourceGroupName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the Management Resource Group.')
param managementResourceGroupName string

@description('The name of the Networking Resource Group.')
param networkingResourceGroupName string

@description('The name of the owner of the deployment.')
param ownerName string

@description('The value for Root Domain Name.')
param rootDomainName string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

// Variables
//////////////////////////////////////////////////
var tags = {
  deploymentDate: currentDate
  owner: ownerName
}

// Variables - App Service Plan
//////////////////////////////////////////////////
var appServicePlanName = 'plan-${appEnvironment}'
var appServicePlanProperties = {
  name: appServicePlanName
  kind: 'linux'
  skuName: 'P1v3'
  reserved: true
}

// Variables - App Service - Inspector Gadget
//////////////////////////////////////////////////
var inspectorGadgetAppServiceName = replace('app-${appEnvironment}-inspectorgadget', '-', '')
var inspectorGadgetApplicationName = 'inspectorgadget'
var inspectorGadgetAppServices = [
  {
    name: inspectorGadgetAppServiceName
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: inspectorGadgetDockerImage
  }
]
var inspectorGadgetDockerImage = 'DOCKER|jelledruyts/inspectorgadget:latest'

// Variables - App Service - Ade App
//////////////////////////////////////////////////
var adeAppAppServices = [
  {
    name: replace('app-${appEnvironment}-ade-frontend', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-frontend'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: null
    privateEndpointName: 'pl-${appEnvironment}-ade-frontend'
    usePrivateEndpoint: false
    privateDnsZoneId: null
    containerImageName: 'ade-frontend'
    appConfigName: appConfig.name
    keyValueName: '${appConfig.name}/Ade:frontendUri$appservices'
  }
  {
    name: replace('app-${appEnvironment}-ade-apigateway', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-apigateway'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: null
    privateEndpointName: 'pl-${appEnvironment}-ade-apigateway'
    usePrivateEndpoint: false
    privateDnsZoneId: null
    containerImageName: 'ade-apigateway'
    keyValueName: '${appConfig.name}/Ade:apigatewayUri$appservices'
  }
  {
    name: replace('app-${appEnvironment}-ade-userservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-userservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::userServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-userservice'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-userservice'
    keyValueName: '${appConfig.name}/Ade:userserviceUri$appservices'
  }
  {
    name: replace('app-${appEnvironment}-ade-dataingestorservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-dataingestorservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::dataIngestorServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-dataingestorservice'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-dataingestorservice'
    keyValueName: '${appConfig.name}/Ade:dataingestorserviceUri$appservices'
  }
  {
    name: replace('app-${appEnvironment}-ade-datareporterservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-datareporterservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::dataReporterServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-datareporterservice'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-datareporterservice'
    keyValueName: '${appConfig.name}/Ade:datareporterserviceUri$appservices'
  }
  {
    name: replace('app-${appEnvironment}-ade-eventingestorservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-eventingestorservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::eventIngestorServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-eventingestorservice'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-eventingestorservice'
    keyValueName: '${appConfig.name}/Ade:eventingestorserviceUri$appservices'
  }
]

// Variables - App Service - Dns Records
//////////////////////////////////////////////////
var appServiceDnsRecords = [
  {
    applicationName: inspectorGadgetApplicationName
    appServiceCustomDomainVerificationId: inspectorGadgetAppServiceModule.outputs.appServiceCustomDomainVerificationIds[0].appServiceCustomDomainVerificationId
    appServiceName: inspectorGadgetAppServiceName
    dnsZoneName: publicDnsZone.name
  }
]

// Variables - App Service - Tls
//////////////////////////////////////////////////
var appServiceTlsSettings = [
  {
    appServiceName: '${inspectorGadgetAppServiceModule.outputs.appServiceNames[0].appServiceName}'
    applicationHostName: '${inspectorGadgetApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'Disabled'
    customHostNameDnsRecordType: 'CName'
    certificateName: 'cert-${inspectorGadgetApplicationName}-wildcard'
    keyVaultId: keyVault.id
    serverFarmId: appServicePlanModule.outputs.appServicePlanId
  }
]

// Variables - Existing Resources
//////////////////////////////////////////////////
var appConfigName = 'appcs-${appEnvironment}'
var appServicePrivateDnsZoneName = 'privatelink.azurewebsites.net'
var containerRegistryName = replace('acr-${appEnvironment}', '-', '')
var dataIngestorServiceSubnetName = 'snet-${appEnvironment}-dataIngestorService'
var dataReporterServiceSubnetName = 'snet-${appEnvironment}-dataReporterService'
var eventHubNamespaceAuthorizationRuleName = 'RootManageSharedAccessKey'
var eventHubNamespaceName = 'evhns-${appEnvironment}-diagnostics'
var eventIngestorServiceSubnetName = 'snet-${appEnvironment}-eventIngestorService'
var inspectorGadgetSqlDatabaseName = 'sqldb-${appEnvironment}-inspectorgadget'
var inspectorGadgetSqlServerName = 'sql-${appEnvironment}-inspectorgadget'
var keyVaultName = 'kv-${appEnvironment}'
var keyVaultSecretName = 'certificate'
var logAnalyticsWorkspaceName = 'log-${appEnvironment}'
var publicDnsZoneName = rootDomainName
var spokeVirtualNetworkName = 'vnet-${appEnvironment}-spoke'
var storageAccountName = replace('sa-diag-${uniqueString(subscription().subscriptionId)}', '-', '')
var userServiceSubnetName = 'snet-${appEnvironment}-userService'
var vnetIntegrationSubnetName = 'snet-${appEnvironment}-vnetIntegration'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: appConfigName
}

// Existing Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(containerResourceGroupName)
  name: containerRegistryName
}

// Existing Resource - Event Hub Authorization Rule
//////////////////////////////////////////////////
resource eventHubNamespaceAuthorizationRule 'Microsoft.EventHub/namespaces/authorizationRules@2022-10-01-preview' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: '${eventHubNamespaceName}/${eventHubNamespaceAuthorizationRuleName}'
}

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  scope: resourceGroup(securityResourceGroupName)
  name: keyVaultName
  resource keyVaultSecret 'secrets' existing = {
    name: keyVaultSecretName
  }
}

// Existing Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: logAnalyticsWorkspaceName
}

// Existing Resource - Private Dns Zone - App Service
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: appServicePrivateDnsZoneName
}

// Existing Resource - Public Dns Zone
resource publicDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: publicDnsZoneName
}

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: storageAccountName
}

// Existing Resource - Sql Database - Inspector Gadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: inspectorGadgetSqlDatabaseName
}

// Existing Resource - Sql Server - Inspectorgadget
//////////////////////////////////////////////////
resource inspectorGadgetSqlServer 'Microsoft.Sql/servers@2020-11-01-preview' existing = {
  scope: resourceGroup(databaseResourceGroupName)
  name: inspectorGadgetSqlServerName
}

// Existing Resource - Virtual Network - Spoke
//////////////////////////////////////////////////
resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: spokeVirtualNetworkName
  resource userServiceSubnet 'subnets@2022-09-01' existing = {
    name: userServiceSubnetName
  }
  resource dataIngestorServiceSubnet 'subnets@2022-09-01' existing = {
    name: dataIngestorServiceSubnetName
  }
  resource dataReporterServiceSubnet 'subnets@2022-09-01' existing = {
    name: dataReporterServiceSubnetName
  }
  resource eventIngestorServiceSubnet 'subnets@2022-09-01' existing = {
    name: eventIngestorServiceSubnetName
  }
  resource vnetIntegrationSubnet 'subnets@2022-09-01' existing = {
    name: vnetIntegrationSubnetName
  }
}

// Module - App Service Plan
//////////////////////////////////////////////////
module appServicePlanModule 'app_service_plan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    appServicePlanProperties: appServicePlanProperties
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
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
    appServices: inspectorGadgetAppServices
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    inspectorGadgetSqlDatabaseName: inspectorGadgetSqlDatabase.name
    inspectorGadgetSqlServerFQDN: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - App Service - Ade App
// //////////////////////////////////////////////////
module adeAppServicesModule 'app_service_adeapp.bicep' = {
  name: 'adeAppServicesDeployment'
  params: {
    appServices: adeAppAppServices
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - App Service - Dns Zone Records
//////////////////////////////////////////////////
// module appServiceDnsZoneRecordsModule 'app_service_dns_records.bicep' = {
//   scope: resourceGroup(networkingResourceGroupName)
//   name: 'appServiceDnsZoneRecordsDeployment'
//   params: {
//     appServiceDnsRecords: appServiceDnsRecords
//   }
// }

// Module - App Service - Tls Settings
//////////////////////////////////////////////////
// module appServiceTlsSettingsModule 'app_service_tls.bicep' = {
//   name: 'appServiceTlsSettingsDeployment'
//   params: {
//     appServiceTlsSettings: appServiceTlsSettings
//     keyVaultSecretName: keyVaultSecretName
//     location: location
//   }
// }

// Module - Webhooks - Ade App(s)
//////////////////////////////////////////////////
module adeAppWebHooksModule 'app_service_webhooks.bicep' = {
  scope: resourceGroup(containerResourceGroupName)
  name: 'adeAppWebHooksDeployment'
  params: {
    appDockerWebHookUris: adeAppServicesModule.outputs.appDockerWebHookUris
    appServices: adeAppAppServices
    location:location
  }
}

// Module - App Config - Ade App(s)
//////////////////////////////////////////////////
module appConfigAppServices 'app_service_app_config.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    appServices: adeAppAppServices
  }
}
