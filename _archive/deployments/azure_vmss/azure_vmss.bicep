param location string {
  metadata: {
    description: 'Location for All Resources.'
  }
  default: resourceGroup().location
}
param vmssLoadBalancerPublicIPAddressName string {
  metadata: {
    description: 'The Name of the VMSS Public IP Address.'
  }
}
param vmssLoadBalancerName string {
  metadata: {
    description: 'The Name of the VMSS Load Balancer.'
  }
}
param vmssName string {
  metadata: {
    description: 'The Name of the Virtual Machine Scale Set.'
  }
}
param adminUsername string {
  metadata: {
    description: 'Specifies the Administrator User Name for the Virtual Machine.'
  }
}
param adminPassword string {
  metadata: {
    description: 'Specifies the Administrator Password for the Virtual Machine.'
  }
}
param vmssNICName string {
  metadata: {
    description: 'The Name of the VMSS Network Interface Card.'
  }
}
param virtualNetwork02ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 02 Resource Group.'
  }
}
param virtualNetwork02Name string {
  metadata: {
    description: 'The Name of Virtual Network 02.'
  }
}
param vmDiagnosticsStorageAccountName string {
  metadata: {
    description: 'The Name of the Virtual Machine Diagnostics Storage Account.'
  }
}
param logAnalyticsWorkspaceResourceGroupName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace Resource Group.'
  }
}
param logAnalyticsWorkspaceName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace.'
  }
}

var loadBalancerResourceID = vmssLoadBalancerName_resource.id
var frontEndIPConfigID = '${loadBalancerResourceID}/frontendIPConfigurations/loadBalancerFrontEnd'
var vmssSKU = 'Standard_B2ms'
var osType = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '16.04-LTS'
  version: 'latest'
}
var imageReference = osType
var vmssSubnetName = 'vmss'
var script1Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/installserver.sh'
var script2Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/workserver.py'
var logAnalyticsWorkspaceID = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${logAnalyticsWorkspaceResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}'
var environmentName = 'Production'
var functionName = 'VMSS'
var costCenterName = 'IT'

resource vmssLoadBalancerPublicIPAddressName_resource 'Microsoft.Network/publicIPAddresses@2018-11-01' = {
  name: vmssLoadBalancerPublicIPAddressName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  dependsOn: []
}

resource vmssLoadBalancerPublicIPAddressName_Microsoft_Insights_vmssLoadBalancerPublicIPAddressName_Diagnostics 'Microsoft.Network/publicIPAddresses/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmssLoadBalancerPublicIPAddressName}/Microsoft.Insights/${vmssLoadBalancerPublicIPAddressName}-Diagnostics'
  tags: {}
  properties: {
    name: '${vmssLoadBalancerPublicIPAddressName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'DDoSMitigationReports'
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
  dependsOn: [
    vmssLoadBalancerPublicIPAddressName_resource
  ]
}

resource vmssLoadBalancerName_resource 'Microsoft.Network/loadBalancers@2018-04-01' = {
  name: vmssLoadBalancerName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: vmssLoadBalancerPublicIPAddressName_resource.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBackendPool'
      }
    ]
    inboundNatPools: [
      {
        name: 'NATPool1'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIPConfigID
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 50000
          frontendPortRangeEnd: 50120
          backendPort: 22
        }
      }
      {
        name: 'NATPool2'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIPConfigID
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 9000
          frontendPortRangeEnd: 9120
          backendPort: 9000
        }
      }
    ]
  }
}

resource vmssLoadBalancerName_Microsoft_Insights_vmssLoadBalancerName_Diagnostics 'Microsoft.Network/loadBalancers/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmssLoadBalancerName}/Microsoft.Insights/${vmssLoadBalancerName}-Diagnostics'
  tags: {}
  properties: {
    name: '${vmssLoadBalancerName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        category: 'LoadBalancerAlertEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'LoadBalancerProbeHealthStatus'
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
  dependsOn: [
    vmssLoadBalancerName_resource
  ]
}

resource vmssName_resource 'Microsoft.Compute/virtualMachineScaleSets@2019-07-01' = {
  name: vmssName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  sku: {
    name: vmssSKU
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      storageProfile: {
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
        imageReference: imageReference
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: vmssNICName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork02ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork02Name}/subnets/${vmssSubnetName}'
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${vmssLoadBalancerName}/backendAddressPools/LoadBalancerBackendPool'
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${vmssLoadBalancerName}/inboundNatPools/NATPool1'
                      }
                      {
                        id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${vmssLoadBalancerName}/inboundNatPools/NATPool2'
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
          storageUri: 'http://${vmDiagnosticsStorageAccountName}.blob.core.windows.net'
        }
      }
      extensionProfile: {
        extensions: [
          {
            name: 'lapextension'
            properties: {
              publisher: 'Microsoft.Azure.Extensions'
              type: 'CustomScript'
              typeHandlerVersion: '2.0'
              autoUpgradeMinorVersion: true
              settings: {
                fileUris: [
                  script1Location
                  script2Location
                ]
                commandToExecute: 'bash installserver.sh'
              }
            }
          }
          {
            type: 'extensions'
            name: 'DependencyAgentLinux'
            location: location
            properties: {
              publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
              type: 'DependencyAgentLinux'
              typeHandlerVersion: '9.5'
              autoUpgradeMinorVersion: true
            }
          }
          {
            type: 'extensions'
            name: 'OMSExtension'
            location: location
            properties: {
              publisher: 'Microsoft.EnterpriseCloud.Monitoring'
              type: 'OmsAgentForLinux'
              typeHandlerVersion: '1.4'
              autoUpgradeMinorVersion: true
              settings: {
                workspaceId: reference(resourceId(logAnalyticsWorkspaceResourceGroupName, 'Microsoft.OperationalInsights/workspaces/', logAnalyticsWorkspaceName), '2015-03-20').customerId
                stopOnMultipleConnections: true
              }
              protectedSettings: {
                workspaceKey: listKeys(resourceId(logAnalyticsWorkspaceResourceGroupName, 'Microsoft.OperationalInsights/workspaces/', logAnalyticsWorkspaceName), '2015-03-20').primarySharedKey
              }
            }
          }
        ]
      }
    }
  }
  dependsOn: [
    vmssLoadBalancerName_resource
  ]
}

resource autoscalehost 'Microsoft.Insights/autoscaleSettings@2015-04-01' = {
  name: 'autoscalehost'
  location: location
  properties: {
    name: 'autoscalehost'
    targetResourceUri: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmssName}'
    enabled: true
    profiles: [
      {
        name: 'AutoscaleProfile'
        capacity: {
          minimum: '1'
          maximum: '3'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: ''
              metricResourceUri: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmssName}'
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: ''
              metricResourceUri: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmssName}'
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
        ]
      }
    ]
  }
  dependsOn: [
    vmssName_resource
  ]
}