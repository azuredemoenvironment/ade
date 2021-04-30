// parameters
param location string
param adminUserName string
param adminPassword string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork002Name string
param nTierWebSubnetName string
param nTierAppSubnetName string
param proximityPlacementGroupAz1Name string
param proximityPlacementGroupAz2Name string
param proximityPlacementGroupAz3Name string
param nTierAppLoadBalancerName string
param nTierAppLoadBalancerPrivateIpAddress string
param nTierWeb01NICName string
param nTierWeb01PrivateIpAddress string
param nTierWeb02NICName string
param nTierWeb02PrivateIpAddress string
param nTierWeb03NICName string
param nTierWeb03PrivateIpAddress string
param nTierApp01NICName string
param nTierApp01PrivateIpAddress string
param nTierApp02NICName string
param nTierApp02PrivateIpAddress string
param nTierApp03NICName string
param nTierApp03PrivateIpAddress string
param nTierWeb01Name string
param nTierWeb01OSDiskName string
param nTierWeb02Name string
param nTierWeb02OSDiskName string
param nTierWeb03Name string
param nTierWeb03OSDiskName string
param nTierApp01Name string
param nTierApp01OSDiskName string
param nTierApp02Name string
param nTierApp02OSDiskName string
param nTierApp03Name string
param nTierApp03OSDiskName string

// variables
var environmentName = 'production'
var functionName = 'nTier'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network - virtual network 002
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  name: virtualNetwork002Name
  scope: resourceGroup(networkingResourceGroupName)
  resource nTierWebSubnet 'subnets@2020-07-01' existing = {
    name: nTierWebSubnetName
  }
  resource nTierAppSubnet 'subnets@2020-07-01' existing = {
    name: nTierAppSubnetName
  }
}

// resource - proximity placement group - availability zone 1
resource proximityPlacementGroupAz1 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz1Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - proximity placement group - availability zone 2
resource proximityPlacementGroupAz2 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz2Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - proximity placement group - availability zone 3
resource proximityPlacementGroupAz3 'Microsoft.Compute/proximityPlacementGroups@2020-12-01' = {
  name: proximityPlacementGroupAz3Name
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

// resource - load balancer - ntierapp
resource nTierAppLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: nTierAppLoadBalancerName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fip-nTierApp'
        properties: {
          subnet: {
            id: virtualNetwork002::nTierAppSubnet.id
          }
          privateIPAddress: nTierAppLoadBalancerPrivateIpAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bep-nTierApp'
      }
    ]
    probes: [
      {
        name: 'probe-nTierApp'
        properties: {
          protocol: 'Https'
          requestPath: '/'
          port: 443
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbr-nTierApp'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', nTierAppLoadBalancerName, 'fip-nTierApp')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', nTierAppLoadBalancerName, 'probe-nTierApp')
          }
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}

// resource - load balancer - ntierapp - diagnostic settings
resource nTierAppLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierAppLoadBalancer.name}-diagnostics'
  scope: nTierAppLoadBalancer
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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
}

// resource - network interface - ntierweb01
resource nTierWeb01NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierWeb01NICName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierWeb01PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierWebSubnet.id
          }
        }
      }
    ]
  }
}

// resource - network interface - ntierweb01 - diagnostic settings
resource nTierWeb01NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierWeb01NIC.name}-diagnostics'
  scope: nTierWeb01NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - network interface - ntierweb02
resource nTierWeb02NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierWeb02NICName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierWeb02PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierWebSubnet.id
          }
        }
      }
    ]
  }
}

// resource - network interface - ntierWeb02 - diagnostic settings
resource nTierWeb02NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierWeb02NIC.name}-diagnostics'
  scope: nTierWeb02NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - network interface - ntierweb03
resource nTierWeb03NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierWeb03NICName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierWeb03PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierWebSubnet.id
          }
        }
      }
    ]
  }
}

// resource - network interface - ntierWeb03 - diagnostic settings
resource nTierWeb03NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierWeb03NIC.name}-diagnostics'
  scope: nTierWeb03NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - network interface - ntierapp01
resource nTierApp01NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierApp01NICName
  location: location
  dependsOn: [
    nTierAppLoadBalancer
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierApp01PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierAppSubnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - ntierapp01 - diagnostic settings
resource nTierApp01NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierApp01NIC.name}-diagnostics'
  scope: nTierApp01NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - network interface - ntierapp02
resource nTierApp02NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierApp02NICName
  location: location
  dependsOn: [
    nTierAppLoadBalancer
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierApp02PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierAppSubnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - ntierapp02 - diagnostic settings
resource nTierApp02NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierApp02NIC.name}-diagnostics'
  scope: nTierApp02NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - network interface - ntierapp03
resource nTierApp03NIC 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: nTierApp03NICName
  location: location
  dependsOn: [
    nTierAppLoadBalancer
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: nTierApp03PrivateIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: virtualNetwork002::nTierAppSubnet.id
          }
          loadBalancerBackendAddressPools: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', nTierAppLoadBalancerName, 'bep-nTierApp')
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - ntierapp03 - diagnostic settings
resource nTierApp03NICDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierApp03NIC.name}-diagnostics'
  scope: nTierApp03NIC
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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

// resource - virtual machine - ntierweb01
resource nTierWeb01 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierWeb01Name
  location: location
  zones: [
    '1'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz1.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierWeb01OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierWeb01Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierWeb01NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierweb01
resource nTierWeb01DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb01.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierweb01
resource nTierWeb01MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb01.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

// resource - virtual machine - ntierweb02
resource nTierWeb02 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierWeb02Name
  location: location
  zones: [
    '2'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz2.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierWeb02OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierWeb02Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierWeb02NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierweb02
resource nTierWeb02DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb02.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierweb02
resource nTierWeb02MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb02.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

// resource - virtual machine - ntierweb03
resource nTierWeb03 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierWeb03Name
  location: location
  zones: [
    '3'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz3.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierWeb03OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierWeb03Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierWeb03NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierweb03
resource nTierWeb03DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb03.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierweb03
resource nTierWeb03MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierWeb03.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

// resource - virtual machine - ntierapp01
resource nTierApp01 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierApp01Name
  location: location
  zones: [
    '1'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz1.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierApp01OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierApp01Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierApp01NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierapp01
resource nTierApp01DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp01.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierapp01
resource nTierApp01MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp01.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

// resource - virtual machine - ntierapp02
resource nTierApp02 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierApp02Name
  location: location
  zones: [
    '2'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz2.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierApp02OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierApp02Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierApp02NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierapp02
resource nTierApp02DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp02.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierapp02
resource nTierApp02MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp02.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}

// resource - virtual machine - ntierapp03
resource nTierApp03 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: nTierApp03Name
  location: location
  zones: [
    '3'
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    proximityPlacementGroup: {
      id: proximityPlacementGroupAz3.id
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: nTierApp03OSDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: nTierApp03Name
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nTierApp03NIC.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// resource - dependency agent linux - ntierapp03
resource nTierApp03DependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp03.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// resource - microsoft monitoring agent - ntierapp03
resource nTierApp03MicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${nTierApp03.name}/OMSExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}
