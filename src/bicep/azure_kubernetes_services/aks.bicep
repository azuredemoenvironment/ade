// Parameters
//////////////////////////////////////////////////
@description('The properties of the Azure Kubernetes Service.')
param aksProperties object

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The list of resource tags.')
param tags object

// Resource - Azure Kubernetes Service Cluster -  App
//////////////////////////////////////////////////
resource aks 'Microsoft.ContainerService/managedClusters@2022-06-01' = {
  name: aksProperties.name
  location: location
  tags: tags
  identity: {
    type: aksProperties.identityType
  }
  properties: {
    kubernetesVersion: aksProperties.kubernetesVersion
    nodeResourceGroup: aksProperties.nodeResourceGroup
    enableRBAC: aksProperties.enableRBAC
    dnsPrefix: aksProperties.dnsPrefix
    agentPoolProfiles: aksProperties.agentPoolProfiles
    networkProfile: {
      loadBalancerSku: aksProperties.loadBalancerSku
      networkPlugin: aksProperties.networkPlugin
      serviceCidr: aksProperties.serviceCidr
      dnsServiceIP: aksProperties.dnsServiceIP
      dockerBridgeCidr: aksProperties.dockerBridgeCidr
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: aksProperties.httpApplicationRoutingEnabled
      }
      omsagent: {
        enabled: aksProperties.omsAgentEnabled
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
  }
}

// Resource - Azure Kubernetes Service Cluster -  App - Diagnostic Settings
//////////////////////////////////////////////////
resource aksDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: aks
  name: '${aks.name}-diagnostics'
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
      {
        category: 'kube-audit-admin'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'cloud-controller-manager'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'guard'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'csi-azuredisk-controller'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'csi-azurefile-controller'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'csi-snapshot-controller'
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
output aksClusterKubeletIdentityId string = aks.properties.identityProfile.kubeletidentity.objectId
output aksClusterPrincipalId string = aks.identity.principalId
output aksControlPlaneFqdn string = aks.properties.fqdn
