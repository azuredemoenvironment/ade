// parameters
param defaultPrimaryRegion string
param containerRegistryLoginServer string
@secure()
param containerRegistryLoginUserName string
@secure()
param containerRegistryLoginPassword string
param adeLoadTestingInfluxDBContainerGroupName string
param adeLoadTestingInfluxDBContainerImageName string

// variables
var environmentName = 'production'
var functionName = 'aci'
var costCenterName = 'it'

// resource - azure container instance - container group - adeLoadTestingInfluxDB
resource adeLoadTestingInfluxDBContainerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: adeLoadTestingInfluxDBContainerGroupName
  location: defaultPrimaryRegion
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    containers: [
      {
        name: adeLoadTestingInfluxDBContainerGroupName
        properties: {
          image: adeLoadTestingInfluxDBContainerImageName
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
      dnsNameLabel: adeLoadTestingInfluxDBContainerGroupName
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
        server: containerRegistryLoginServer
        username: containerRegistryLoginUserName
        password: containerRegistryLoginPassword
      }
    ]
  }
}

// outputs
output influxFqdn string = adeLoadTestingInfluxDBContainerGroup.properties.ipAddress.fqdn
