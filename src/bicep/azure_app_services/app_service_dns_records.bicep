// Parameters
//////////////////////////////////////////////////
@description('The array of Dns Zone Records.')
param appServiceDnsRecords array

// Resource - Dns Zone - Txt Record
//////////////////////////////////////////////////
resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = [for (appServiceDnsRecord, i) in appServiceDnsRecords: {
	name: '${appServiceDnsRecord.dnsZoneName}/asuid.${appServiceDnsRecord.applicationName}'
	properties: {
		TTL: 3600
		TXTRecords: [
			{
				value: [
					appServiceDnsRecord.appServiceCustomDomainVerificationId
				]
			}
		]
	}
}]

// Resource - Dns Zone -Cname Record
//////////////////////////////////////////////////
resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for (appServiceDnsRecord, i) in appServiceDnsRecords: {
	name: '${appServiceDnsRecord.dnsZoneName}/${appServiceDnsRecord.applicationName}'
	properties: {
		TTL: 3600
		CNAMERecord: {
			cname: '${appServiceDnsRecord.appServiceName}.azurewebsites.net'
		}
	}
}]
