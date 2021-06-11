// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param rootDomainName string
param monitorResourceGroupName string
param networkingResourceGroupName string
param identityResourceGroupName string
param nTierResourceGroupName string
param sslCertificateName string
param sslCertificateData string
param sslCertificateDataPassword string

// existing resources
// variables
var logAnalyticsWorkspaceName = 'log-ade-${aliasRegion}-001'
// resource - log analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  scope: resourceGroup(monitorResourceGroupName)
  name: logAnalyticsWorkspaceName
}
// variables
var virtualNetwork001Name = 'vnet-ade-${aliasRegion}-001'
var applicationGatewaySubnetName = 'snet-agw'
// resource - virtual network - virtual network 001
resource virtualNetwork001 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork001Name
  resource applicationGatewaySubnet 'subnets@2020-07-01' existing = {
    name: applicationGatewaySubnetName
  }
}
// variables
var virtualNetwork002Name = 'vnet-ade-${aliasRegion}-002'
var nTierWebSubnetName = 'snet-nTierWeb'
// resource - virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource nTierWebSubnet 'subnets@2020-07-01' existing = {
    name: nTierWebSubnetName
  }
}
// variables
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
// resource - user assigned managed identity
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// module - application gateway
// variables
var applicationGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-appgw001'
var inspectorGadgetAppServiceWafPolicyName = 'waf-ade-${aliasRegion}-inspectorgadget'
var applicationGatewayName = 'appgw-ade-${aliasRegion}-001'
var adeAppFrontEndAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-frontend.azurewebsites.net', '-', '')
var adeAppFrontEndAppServiceHostName = 'ade-frontend.${rootDomainName}'
var adeAppApiGatewayAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-apigateway.azurewebsites.net', '-', '')
var adeAppApiGatewayAppServiceHostName = 'ade-apigateway.${rootDomainName}'
var inspectorGadgetAppServiceFqdn = replace('app-ade-${aliasRegion}-inspectorgadget.azurewebsites.net', '-', '')
var inspectorGadgetAppServiceHostName = 'inspectorgadget.${rootDomainName}'
var nTierHostName = 'ntier.${rootDomainName}'
// module deployment
module applicationGatewayModule 'azure_application_gateway.bicep' = {
  scope: resourceGroup(networkingResourceGroupName)
  name: 'applicationGatewayDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    sslCertificateName: sslCertificateName
    sslCertificateData: sslCertificateData
    sslCertificateDataPassword: sslCertificateDataPassword
    applicationGatewaySubnetId: virtualNetwork001::applicationGatewaySubnet.id
    applicationGatewayPublicIpAddressName: applicationGatewayPublicIpAddressName
    inspectorGadgetAppServiceWafPolicyName: inspectorGadgetAppServiceWafPolicyName
    applicationGatewayName: applicationGatewayName
    adeAppFrontEndAppServiceFqdn: adeAppFrontEndAppServiceFqdn
    adeAppFrontEndAppServiceHostName: adeAppApiGatewayAppServiceHostName
    adeAppApiGatewayAppServiceFqdn: adeAppApiGatewayAppServiceFqdn
    adeAppApiGatewayAppServiceHostName: adeAppFrontEndAppServiceHostName
    inspectorGadgetAppServiceFqdn: inspectorGadgetAppServiceFqdn
    inspectorGadgetAppServiceHostName: inspectorGadgetAppServiceHostName
    nTierHostName: nTierHostName
    applicationGatewayManagedIdentity: applicationGatewayManagedIdentity.id
  }
}

// module - network interface update - ntier
// variables
var nTierWeb01NICName = 'nic-ade-${aliasRegion}-ntierweb01'
var nTierWeb01PrivateIpAddress = '10.102.1.5'
var nTierWeb02NICName = 'nic-ade-${aliasRegion}-ntierweb02'
var nTierWeb02PrivateIpAddress = '10.102.1.6'
var nTierWeb03NICName = 'nic-ade-${aliasRegion}-ntierweb03'
var nTierWeb03PrivateIpAddress = '10.102.1.7'
// module deployment
module nTierNICUpdateModule 'azure_virtual_machine_ntier_nic_update.bicep' = {
  scope: resourceGroup(nTierResourceGroupName)
  name: 'nTierNICUpdateDeployment'
  params: {
    location: defaultPrimaryRegion
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    nTierWebSubnetId: virtualNetwork002::nTierWebSubnet.id
    nTierWeb01NICName: nTierWeb01NICName
    nTierWeb01PrivateIpAddress: nTierWeb01PrivateIpAddress
    nTierWeb02NICName: nTierWeb02NICName
    nTierWeb02PrivateIpAddress: nTierWeb02PrivateIpAddress
    nTierWeb03NICName: nTierWeb03NICName
    nTierWeb03PrivateIpAddress: nTierWeb03PrivateIpAddress
    nTierBackendPoolId: applicationGatewayModule.outputs.nTierBackendPoolId
  }
}
