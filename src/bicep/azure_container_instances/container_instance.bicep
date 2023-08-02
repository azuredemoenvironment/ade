// Parameters
//////////////////////////////////////////////////
@description('The properties of the Container Group.')
param containerGroupProperties object

@description('The location for all resources.')
param location string

@description('The list of resource tags.')
param tags object

// Resource - Container Instance - Container Group
//////////////////////////////////////////////////
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: containerGroupProperties.name
  location: location
  tags: tags
  properties: {
    containers: containerGroupProperties.containers
    osType: containerGroupProperties.osType
    restartPolicy: containerGroupProperties.restartPolicy
    ipAddress: {
      dnsNameLabel: containerGroupProperties.dnsNameLabel
      type: containerGroupProperties.ipAddressType
      ports: containerGroupProperties.ports
    }
    imageRegistryCredentials: containerGroupProperties.imageRegistryCredentials
  }
}

// Outputs
//////////////////////////////////////////////////
// Outputs
//////////////////////////////////////////////////
output containerGroupFqdn string = containerGroup.properties.ipAddress.fqdn
