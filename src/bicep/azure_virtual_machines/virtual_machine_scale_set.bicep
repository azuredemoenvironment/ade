// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The location for all resources.')
param location string

@description('The list of resource tags.')
param tags object

@description('The array of properties for Virtual Machine Scale Sets.')
param virtualMachineScaleSets array

// Resource - Virtual Machine Scale Set
//////////////////////////////////////////////////
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  name: virtualMachineScaleSet.name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: tags
  sku: {
    name: virtualMachineScaleSet.skuName
    tier: virtualMachineScaleSet.tier
    capacity: virtualMachineScaleSet.capacity
  }
  identity: {
    type: virtualMachineScaleSet.identityType
  }
  properties: {
    overprovision: virtualMachineScaleSet.overprovision
    upgradePolicy: {
      mode: virtualMachineScaleSet.upgradePolicyMode
    }
    singlePlacementGroup: virtualMachineScaleSet.singlePlacementGroup
    zoneBalance: virtualMachineScaleSet.zoneBalance
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: virtualMachineScaleSet.name
        adminUsername: adminUserName
        adminPassword: adminPassword
      }
      storageProfile: {
        imageReference: virtualMachineScaleSet.imageReference
        osDisk: {
          createOption: virtualMachineScaleSet.createOption
        }        
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: virtualMachineScaleSet.nicName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: virtualMachineScaleSet.subnetId
                    }
                    loadBalancerBackendAddressPools: virtualMachineScaleSet.loadBalancerBackendPoolId != null ? [
                      {
                        id: virtualMachineScaleSet.loadBalancerBackendPoolId
                      }
                    ] : null
                    applicationGatewayBackendAddressPools: virtualMachineScaleSet.applicationGatewayBackendPoolIds != null ? virtualMachineScaleSet.applicationGatewayBackendPoolIds : null
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}]

// Resource - Dependency Agent Linux
//////////////////////////////////////////////////
resource dependencyAgent 'Microsoft.Compute/virtualMachineScaleSets/extensions@2020-12-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  parent: vmss[i]
  name: 'DependencyAgentLinux'
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
resource azureMonitorAgent 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-11-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  parent: vmss[i]
  name: 'AzureMonitorLinuxAgent'
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
          'identifier-value': virtualMachineScaleSet.managedIdentityId
        }
      }
    }
  }
}]

// Resource - Data Collection Rule Association
//////////////////////////////////////////////////
resource dataCollectionRuleAssociation 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  name: 'VMInsightsDataCollectionRuleAssociation'
  scope: vmss[i]
  properties: {
    dataCollectionRuleId: virtualMachineScaleSet.dataCollectionRuleId
  }
}]

// Resource - Auto Scale Setting
//////////////////////////////////////////////////
resource vmssAutoScaleSettings 'microsoft.insights/autoscalesettings@2015-04-01' = [for (virtualMachineScaleSet, i) in virtualMachineScaleSets: {
  name: '${virtualMachineScaleSet.name}-autoscale'
  location: location
  properties: {
    name: '${virtualMachineScaleSet.name}-autoscale'
    targetResourceUri: vmss[i].id
    enabled: true
    profiles: [
      {
        name: 'Profile1'
        capacity: {
          minimum: '1'
          maximum: '10'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricResourceUri: vmss[i].id
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 50
              statistic: 'Average'
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricResourceUri: vmss[i].id
              timeGrain: 'PT1M'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
              statistic: 'Average'
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}]
