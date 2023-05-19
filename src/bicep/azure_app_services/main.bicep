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

@description('The name of the Dns Zone Resource Group.')
param dnsZoneResourceGroupName string

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

// Variables - App Service - Certificate
//////////////////////////////////////////////////
var certificateName = 'wildcard'

// Variables - App Service - Inspector Gadget
//////////////////////////////////////////////////
var inspectorGadgetAppService = {
  name: replace('app-${appEnvironment}-inspectorgadget', '-', '')
  kind: 'container'
  httpsOnly: true
  serverFarmId: appServicePlanModule.outputs.serverFarmId
  virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
  vnetRouteAllEnabled: true
  linuxFxVersion: inspectorGadgetDockerImage
}
var inspectorGadgetDockerImage = 'DOCKER|jelledruyts/inspectorgadget:latest'

// Variables - App Service - Dns Records - Inspector Gadget
//////////////////////////////////////////////////
var inspectorGadgetAppServiceTxtRecords = [
  {
    name: 'asuid.inspectorgadget'
    ttl: 3600
    value: inspectorGadgetAppServiceModule.outputs.appServiceCustomDomainVerificationId
  }
]
var inspectorGadgetAppServiceCnameRecords = [
  {
    name: 'inspectorgadget'
    ttl: 3600
    cname: inspectorGadgetAppServiceModule.outputs.appServiceDefaultHostName
  }
]

