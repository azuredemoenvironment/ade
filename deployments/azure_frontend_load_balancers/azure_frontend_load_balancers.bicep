// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The name of the admin user.')
param adminUserName string

@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The value for Root Domain Name.')
param rootDomainName string

@description('The name of the SSL Certificate.')
param sslCertificateName string

@description('The base URI for deployment scripts.')
param deploymentScriptsBaseUri string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var adeAppVmResourceGroupName = 'rg-ade-${aliasRegion}-adeappvm'
var adeAppVmssResourceGroupName = 'rg-ade-${aliasRegion}-adeappvmss'
var appConfigResourceGroupName = 'rg-ade-${aliasRegion}-appconfig'
var containerRegistryResourceGroupName = 'rg-ade-${aliasRegion}-containerregistry'
var identityResourceGroupName = 'rg-ade-${aliasRegion}-identity'
var keyVaultResourceGroupName = 'rg-ade-${aliasRegion}-keyvault'
var monitorResourceGroupName = 'rg-ade-${aliasRegion}-monitor'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var adeAppApiGatewayAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-apigateway.azurewebsites.net', '-', '')
var adeAppApiGatewayAppServiceHostName = 'ade-apigateway-app.${rootDomainName}'
var adeAppApiGatewayHostName = 'ade-apigateway.${rootDomainName}'
var adeAppApiGatewayVmHostName = 'ade-apigateway-vm.${rootDomainName}'
var adeAppApiGatewayVmssHostName = 'ade-apigateway-vmss.${rootDomainName}'
var adeAppFrontendAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-frontend.azurewebsites.net', '-', '')
var adeAppFrontendAppServiceHostName = 'ade-frontend-app.${rootDomainName}'
var adeAppFrontendHostName = 'ade-frontend.${rootDomainName}'
var adeAppFrontendVmHostName = 'ade-frontend-vm.${rootDomainName}'
var adeAppFrontendVmssHostName = 'ade-frontend-vmss.${rootDomainName}'
var adeAppVmssLoadBalancerPrivateIpAddress = '10.102.12.4'
var adeWebModuleName = 'frontend'
var adeWebVirtualMachines = [
  {
    nicName: adeWebVm01NICName
  }
  {
    nicName: adeWebVm02NICName
  }
  {
    nicName: adeWebVm03NICName
  }
]
var adeWebVm01NICName = 'nic-ade-${aliasRegion}-adeweb01'
var adeWebVm02NICName = 'nic-ade-${aliasRegion}-adeweb02'
var adeWebVm03NICName = 'nic-ade-${aliasRegion}-adeweb03'
var adeWebVmssName = 'vmss-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssNICName = 'nic-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmssSubnetName = 'snet-ade-${aliasRegion}-adeweb-vmss'
var adeWebVmSubnetName = 'snet-ade-${aliasRegion}-adeweb-vm'
var appConfigName = 'appcs-ade-${aliasRegion}-001'
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-applicationgateway'
var applicationGatewayName = 'appgw-ade-${aliasRegion}-001'
var applicationGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-appgw001'
var applicationGatewaySubnetName = 'snet-ade-${aliasRegion}-applicationGateway'
var containerRegistryName = replace('acr-ade-${aliasRegion}-001', '-', '')
var inspectorGadgetAppServiceFqdn = replace('app-ade-${aliasRegion}-inspectorgadget.azurewebsites.net', '-', '')
var inspectorGadgetAppServiceHostName = 'inspectorgadget.${rootDomainName}'
var inspectorGadgetAppServiceWafPolicyName = 'waf-ade-${aliasRegion}-inspectorgadget'
var inspectorGadgetAppServiceWafPolicyRuleName = 'waf-policy-ade-${aliasRegion}-inspectorgadget'
var keyVaultName = 'kv-ade-${aliasRegion}-001'
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
var sslCertificateDataPassword = ''
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'

// Existing Resource - App Config
//////////////////////////////////////////////////
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-07-01-preview' existing = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: appConfigName
}

// Resource - Container Registry
//////////////////////////////////////////////////
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
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

