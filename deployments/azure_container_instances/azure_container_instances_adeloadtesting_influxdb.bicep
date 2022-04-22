// Parameters
//////////////////////////////////////////////////
@description('The name of the InfluxDb Container Group.')
param adeLoadTestingInfluxDbContainerGroupName string

@description('The name of the InfluxDb Container Image.')
param adeLoadTestingInfluxDbContainerImageName string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

@description('The URL of the Azure Container Registry.')
param containerRegistryURL string

@description('The location for all resources.')
param location string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'aci'
  costCenter: 'it'
}

// Resource - Azure Container Instance - Container Group - Influx Db
//////////////////////////////////////////////////
resource adeLoadTestingInfluxDbContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingInfluxDbContainerGroupName
  location: location
  tags: tags
  properties: {
    containers: [
      {
        name: adeLoadTestingInfluxDbContainerGroupName
        properties: {
          image: adeLoadTestingInfluxDbContainerImageName
          ports: [
            {
              protocol: 'TCP'
              port: 8083
            }
            {
              protocol: 'TCP'
              port: 8086
            }
            {
              protocol: 'TCP'
              port: 2003
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
      dnsNameLabel: adeLoadTestingInfluxDbContainerGroupName
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 8083
        }
        {
          protocol: 'TCP'
          port: 8086
        }
        {
          protocol: 'TCP'
          port: 2003
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
output influxFqdn string = adeLoadTestingInfluxDbContainerGroup.properties.ipAddress.fqdn
