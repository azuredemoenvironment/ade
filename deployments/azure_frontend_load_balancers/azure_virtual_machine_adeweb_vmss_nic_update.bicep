// Parameters
//////////////////////////////////////////////////
@description('The ID of the ADE App Api Gateway Backend Pool.')
param adeAppApiGatewayBackendPoolId string

@description('The ID of the ADE App Api Gateway VMSS Backend Pool.')
param adeAppApiGatewayVmssBackendPoolId string

@description('The ID of the ADE App Frontend Backend Pool.')
param adeAppFrontendBackendPoolId string

@description('The ID of the ADE App Frontend VMSS Backend Pool.')
param adeAppFrontendVmssBackendPoolId string

@description('The private Ip address of the ADE App Vmss Load Balancer.')
param adeAppVmssLoadBalancerPrivateIpAddress string

@description('The name of the ADE Web Module.')
param adeWebModuleName string

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

@description('The connection string from the App Configuration instance.')
param appConfigConnectionString string

@description('The name of the admin user of the Azure Container Registry.')
param containerRegistryName string

@description('The password of the admin user of the Azure Container Registry.')
param containerRegistryPassword string

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
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/azure-demo-environment/dev/deployments/azure_virtual_machines_app_deployment/adeappinstall.sh'
var scriptName = 'adeappinstall.sh'
var tags = {
  environment: 'production'
  function: 'adeWebVmss'
  costCenter: 'it'
}
var timeStamp = int('${substring(sanitizeCurrentTime, 1, 2)}${substring(sanitizeCurrentTime, 3, 2)}${substring(sanitizeCurrentTime, 5, 2)}${substring(sanitizeCurrentTime, 7, 4)}')

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
                    applicationGatewayBackendAddressPools: [
                      {
                        id: adeAppApiGatewayBackendPoolId
                      }
                      {
                        id: adeAppApiGatewayVmssBackendPoolId
                      }
                      {
                        id: adeAppFrontendBackendPoolId
                      }
                      {
                        id: adeAppFrontendVmssBackendPoolId
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
          {
            name: 'lapextension'
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
                commandToExecute: './${scriptName} "${containerRegistryName}" "${containerRegistryPassword}" "${appConfigConnectionString}" "${adeWebModuleName}" "${adeAppVmssLoadBalancerPrivateIpAddress}"'
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
