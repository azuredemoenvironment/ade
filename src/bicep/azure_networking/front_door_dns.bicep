// Parameters
//////////////////////////////////////////////////
@description('The name of the Dns Zone.')
param dnsZoneName string

@description('The array of Dns Cname Records.')
param dnsCnameRecords array

@description('The array of Dns Txt Records.')
param dnsTxtRecords array

// Resource - Dns Zone - Txt Record
//////////////////////////////////////////////////
resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = [for (dnsTxtRecord, i) in dnsTxtRecords: {
  name: '${dnsZoneName}/${dnsTxtRecord.name}'
  properties: {
    TTL: dnsTxtRecord.ttl
    TXTRecords: [
      {
        value: [
          dnsTxtRecord.value
        ]
      }
    ]
  }
}]

// Resource - Dns Zone -Cname Record
//////////////////////////////////////////////////
resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for (dnsCnameRecord, i) in dnsCnameRecords: {
  name: '${dnsZoneName}/${dnsCnameRecord.name}'
  properties: {
    TTL: dnsCnameRecord.ttl
    CNAMERecord: {
      cname: dnsCnameRecord.cname
    }
  }
}]
