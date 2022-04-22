// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE Web VMSS.')
param adeWebVmssName string

@description('The name of the ADE Web VMSS NIC.')
param adeWebVmssNICName string

@description('The ID of the ADE Web Subnet.')
param adeWebVmssSubnetId string

@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The location for all resources.')
param location string

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

// Variables
//////////////////////////////////////////////////
var tags = {
  environment: 'production'
  function: 'adeWebVmss'
  costCenter: 'it'
}

// Resource - Virtual Machine Scale Set - ADE Web
//////////////////////////////////////////////////
resource adeWebVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = {
  name: adeWebVmssName
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: tags
  sku: {
    name: 'Standard_B2ms'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    singlePlacementGroup: false
    zoneBalance: true
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: adeWebVmssName
        adminUsername: adminUserName
        adminPassword: adminPassword
      }
      storageProfile: {
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
        }
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '18.04-LTS'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: adeWebVmssNICName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: adeWebVmssSubnetId
                    }
                  }
                }
              ]
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'DependencyAgentLinux'
            properties: {
              publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
              type: 'DependencyAgentLinux'
              typeHandlerVersion: '9.5'
              autoUpgradeMinorVersion: true
            }
          }
          {
            name: 'OMSExtension'
            properties: {
              publisher: 'Microsoft.EnterpriseCloud.Monitoring'
              type: 'OmsAgentForLinux'
              typeHandlerVersion: '1.4'
              autoUpgradeMinorVersion: true
              settings: {
                workspaceId: logAnalyticsWorkspaceCustomerId
              }
              protectedSettings: {
                workspaceKey: logAnalyticsWorkspaceKey
              }
            }
          }
        ]
      }
    }
  }
}

// Resource - Auto Scale Setting
//////////////////////////////////////////////////
resource adeWebVmssAutoScaleSettings 'microsoft.insights/autoscalesettings@2015-04-01' = {
  name: '${adeWebVmss.name}-autoscale'
  location: location
  properties: {
    name: '${adeWebVmss.name}-autoscale'
    targetResourceUri: adeWebVmss.id
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
              metricNamespace: ''
              metricResourceUri: adeWebVmss.id
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
              metricNamespace: ''
              metricResourceUri: adeWebVmss.id
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
}
