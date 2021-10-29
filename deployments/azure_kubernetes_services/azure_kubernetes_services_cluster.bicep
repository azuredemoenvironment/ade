// Parameters
//////////////////////////////////////////////////
@description('The DNS name of the ADE App AKS Cluster.')
param adeAppAksClusterDNSName string

@description('The name of the ADE App AKS Cluster.')
param adeAppAksClusterName string

@description('The DNS Service IP ADdress of the ADE App AKS Cluster.')
param adeAppAksDNSServiceIPAddress string

@description('The Docker Bridge Address of the ADE App AKS Cluster.')
param adeAppAksDockerBridgeAddress string

@description('The name of the ADE App AKS Cluster Node Resource Group.')
param adeAppAksNodeResourceGroupName string

@description('The Service Address Prefix of the ADE App AKS Cluster.')
param adeAppAksServiceAddressPrefix string

@description('The ID of the ADE App AKS Subnet.')
param adeAppAksSubnetId string

// TDOD: Remove after 0.5 Bicep Release
@description('The name of the ADE App AKS Subnet.')
param adeAppAksSubnetName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

// TDOD: Remove after 0.5 Bicep Release
@description('The name of the networking Resource Group.')
param networkingResourceGroupName string

// TDOD: Remove after 0.5 Bicep Release
@description('The name of Virtual Network 002.')
param virtualNetwork002Name string

// Variables
//////////////////////////////////////////////////
var networkContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'aks'
  costCenter: 'it'
}

// Existing Resource - Virtual Network - Virtual Network 002
//////////////////////////////////////////////////
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  scope: resourceGroup(networkingResourceGroupName)
  name: virtualNetwork002Name
  resource adeAppAksSubnet 'subnets@2020-07-01' existing = {
    name: adeAppAksSubnetName
  }
}

resource a 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: adeAppAksSubnetId
  name: guid(adeAppAksSubnet.id, networkContributorRoleDefinitionId, adeAppAksCluster.identity.principalId)
  dependsOn: [
    adeAppAksCluster
  ]
  properties: {
    principalId: adeAppAksCluster.identity.principalId
    roleDefinitionId: networkContributorRoleDefinitionId
  }
}

// Resource - Azure Kubernetes Service Cluster - ADE App
//////////////////////////////////////////////////
resource adeAppAksCluster 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: adeAppAksClusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.19.7'
    nodeResourceGroup: adeAppAksNodeResourceGroupName
    enableRBAC: true
    dnsPrefix: adeAppAksClusterDNSName
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
        vnetSubnetID: adeAppAksSubnetId
        tags: tags
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      serviceCidr: adeAppAksServiceAddressPrefix
      dnsServiceIP: adeAppAksDNSServiceIPAddress
      dockerBridgeCidr: adeAppAksDockerBridgeAddress
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
output adeAppAksControlPlaneFqdn string = adeAppAksCluster.properties.fqdn
