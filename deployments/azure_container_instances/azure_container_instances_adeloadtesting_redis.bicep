// parameters
param azureRegion string
param containerRegistryLoginServer string
@secure()
param containerRegistryLoginUserName string
@secure()
param containerRegistryLoginPassword string
param adeLoadTestingRedisContainerGroupName string
param adeLoadTestingRedisContainerImageName string

// variables
var environmentName = 'production'
var functionName = 'aci'
var costCenterName = 'it'

// resource - azure container instance - container group - adeLoadTestingRedis
resource adeLoadTestingRedisContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingRedisContainerGroupName
  location: azureRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
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
        server: containerRegistryLoginServer
        username: containerRegistryLoginUserName
        password: containerRegistryLoginPassword
      }
    ]
  }
}

// outputs
output redisFqdn string = adeLoadTestingRedisContainerGroup.properties.ipAddress.fqdn
