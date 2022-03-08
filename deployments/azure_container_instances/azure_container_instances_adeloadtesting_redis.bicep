// Parameters
//////////////////////////////////////////////////
@description('The name of the Redis Container Group.')
param adeLoadTestingRedisContainerGroupName string

@description('The name of the Redis Container Image.')
param adeLoadTestingRedisContainerImageName string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The region location of deployment.')
param location string = resourceGroup().location

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'aci'
  costCenter: 'it'
}

// Resource - Azure Container Instance - Container Group - Redis
//////////////////////////////////////////////////
resource adeLoadTestingRedisContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingRedisContainerGroupName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: adeLoadTestingRedisContainerGroupName
        properties: {
          image: adeLoadTestingRedisContainerImageName
          ports: [
            {
              protocol: 'TCP'
              port: 6379
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: 2
              cpu: 2
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
    ipAddress: {
      dnsNameLabel: adeLoadTestingRedisContainerGroupName
      type: 'Public'
      ports: [
        {
          port: 6379
          protocol: 'TCP'
        }
      ]
    }
    imageRegistryCredentials: [
      {
        server: containerRegistryURL
        username: containerRegistryName
        password: containerRegistryPassword
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output redisFqdn string = adeLoadTestingRedisContainerGroup.properties.ipAddress.fqdn