// Existing Resource - Managed Identity
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// Existing Resource - Virtual Network - Virtual Network 001
//////////////////////////////////////////////////
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork001Name
  resource applicationGatewaySubnet 'subnets@2020-07-01' existing = {
    name: applicationGatewaySubnetName
  }
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource adeWebVmSubnet 'subnets@2020-07-01' existing = {
    name: adeWebVmSubnetName
  }
  resource adeWebVmssSubnet 'subnets@2020-07-01' existing = {
    name: adeWebVmssSubnetName
  }
}

// Module - Application Gateway
//////////////////////////////////////////////////
module applicationGatewayModule 'azure_application_gateway.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'applicationGatewayDeployment'
  params: {
    adeAppApiGatewayAppServiceFqdn: adeAppApiGatewayAppServiceFqdn
    adeAppApiGatewayAppServiceHostName: adeAppApiGatewayAppServiceHostName
    adeAppApiGatewayHostName: adeAppApiGatewayHostName
    adeAppApiGatewayVmHostName: adeAppApiGatewayVmHostName
    adeAppApiGatewayVmssHostName: adeAppApiGatewayVmssHostName
    adeAppFrontendAppServiceFqdn: adeAppFrontendAppServiceFqdn
    adeAppFrontendAppServiceHostName: adeAppFrontendAppServiceHostName
    adeAppFrontendHostName: adeAppFrontendHostName
    adeAppFrontendVmHostName: adeAppFrontendVmHostName
    adeAppFrontendVmssHostName: adeAppFrontendVmssHostName
    applicationGatewayManagedIdentityId: applicationGatewayManagedIdentity.id
    applicationGatewayName: applicationGatewayName
    applicationGatewayPublicIpAddressName: applicationGatewayPublicIpAddressName
    applicationGatewaySubnetId: virtualNetwork001::applicationGatewaySubnet.id
    inspectorGadgetAppServiceFqdn: inspectorGadgetAppServiceFqdn
    inspectorGadgetAppServiceHostName: inspectorGadgetAppServiceHostName
    inspectorGadgetAppServiceWafPolicyName: inspectorGadgetAppServiceWafPolicyName
    inspectorGadgetAppServiceWafPolicyRuleName: inspectorGadgetAppServiceWafPolicyRuleName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sslCertificateData: keyVault.getSecret('certificate')
    sslCertificateDataPassword: sslCertificateDataPassword
    sslCertificateName: sslCertificateName
  }
}

// Module - Network Interface Update - ADE Web Vm
//////////////////////////////////////////////////
module adeWebVmNICUpdateModule './azure_virtual_machine_adeweb_vm_nic_update.bicep' = {
  scope: resourceGroup(adeAppVmResourceGroupName)
  name: 'adeWebVmNICUpdateDeployment'
  params: {
    adeAppApiGatewayBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayBackendPoolId
    adeAppApiGatewayVmBackendPoolId: applicationGatewayModule.outputs.adeAppApiGatewayVmBackendPoolId
    adeAppFrontendBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendBackendPoolId
    adeAppFrontendVmBackendPoolId: applicationGatewayModule.outputs.adeAppFrontendVmBackendPoolId
    adeWebVirtualMachines: adeWebVirtualMachines
    adeWebVmSubnetId: virtualNetwork002::adeWebVmSubnet.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

// Module - Network Interface Update - ADE Web Vmss
//////////////////////////////////////////////////
module adeWebVmssNICUpdateModule './azure_virtual_machine_adeweb_vmss_nic_update.bicep' = {
  scope: resourceGroup(adeAppVmssResourceGroupName)
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
    containerRegistryName: containerRegistryName
    containerRegistryPassword: first(listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords).value
    deploymentScriptsBaseUri: deploymentScriptsBaseUri
    logAnalyticsWorkspaceCustomerId: logAnalyticsWorkspace.properties.customerId
    logAnalyticsWorkspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey,
  }
}

// Module - App Config - Frontend Load Balancers
//////////////////////////////////////////////////
module appConfigAppServices './azure_app_config_frontend_load_balancers.bicep' = {
  scope: resourceGroup(appConfigResourceGroupName)
  name: 'azureAppServicesAdeAppConfigDeployment'
  params: {
    adeAppApiGatewayAppServiceHostName: applicationGatewayModule.outputs.adeAppApiGatewayAppServiceHostName
    adeAppApiGatewayVmHostName: applicationGatewayModule.outputs.adeAppApiGatewayVmHostName
    appConfigName: appConfigName
  }
}
