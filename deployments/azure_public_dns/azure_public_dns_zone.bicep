// Parameters
//////////////////////////////////////////////////
@description('The value for Root Domain Name.')
param rootDomainName string

@description('The region location of deployment.')
param location string = 'global'

// Variables
//////////////////////////////////////////////////

// Resource - DNS Zone
//////////////////////////////////////////////////
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: rootDomainName
  location: location
}

// Outputs
//////////////////////////////////////////////////
output dnsZoneName string = dnsZone.name
