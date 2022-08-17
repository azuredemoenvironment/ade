// Parameters
//////////////////////////////////////////////////
@description('The DNS name of the ADE App Aks Cluster.')
param adeAppAksClusterDNSName string

@description('The name of the ADE App Aks Cluster.')
param adeAppAksClusterName string

@description('The DNS Service IP ADdress of the ADE App Aks Cluster.')
param adeAppAksDNSServiceIPAddress string

@description('The Docker Bridge Address of the ADE App Aks Cluster.')
param adeAppAksDockerBridgeAddress string

@description('The name of the ADE App Aks Cluster Node Resource Group.')
param adeAppAksNodeResourceGroupName string

@description('The Service Address Prefix of the ADE App Aks Cluster.')
param adeAppAksServiceAddressPrefix string

@description('The ID of the ADE App Aks Subnet.')
param adeAppAksSubnetId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'aks'
  costCenter: 'it'
}

// Resource - Azure Kubernetes Service Cluster - ADE App
//////////////////////////////////////////////////
resource adeAppAksCluster 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  name: adeAppAksClusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.22.11'
    nodeResourceGroup: adeAppAksNodeResourceGroupName
    enableRBAC: true
    dnsPrefix: adeAppAksClusterDNSName
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
        vnetSubnetID: adeAppAksSubnetId
        tags: tags
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: adeAppAksServiceAddressPrefix
      dnsServiceIP: adeAppAksDNSServiceIPAddress
      dockerBridgeCidr: adeAppAksDockerBridgeAddress
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

// Resource - Azure Kubernetes Service Cluster - ADE App - Diagnostic Settings
//////////////////////////////////////////////////
resource adeAppAksClusterDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: adeAppAksCluster
  name: '${adeAppAksCluster.name}-diagnostics'
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
output adeAppAksClusterKubeletIdentityId string = adeAppAksCluster.properties.identityProfile.kubeletidentity.objectId
output adeAppAksClusterPrincipalId string = adeAppAksCluster.identity.principalId
output adeAppAksControlPlaneFqdn string = adeAppAksCluster.properties.fqdn