// Variables - App Service - Tls - Inspector Gadget
//////////////////////////////////////////////////
var inspectorGadgetAppServiceTlsSettings = [
  {
    appServiceName: inspectorGadgetAppServiceModule.outputs.appServiceName
    applicationHostName: 'inspectorgadget.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
]

// Variables - App Service - Ade App
//////////////////////////////////////////////////
var adeAppServices = [
  {
    name: replace('app-${appEnvironment}-ade-frontend', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
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
  }
  {
    name: replace('app-${appEnvironment}-ade-apigateway', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
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
  }
  {
    name: replace('app-${appEnvironment}-ade-userservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-userservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::userServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-userservice'
    privateEndpointNicName: 'nic-${appEnvironment}-ade-userservice'
    privateEndpointPrivateIpAddress: '10.102.151.4'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-userservice'
  }
  {
    name: replace('app-${appEnvironment}-ade-dataingestorservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-dataingestorservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::dataIngestorServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-dataingestorservice'
    privateEndpointNicName: 'nic-${appEnvironment}-ade-dataingestorservice'
    privateEndpointPrivateIpAddress: '10.102.152.4'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-dataingestorservice'
  }
  {
    name: replace('app-${appEnvironment}-ade-datareporterservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-datareporterservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::dataReporterServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-datareporterservice'
    privateEndpointNicName: 'nic-${appEnvironment}-ade-datareporterservice'
    privateEndpointPrivateIpAddress: '10.102.153.4'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-datareporterservice'
  }
  {
    name: replace('app-${appEnvironment}-ade-eventingestorservice', '-', '')
    kind: 'container'
    httpsOnly: true
    serverFarmId: appServicePlanModule.outputs.serverFarmId
    virtualNetworkSubnetId: spokeVirtualNetwork::vnetIntegrationSubnet.id
    vnetRouteAllEnabled: true
    linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/ade-eventingestorservice'
    appConfigConnectionString: first(appConfig.listKeys().value).connectionString
    containerRegistryUrl: containerRegistry.properties.loginServer
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(containerRegistry.listCredentials().passwords).value
    subnetId: spokeVirtualNetwork::eventIngestorServiceSubnet.id
    privateEndpointName: 'pl-${appEnvironment}-ade-eventingestorservice'
    privateEndpointNicName: 'nic-${appEnvironment}-ade-eventingestorservice'
    privateEndpointPrivateIpAddress: '10.102.154.4'
    usePrivateEndpoint: true
    privateDnsZoneId: appServicePrivateDnsZone.id
    containerImageName: 'ade-eventingestorservice'
  }
]

// Variables - App Service - Dns Records - Ade App
//////////////////////////////////////////////////
var adeAppServiceTxtRecords = [
  {
    name: 'asuid.ade-frontend-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[0].appServiceCustomDomainVerificationId
  }
  {
    name: 'asuid.ade-apigateway-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[1].appServiceCustomDomainVerificationId
  }
  {
    name: 'asuid.ade-userservice-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[2].appServiceCustomDomainVerificationId
  }
  {
    name: 'asuid.ade-dataingestorservice-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[3].appServiceCustomDomainVerificationId
  }
  {
    name: 'asuid.ade-datareporterservice-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[4].appServiceCustomDomainVerificationId
  }
  {
    name: 'asuid.ade-eventingestorservice-app'
    ttl: 3600
    value: adeAppServiceModule.outputs.appServiceCustomDomainVerificationIds[5].appServiceCustomDomainVerificationId
  }
]
var adeAppServiceCnameRecords = [
  {
    name: 'ade-frontend-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[0].appServiceDefaultHostName
  }
  {
    name: 'ade-apigateway-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[1].appServiceDefaultHostName
  }
  {
    name: 'ade-userservice-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[2].appServiceDefaultHostName
  }
  {
    name: 'ade-dataingestorservice-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[3].appServiceDefaultHostName
  }
  {
    name: 'ade-datareporterservice-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[4].appServiceDefaultHostName
  }
  {
    name: 'ade-eventingestorservice-app'
    ttl: 3600
    cname: adeAppServiceModule.outputs.appServiceDefaultHostNames[5].appServiceDefaultHostName
  }
]

// Variables - App Service - Tls - Ade App
//////////////////////////////////////////////////
var adeFrontendApplicationName = 'ade-frontend-app'
var adeApiGatewayApplicationName = 'ade-apigateway-app'
var adeUserServiceApplicationName = 'ade-userservice-app'
var adeDataIngestorServiceApplicationName = 'ade-dataingestorservice-app'
var adeDataReporterServiceApplicationName = 'ade-datareporterservice-app'
var adeEventIngestorServiceApplicationName = 'ade-eventingestorservice-app'
var adeAppServiceTlsSettings = [
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[0].appServiceName}'
    applicationHostName: '${adeFrontendApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[1].appServiceName}'
    applicationHostName: '${adeApiGatewayApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[2].appServiceName}'
    applicationHostName: '${adeUserServiceApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[3].appServiceName}'
    applicationHostName: '${adeDataIngestorServiceApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[4].appServiceName}'
    applicationHostName: '${adeDataReporterServiceApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
  }
  {
    appServiceName: '${adeAppServiceModule.outputs.appServiceNames[5].appServiceName}'
    applicationHostName: '${adeEventIngestorServiceApplicationName}.${rootDomainName}'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    customHostNameDnsRecordType: 'CName'
    thumbprint: appServiceCertificateModule.outputs.certificateThumbprint
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

// Existing Resource - App Configuration
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

// Existing Resource - Dns Zone
//////////////////////////////////////////////////
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: rootDomainName
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

// Module - App Service - Certificate
//////////////////////////////////////////////////
module appServiceCertificateModule 'app_service_certificate.bicep' = {
  name: 'appServiceCertificateDeployment'
  params: {
    certificateName: certificateName
    keyVaultId: keyVault.id
    keyVaultSecretName: keyVaultSecretName
    location: location
    serverFarmId: appServicePlanModule.outputs.serverFarmId
  }
}

// Module - App Service - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetAppServiceModule 'app_service_inspectorgadget.bicep' = {
  name: 'inspectorGadgetAppServiceDeployment'
  params: {
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appService: inspectorGadgetAppService
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    sqlDatabaseName: inspectorGadgetSqlDatabase.name
    sqlServerFqdn: inspectorGadgetSqlServer.properties.fullyQualifiedDomainName
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - App Service - Dns Zone Records - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetAppServiceDnsZoneRecordsModule 'app_service_dns.bicep' = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: 'inspectorGadgetAppServiceDnsZoneRecordsDeployment'
  params: {
    dnsCnameRecords: inspectorGadgetAppServiceCnameRecords
    dnsTxtRecords: inspectorGadgetAppServiceTxtRecords
    dnsZoneName: dnsZone.name
  }
}

// Module - App Service - Tls Settings - Inspector Gadget
//////////////////////////////////////////////////
module inspectorGadgetAppServiceTlsSettingsModule 'app_service_tls.bicep' = {
  name: 'inspectorGadgetAppServiceTlsSettingsDeployment'
  params: {
    appServiceTlsSettings: inspectorGadgetAppServiceTlsSettings
  }
}

// Module - App Service - Ade App
// //////////////////////////////////////////////////
module adeAppServiceModule 'app_service_adeapp.bicep' = {
  name: 'adeAppServiceDeployment'
  params: {
    appServices: adeAppServices
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location:location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    tags: tags
  }
}

// Module - App Service - Dns Zone Records - Ade App
//////////////////////////////////////////////////
module adeAppServiceDnsZoneRecordsModule 'app_service_dns.bicep' = {
  scope: resourceGroup(dnsZoneResourceGroupName)
  name: 'adeAppServiceDnsZoneRecordsDeployment'
  params: {
    dnsCnameRecords: adeAppServiceCnameRecords
    dnsTxtRecords: adeAppServiceTxtRecords
    dnsZoneName: dnsZone.name
  }
}

// Module - App Service - Tls Settings - Ade App
//////////////////////////////////////////////////
module adeAppServiceTlsSettingsModule 'app_service_tls.bicep' = {
  name: 'adeAppServiceTlsSettingsDeployment'
  params: {
    appServiceTlsSettings: adeAppServiceTlsSettings
  }
}

// Module - Webhooks - Ade App(s)
//////////////////////////////////////////////////
module adeAppWebHooksModule 'app_service_webhooks.bicep' = {
  scope: resourceGroup(containerResourceGroupName)
  name: 'adeAppWebHooksDeployment'
  params: {
    appDockerWebHookUris: adeAppServiceModule.outputs.appDockerWebHookUris
    appServices: adeAppServices
    location:location
  }
}
