// Parameters
//////////////////////////////////////////////////
@description('The name of the Dns Zone.')
param dnsZoneName string

@description('The array of Dns A Records.')
param dnsARecords array

// Resource - Dns Zone - A Record
//////////////////////////////////////////////////
resource aRecord 'Microsoft.Network/dnsZones/A@2018-05-01' = [for (dnsARecord, i) in dnsARecords: {
  name: '${dnsZoneName}/${dnsARecord.name}'
  properties: {
    TTL: dnsARecord.ttl
    ARecords: [
      {
        ipv4Address: dnsARecord.ipv4Address
      }
    ]
  }
}]
