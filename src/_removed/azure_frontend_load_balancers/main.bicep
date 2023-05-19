// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The application environment (workload, environment, location).')
param appEnvironment string

@description('The name of the Container Resource Group.')
param containerResourceGroupName string

@description('The date of the resource deployment.')
param deploymentDate string = utcNow('yyyy-MM-dd')

@description('The name of the Identity Resource Group.')
param identityResourceGroupName string

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

@description('The name of the SSL Certificate.')
param sslCertificateName string

@description('The base URI for deployment scripts.')
param scriptsBaseUri string

@description('The name of the Security Resource Group.')
param securityResourceGroupName string

@description('The name of the Virtual Machine Resource Group.')
param virtualMachineResourceGroupName string

// Variables
//////////////////////////////////////////////////
var adeAppVmssLoadBalancerPrivateIpAddress = '10.102.12.4'
var adeWebModuleName = 'frontend'
var adeWebVmssName = 'vmss-${appEnvironment}-adeweb-vmss'
var adeWebVmssNICName = 'nic-${appEnvironment}-adeweb-vmss'
var applicationGatewayName = 'appgw-${appEnvironment}-001'
var applicationGatewayPublicIpAddressName = 'pip-${appEnvironment}-appgw001'
var sslCertificateDataPassword = ''
var tags = {
  deploymentDate: deploymentDate
  owner: ownerName
}

// Variable Arrays
//////////////////////////////////////////////////
var apiGateway = [
  {
    aksHostName: 'ade-apigateway-aks.${rootDomainName}'
    appServiceHostName: 'ade-apigateway-app.${rootDomainName}'
    fqdn: replace('app-${appEnvironment}-ade-apigateway.azurewebsites.net', '-', '')    
    hostName: 'ade-apigateway.${rootDomainName}'
    vmHostName: 'ade-apigateway-vm.${rootDomainName}'
    vmssHostName: 'ade-apigateway-vmss.${rootDomainName}'
  }
]
var frontEnd = [
  {
    aksHostName: 'ade-frontEnd-aks.${rootDomainName}'
    appServiceHostName: 'ade-frontEnd-app.${rootDomainName}'
    fqdn: replace('app-${appEnvironment}-ade-frontEnd.azurewebsites.net', '-', '')
    hostName: 'ade-frontEnd.${rootDomainName}'
    vmHostName: 'ade-frontEnd-vm.${rootDomainName}'
    vmssHostName: 'ade-frontEnd-vmss.${rootDomainName}'
  }
]
var inspectorGadget = [
  {
    appServiceHostName: 'inspectorgadget.${rootDomainName}'
    fqdn: replace('app-${appEnvironment}-inspectorgadget.azurewebsites.net', '-', '')
    wafPolicyName: 'waf-${appEnvironment}-inspectorgadget'
    wafPolicyRuleName: 'waf-policy-${appEnvironment}-inspectorgadget'
  }
]
var virtualMachines = [
  {
    nicName: 'nic-${appEnvironment}-adeweb01'
  }
  {
    nicName: 'nic-${appEnvironment}-adeweb02'
  }
  {
    nicName: 'nic-${appEnvironment}-adeweb03'
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

// Existing Resource - Storage Account - Diagnostics
//////////////////////////////////////////////////
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  scope: resourceGroup(managementResourceGroupName)
  name: replace('sa-${appEnvironment}-diags', '-', '')
}

// Existing Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: 'id-${appEnvironment}-applicationgateway'
}

// Existing Resource - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-001'
  resource applicationGatewaySubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-applicationGateway'
  }
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'vnet-${appEnvironment}-002'
  resource adeWebVmssSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeweb-vmss'
  }
  resource adeWebVmSubnet 'subnets@2020-07-01' existing = {
    name: 'snet-${appEnvironment}-adeweb-vm'
  }  
}

// Module - Application Gateway
//////////////////////////////////////////////////
module applicationGatewayModule 'azure_application_gateway.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'applicationGatewayDeployment'
  params: {
    apiGateway: apiGateway
    frontEnd: frontEnd
    applicationGatewayManagedIdentityId: applicationGatewayManagedIdentity.id
    applicationGatewayName: applicationGatewayName
    applicationGatewayPublicIpAddressName: applicationGatewayPublicIpAddressName
    applicationGatewaySubnetId: virtualNetwork001::applicationGatewaySubnet.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    inspectorGadget: inspectorGadget
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sslCertificateData: keyVault.getSecret('certificate')
    sslCertificateDataPassword: sslCertificateDataPassword
    sslCertificateName: sslCertificateName
  }
}

// Module - Network Interface Update -  Virtual Machines
//////////////////////////////////////////////////
module adeWebVmNICUpdateModule 'virtual_machine_nic_update.bicep' = {
  scope: resourceGroup(virtualMachineResourceGroupName)
  name: 'adeWebVmNICUpdateDeployment'
  params: {
    adeAppApiGatewayBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayBackendPoolId
    adeAppApiGatewayVmBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayVmBackendPoolId
    adeAppFrontendBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendBackendPoolId
    adeAppFrontendVmBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendVmBackendPoolId
    virtualMachines: virtualMachines
    adeWebVmSubnetId: virtualNetwork002::adeWebVmSubnet.id
    diagnosticsStorageAccountId: diagnosticsStorageAccount.id
    eventHubNamespaceAuthorizationRuleId: eventHubNamespaceAuthorizationRule.id
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    tags: tags
  }
}

// Module - Network Interface Update -  Web Vmss
//////////////////////////////////////////////////
module adeWebVmssNICUpdateModule './azure_virtual_machine_adeweb_vmss_nic_update.bicep' = {
  scope: resourceGroup(virtualMachineResourceGroupName)
  name: 'adeWebVmssNICUpdateDeployment'
  params: {
    adeAppApiGatewayBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayBackendPoolId
    adeAppApiGatewayVmssBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayVmssBackendPoolId
    adeAppFrontendBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendBackendPoolId
    adeAppFrontendVmssBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendVmssBackendPoolId
    adeAppVmssLoadBalancerPrivateIpAddress: adeAppVmssLoadBalancerPrivateIpAddress
    adeWebModuleName: adeWebModuleName
    adeWebVmssName: adeWebVmssName
    adeWebVmssNICName: adeWebVmssNICName
    adeWebVmssSubnetId: virtualNetwork002::adeWebVmssSubnet.id
    adminPassword: keyVault.getSecret('resourcePassword')
    adminUserName: adminUserName
    appConfigConnectionString: first(listKeys(appConfig.id, appConfig.apiVersion).value).connectionString
    containerRegistryName: containerRegistry.name
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    scriptsBaseUri: scriptsBaseUri
    location: location
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
  }
}

// Module - App Config - Frontend Load Balancers
//////////////////////////////////////////////////
module appConfigAppServices './azure_app_config_frontend_load_balancers.bicep' = {
  scope: resourceGroup(securityResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    adeAppApiGatewayAppServiceHostName: applicationGatewayModule.outputs.adeAppApiGatewayAppServiceHostName
    adeAppApiGatewayVmHostName: applicationGatewayModule.outputs.adeAppApiGatewayVmHostName
    appConfigName: appConfig.name
  }
}
