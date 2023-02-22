// Parameters
//////////////////////////////////////////////////
@description('The DNS name of the  App Aks Cluster.')
param aksClusterDNSName string

@description('The name of the  App Aks Cluster.')
param aksClusterName string

@description('The DNS Service IP ADdress of the  App Aks Cluster.')
param aksDNSServiceIPAddress string

@description('The Docker Bridge Address of the  App Aks Cluster.')
param aksDockerBridgeAddress string

@description('The name of the  App Aks Cluster Node Resource Group.')
param aksNodeResourceGroupName string

@description('The Service Address Prefix of the  App Aks Cluster.')
param aksServiceAddressPrefix string

@description('The ID of the  App Aks Subnet.')
param aksSubnetId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of Resource tags')
param tags object

// Resource - Azure Kubernetes Service Cluster -  App
//////////////////////////////////////////////////
resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  name: aksClusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.23.12'
    nodeResourceGroup: aksNodeResourceGroupName
    enableRBAC: true
    dnsPrefix: aksClusterDNSName
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 3
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_B2s'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        vnetSubnetID: aksSubnetId
        tags: tags
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: aksServiceAddressPrefix
      dnsServiceIP: aksDNSServiceIPAddress
      dockerBridgeCidr: aksDockerBridgeAddress
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

// Resource - Azure Kubernetes Service Cluster -  App - Diagnostic Settings
//////////////////////////////////////////////////
resource aksClusterDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: aksCluster
  name: '${aksCluster.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'kube-apiserver'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'kube-audit'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'kube-controller-manager'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'kube-scheduler'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output aksClusterKubeletIdentityId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
output aksClusterPrincipalId string = aksCluster.identity.principalId
output aksControlPlaneFqdn string = aksCluster.properties.fqdn
