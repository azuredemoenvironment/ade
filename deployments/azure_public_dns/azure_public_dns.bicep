// Target Scope
//////////////////////////////////////////////////
targetScope = 'subscription'

// Parameters
//////////////////////////////////////////////////
@description('The user alias and Azure region defined from user input.')
param aliasRegion string

@description('The selected Azure region for deployment.')
param azureRegion string

@description('The value for Root Domain Name.')
param rootDomainName string

// Global Variables
//////////////////////////////////////////////////
// Resource Groups
var dnsResourceGroupName = 'rg-ade-${aliasRegion}-dns'
var networkingResourceGroupName = 'rg-ade-${aliasRegion}-networking'
// Resources
var applicationGatewayPublicIpAddressName = 'pip-ade-${aliasRegion}-appgw001'
var aRecords = [
  {
    name: 'ade-frontend'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-frontend-app'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-frontend-vm'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-frontend-vmss'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway-app'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway-vm'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'ade-apigateway-vmss'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
  {
    name: 'inspectorgadget'
    ttl: 3600
    ipv4Address: applicationGatewayPublicIpAddress.properties.ipAddress
  }
]

// Existing Resource - Public IP Address - Application Gateway
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: applicationGatewayPublicIpAddressName
}

// Resource Group - DNS
//////////////////////////////////////////////////
resource dnsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: dnsResourceGroupName
  location: azureRegion
}

// Module - Public DNS Zone
//////////////////////////////////////////////////
module dnsZoneModule 'azure_public_dns_zone.bicep' = {
  scope: resourceGroup(dnsResourceGroupName)
  name: 'dnsZoneDeployment'
  dependsOn: [
    dnsResourceGroup
  ]
  params: {
    rootDomainName: rootDomainName
  }
}

// Module - Public DNS Zone - Records
//////////////////////////////////////////////////
module dnsZoneRecordsModule 'azure_public_dns_zone_records.bicep' = {
  scope: resourceGroup(dnsResourceGroupName)
  name: 'dnsZoneRecordsDeployment'
  dependsOn: [
    dnsResourceGroup
  ]
  params: {
    aRecords: aRecords
    dnsZoneName: dnsZoneModule.outputs.dnsZoneName
  }
}
