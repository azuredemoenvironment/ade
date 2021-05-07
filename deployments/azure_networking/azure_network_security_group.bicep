// parameters
param location string
param sourceAddressPrefix string
param logAnalyticsWorkspaceId string
param azureBastionSubnetNSGName string
param managementSubnetNSGName string
param nTierWebSubnetNSGName string
param nTierAppSubnetNSGName string
param vmssSubnetNSGName string
param clientServicesSubnetNSGName string

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - network security group - azure bastion subnet
resource azureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: azureBastionSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: [
      {
        name: 'HTTPS_Inbound'
        properties: {
          description: 'Allow HTTPS Access from Current Location'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Gateway_Manager_Inbound'
        properties: {
          description: 'Allow Gateway Manager Access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH_RDP_Outbound'
        properties: {
          description: 'Allow SSH and RDP Outbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Azure_Cloud_Outbound'
        properties: {
          description: 'Allow Azure Cloud Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
        }
      }
    ]
  }
}

// resource - network security group - diagnostic settings - azure bastion subnet 
resource azureBastionSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: azureBastionSubnetNSG
  name: '${azureBastionSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - network security group - management subnet
resource managementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: managementSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: [
      {
        name: 'RDP_Inbound'
        properties: {
          description: 'Allow RDP Access from Current Location'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// resource - network security group - diagnostic settings - azure bastion subnet
resource managementSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: managementSubnetNSG
  name: '${managementSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - network security group - ntier web subnet
resource nTierWebSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: nTierWebSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: []
  }
}

// resource - network security group - diagnostic settings - ntier web subnet
resource nTierWebSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nTierWebSubnetNSG
  name: '${nTierWebSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - network security group - ntier app subnet
resource nTierAppSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: nTierAppSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: []
  }
}

// resource - network security group - diagnostic settings - ntier app subnet
resource nTierAppSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: nTierAppSubnetNSG
  name: '${nTierAppSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - network security group - vmss subnet
resource vmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: vmssSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: [
      {
        name: 'HTTP_Inbound'
        properties: {
          description: 'Allow HTTP Inbound Over Port 9000'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9000'
          sourceAddressPrefix: sourceAddressPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// resource - network security group - diagnostic settings - vmss subnet
resource vmssSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: vmssSubnetNSG
  name: '${vmssSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// resource - network security group - client services subnet
resource clientServicesSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: clientServicesSubnetNSGName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    securityRules: []
  }
}

// resource - network security group - diagnostic settings - client services subnet
resource clientServicesSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: clientServicesSubnetNSG
  name: '${clientServicesSubnetNSG.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// outputs
output azureBastionSubnetNSGId string = azureBastionSubnetNSG.id
output managementSubnetNSGId string = managementSubnetNSG.id
output nTierWebSubnetNSGId string = nTierWebSubnetNSG.id
output nTierAppSubnetNSGId string = nTierAppSubnetNSG.id
output vmssSubnetNSGId string = vmssSubnetNSG.id
output clientServicesSubnetNSGId string = clientServicesSubnetNSG.id
