// private dns zone - azure app services
resource azureAppServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: azureAppServicePrivateDnsZoneName
}
