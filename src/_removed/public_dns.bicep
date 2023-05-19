// Parameters
//////////////////////////////////////////////////
@description('The value for Root Domain Name.')
param rootDomainName string

// Resource - DNS Zone
//////////////////////////////////////////////////
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: rootDomainName
  location: 'global'
}

// Outputs
//////////////////////////////////////////////////
output dnsZoneName string = dnsZone.name
