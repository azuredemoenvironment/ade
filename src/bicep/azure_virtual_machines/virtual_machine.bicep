// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The ID of the Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

@description('The array of properties for Virtual Machines.')
param virtualMachines array

// Resource - Network Interface
//////////////////////////////////////////////////
resource vmNic 'Microsoft.Network/networkInterfaces@2022-09-01' = [for (virtualMachine, i) in virtualMachines: {
  name: virtualMachine.nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: virtualMachine.privateIPAllocationMethod
          subnet: {
            id: virtualMachine.subnetId
          }
          loadBalancerBackendAddressPools: virtualMachine.loadBalancerBackendPoolId != null ? [
            {
              id: virtualMachine.loadBalancerBackendPoolId
            }
          ] : null
        }
      }
    ]
  }
}]

// Resource - Network Interface - Diagnostic Settings
//////////////////////////////////////////////////
resource adeAppVmNicDiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (virtualMachine, i) in virtualMachines: {
  scope: vmNic[i]
  name: '${virtualMachine.nicName}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 7
        }
      }
    ]
  }
}]

// Resource - Virtual Machine
//////////////////////////////////////////////////
resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = [for (virtualMachine, i) in virtualMachines: {
  name: virtualMachine.name
  location: location
  zones: [
    virtualMachine.availabilityZone
  ]
  tags: tags
  identity: {
    type: virtualMachine.identityType
  }
  properties: {
    proximityPlacementGroup: {
      id: virtualMachine.proximityPlacementGroupId
    }
    hardwareProfile: {
      vmSize: virtualMachine.vmSize
    }
    storageProfile: {
      imageReference: virtualMachine.imageReference
      osDisk: {
        osType: virtualMachine.osType
        name: virtualMachine.osDiskName
        createOption: virtualMachine.createOption
        managedDisk: {
          storageAccountType: virtualMachine.storageAccountType
        }
      }
    }
    osProfile: {
      computerName: virtualMachine.name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]

// Resource - Dependency Agent Linux
//////////////////////////////////////////////////
resource dependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for (virtualMachine, i) in virtualMachines: {
  parent: vm[i]
  name: 'DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
    settings: {
      enableAMA: 'true'
    }
  }
}]

// Resource - Azure Monitor Agent
//////////////////////////////////////////////////
resource azureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = [for (virtualMachine, i) in virtualMachines: {
  parent: vm[i]
  name: 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': virtualMachine.managedIdentityId
        }
      }
    }
  }
}]

// Resource - Data Collection Rule Association
//////////////////////////////////////////////////
resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = [for (virtualMachine, i) in virtualMachines: {
  name: 'VMInsightsDataCollectionRuleAssociation'
  scope: vm[i]
  properties: {
    dataCollectionRuleId: virtualMachine.dataCollectionRuleId
  }
}]
