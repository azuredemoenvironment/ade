// Parameters
//////////////////////////////////////////////////
@description('The array of properties for the DNS Zone A Records.')
param aRecords array

@description('The name of the DNS Zone.')
param dnsZoneName string

// Resource - DNS Zone A Records
//////////////////////////////////////////////////
resource dnsZoneARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = [for aRecord in aRecords: {
  name: '${dnsZoneName}/${aRecord.name}'
  properties: {
    TTL: aRecord.ttl
    ARecords: [
      {
        ipv4Address: aRecord.ipv4Address
      }
    ]
  }
}]
