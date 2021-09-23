// Parameters
@description('Parameter for the location of resources. Defined in azure_governance.bicep.')
param location string = resourceGroup().location

param logAnalyticsWorkspaceId string
param aksSubnetId string
param aksClusterName string
param aksNodeResourceGroupName string
param aksClusterDNSName string
param aksServiceAddressPrefix string
param aksDNSServiceIPAddress string
param aksDockerBridgeAddress string

// Variables
var environmentName = 'production'
var functionName = 'aks'
var costCenterName = 'it'

// Resource - Azure Kubernetes Service Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: aksClusterName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.19.7'
    nodeResourceGroup: aksNodeResourceGroupName
    enableRBAC: true
    dnsPrefix: aksClusterDNSName
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 1
        vmSize: 'Standard_B2s'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
        vnetSubnetID: aksSubnetId
        tags: {
          environment: environmentName
          function: functionName
          costCenter: costCenterName
        }
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: aksServiceAddressPrefix
      dnsServiceIP: aksDNSServiceIPAddress
      dockerBridgeCidr: aksDockerBridgeAddress
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: true
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}
