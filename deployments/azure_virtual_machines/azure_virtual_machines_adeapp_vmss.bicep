// Parameters
//////////////////////////////////////////////////
@description('The ID of the ADE App Vmss Load Balancer Backend Pool.')
param adeAppVmssLoadBalancerBackendPoolId string

@description('The name of the ADE App VMSS.')
param adeAppVmssName string

@description('The name of the ADE App VMSS NIC.')
param adeAppVmssNICName string

@description('The ID of the ADE App Subnet.')
param adeAppVmssSubnetId string

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
  function: 'adeAppVmss'
  costCenter: 'it'
}

// Resource - Virtual Machine Scale Set - ADE App
//////////////////////////////////////////////////
resource adeAppVmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = {
  name: adeAppVmssName
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
        computerNamePrefix: adeAppVmssName
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
            name: adeAppVmssNICName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: adeAppVmssSubnetId
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: adeAppVmssLoadBalancerBackendPoolId
                      }
                    ]
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
resource adeAppVmssAutoScaleSettings 'microsoft.insights/autoscalesettings@2015-04-01' = {
  name: '${adeAppVmss.name}-autoscale'
  location: location
  properties: {
    name: '${adeAppVmss.name}-autoscale'
    targetResourceUri: adeAppVmss.id
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
              metricResourceUri: adeAppVmss.id
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
              metricResourceUri: adeAppVmss.id
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
