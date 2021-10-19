// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

@description('The name of the VMSS Load Balancer.')
param vmssLoadBalancerName string

@description('The name of the VMSS Public Ip Address')
param vmssLoadBalancerPublicIpAddressName string

@description('The name of the Virtual Machine Scale Set.')
param vmssName string

@description('The name of the VMSS NIC.')
param vmssNICName string

@description('The ID of the VMSS Subnet.')
param vmssSubnetId string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var imageReference = osType
var osType = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '16.04-LTS'
  version: 'latest'
}
var script1Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/installserver.sh'
var script2Location = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/main/deployments/azure_vmss/workserver.py'
var tags = {
  environment: 'production'
  function: 'vmss'
  costCenter: 'it'
}

// Resource - Public Ip Address - Load Balancer - Vmss
//////////////////////////////////////////////////
resource vmssLoadBalancerPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vmssLoadBalancerPublicIpAddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Basic'
  }
}

// Resource - Public Ip Address - Diagnostic Settings - Load Balancer - Vmss
//////////////////////////////////////////////////
resource vmssLoadBalancerPublicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vmssLoadBalancerPublicIpAddress
  name: '${vmssLoadBalancerPublicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Load Balancer - Vmss
//////////////////////////////////////////////////
resource vmssLoadBalancer 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: vmssLoadBalancerName
  location: location
  tags: tags
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

// Resource - Load Balancer - Diagnostic Settings - Vmss
//////////////////////////////////////////////////
resource vmssLoadBalancerDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vmssLoadBalancer
  name: '${vmssLoadBalancer.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

// Resource - Virtual Machine Scale Set - Vmss
//////////////////////////////////////////////////
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2020-12-01' = {
  name: vmssName
  location: location
  dependsOn: [
    vmssLoadBalancer
  ]
  tags: tags
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
                      id: vmssSubnetId
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
