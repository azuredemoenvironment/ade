// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user of the Azure Container Registry.')
param acrPassword string

@description('The name of the admin user of the Azure Container Registry.')
param acrServerName string

@description('The name of the ADE App Module.')
param adeAppModuleName string

@description('The ID of the ADE App Vmss Load Balancer Backend Pool.')
param adeAppVmssLoadBalancerBackendPoolId string

@description('The private Ip address of the ADE App Vmss Load Balancer.')
param adeAppVmssLoadBalancerPrivateIpAddress string

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

@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('Function to generate the current time.')
param currentTime string = utcNow()

@description('The customer Id of the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomerId string

@description('The Workspace Key of the Log Analytics Workspace.')
param logAnalyticsWorkspaceKey string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var sanitizeCurrentTime = replace(replace(currentTime, 'Z', ''), 'T', '')
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/dev/deployments/azure_virtual_machines/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'
var tags = {
  environment: 'production'
  function: 'adeAppVmss'
  costCenter: 'it'
}
var timeStamp = int('${substring(sanitizeCurrentTime, 1, 2)}${substring(sanitizeCurrentTime, 3, 2)}${substring(sanitizeCurrentTime, 5, 2)}${substring(sanitizeCurrentTime, 7, 4)}')

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
    }
  }
}

// Resource - Auto Scale Setting
//////////////////////////////////////////////////
resource adeAppVmssAutoScaleSettings 'microsoft.insights/autoscalesettings@2015-04-01' = {
  name: 'cpuautoscale'
  location: location
  properties: {
    name: 'cpuautoscale'
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

// Resource - Dependency Agent Linux
//////////////////////////////////////////////////
resource adeAppVmssDependencyAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${adeAppVmss.name}/DependencyAgentLinux'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

// Resource - Microsoft Monitoring Agent
//////////////////////////////////////////////////
resource adeAppVmssMicrosoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${adeAppVmss.name}/OMSExtension'
  location: location
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

// Resource - Custom Script Extension - ADE App Vmss
//////////////////////////////////////////////////
resource adeAppVmssCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${adeAppVmss.name}/CustomScriptextension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      skipDos2Unix: true
      timestamp: timeStamp
    }
    protectedSettings: {
      fileUris: [
        scriptLocation
      ]
      commandToExecute: './${scriptName} "${acrServerName}" "${acrPassword}" "${appConfigConnectionString}" "${adeAppModuleName}" "${adeAppVmssLoadBalancerPrivateIpAddress}"'
    }
  }
}
