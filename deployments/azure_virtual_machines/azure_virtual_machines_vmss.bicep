// parameters
param location string
param adminUserName string
param adminPassword string
param monitorResourceGroupName string
param logAnalyticsWorkspaceName string
param networkingResourceGroupName string
param virtualNetwork002Name string
param vmssSubnetName string
param vmssLoadBalancerPublicIpAddressName string
param vmssLoadBalancerName string
param vmssName string
param vmssNICName string

// variables
var imageReference = osType
var osType = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '16.04-LTS'
  version: 'latest'
}
var script1Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/installserver.sh'
var script2Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/workserver.py'
var environmentName = 'production'
var functionName = 'vmss'
var costCenterName = 'it'

// existing resources
// log analytics
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}
// virtual network
resource virtualNetwork002 'Microsoft.Network/virtualNetworks@2020-07-01' existing = {
  name: virtualNetwork002Name
  scope: resourceGroup(networkingResourceGroupName)
  resource vmssSubnet 'subnets@2020-07-01' existing = {
    name: vmssSubnetName
  }
}

// resource - public ip address - load balancer - vmss
resource vmssLoadBalancerPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vmssLoadBalancerPublicIpAddressName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Basic'
  }
}

// resource - public ip address - load balancer - vmss - diagnostic settings
resource vmssLoadBalancerPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmssLoadBalancerPublicIpAddress.name}-diagnostics'
  scope: vmssLoadBalancerPublicIpAddress
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
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
}

// resource - load balancer - vmss
resource vmssLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: vmssLoadBalancerName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fip-vmss'
        properties: {
          publicIPAddress: {
            id: vmssLoadBalancerPublicIpAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bep-vmss'
      }
    ]
    inboundNatPools: [
      {
        name: 'natPool1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', vmssLoadBalancerName, 'fip-vmss')
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 50000
          frontendPortRangeEnd: 50120
          backendPort: 22
        }
      }
      {
        name: 'natPool2'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', vmssLoadBalancerName, 'fip-vmss')
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

// resource - load balancer - vmss - diagnostic settings
resource vmssLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmssLoadBalancer.name}-diagnostics'
  scope: vmssLoadBalancer
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

// resource - virtual machine scale set - vmss
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = {
  name: vmssName
  location: location
  dependsOn: [
    vmssLoadBalancer
  ]
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  sku: {
    name: 'Standard_B2ms'
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
        adminUsername: adminUserName
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
                      id: virtualNetwork002::vmssSubnet.id
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', vmssLoadBalancerName, 'bep-vmss')
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/inboundNatPools', vmssLoadBalancerName, 'natPool1')
                      }
                      {
                        id: resourceId('Microsoft.Network/loadBalancers/inboundNatPools', vmssLoadBalancerName, 'natPool2')
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
                workspaceId: logAnalyticsWorkspace.properties.customerId
              }
              protectedSettings: {
                workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
              }
            }
          }
        ]
      }
    }
  }
}
