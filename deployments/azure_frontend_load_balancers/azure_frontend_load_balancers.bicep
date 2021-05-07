// target scope
targetScope = 'subscription'

// parameters
param defaultPrimaryRegion string
param aliasRegion string
param rootDomainName string
param monitorResourceGroupName string
param networkingResourceGroupName string
param identityResourceGroupName string
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
var applicationGatewayManagedIdentityName = 'id-ade-${aliasRegion}-agw'
// resource - user assigned managed identity
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroupName)
  name: applicationGatewayManagedIdentityName
}

// module - application gateway
// variables
var applicationGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-appgw001'
var inspectorGadgetWafPolicyName = 'waf-ade-${aliasRegion}-inspectorgadget'
var applicationGatewayName = 'appgw-ade-${aliasRegion}-001'
var adeAppFrontEndAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-frontend.azurewebsites.net', '-', '')
var adeAppApiGatewayAppServiceHostName = replace('ade-frontend.${rootDomainName}', '-', '')
var adeAppApiGatewayAppServiceFqdn = replace('app-ade-${aliasRegion}-ade-apigateway.azurewebsites.net', '-', '')
var adeAppFrontEndAppServiceHostName = replace('ade-apigateway.${rootDomainName}', '-', '')
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
    inspectorGadgetWafPolicyName: inspectorGadgetWafPolicyName
    applicationGatewayName: applicationGatewayName
    adeAppFrontEndAppServiceFqdn: adeAppFrontEndAppServiceFqdn
    adeAppFrontEndAppServiceHostName: adeAppApiGatewayAppServiceHostName
    adeAppApiGatewayAppServiceFqdn: adeAppApiGatewayAppServiceFqdn
    adeAppApiGatewayAppServiceHostName: adeAppFrontEndAppServiceHostName
    applicationGatewayManagedIdentity: applicationGatewayManagedIdentity.id
  }
}
