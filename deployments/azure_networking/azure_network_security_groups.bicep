// parameters
param location string = resourceGroup().location
param aliasRegion string
param sourceAddressPrefix string

// variables
var azureBastionSubnetNSGName = 'nsg-ade-${aliasRegion}-azurebastion'
var managementSubnetNSGName = 'nsg-ade-${aliasRegion}-management'
var directoryServicesSubnetNSGName = 'nsg-ade-${aliasRegion}-directoryservices'
var developerSubnetNSGName = 'nsg-ade-${aliasRegion}-developer'
var nTierWebSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierweb'
var nTierDBSubnetNSGName = 'nsg-ade-${aliasRegion}-ntierdb'
var vmssSubnetNSGName = 'nsg-ade-${aliasRegion}-vmss'
var clientServicesSubnetNSGName = 'nsg-ade-${aliasRegion}-clientservices'
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// existing resources
// log analytics
param logAnalyticsWorkspaceResourceGroupName string
param logAnalyticsWorkspaceName string
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
}

// resource - network security group - azure bastion subnet
resource azureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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

// resource - network security group - azure bastion subnet - diagnostic settings
resource azureBastionSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${azureBastionSubnetNSG.name}-diagnostics'
  scope: azureBastionSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
resource managementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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

// resource - network security group - management subnet - diagnostic settings
resource managementSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${managementSubnetNSG.name}-diagnostics'
  scope: managementSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// resource - network security group - directory services subnet
resource directoryServicesSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: directoryServicesSubnetNSGName
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

// resource - network security group - directory services subnet - diagnostic settings
resource directoryServicesNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${directoryServicesSubnetNSG.name}-diagnostics'
  scope: directoryServicesSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// resource - network security group - developer subnet
resource developerSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: developerSubnetNSGName
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

// resource - network security group - developer subnet - diagnostic settings
resource developerSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${developerSubnetNSG.name}-diagnostics'
  scope: developerSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
resource nTierWebSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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

// resource - network security group - ntier web subnet - diagnostic settings
resource nTierWebSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierWebSubnetNSG.name}-diagnostics'
  scope: nTierWebSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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

// resource - network security group - ntier db subnet
resource nTierDBSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nTierDBSubnetNSGName
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

// resource - network security group - ntier db subnet - diagnostic settings
resource nTierDBSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${nTierDBSubnetNSG.name}-diagnostics'
  scope: nTierDBSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
resource vmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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

// resource - network security group - vmss subnet - diagnostic settings
resource vmssSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${vmssSubnetNSG.name}-diagnostics'
  scope: vmssSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
resource clientServicesSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
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

// resource - network security group - client services subnet - diagnostic settings
resource clientServicesSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${clientServicesSubnetNSG.name}-diagnostics'
  scope: clientServicesSubnetNSG
  properties: {
    workspaceId: logAnalyticsWorkspace.id
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
output directoryServicesSubnetNSGId string = directoryServicesSubnetNSG.id
output developerSubnetNSGId string = managementSubnetNSG.id
output nTierWebSubnetNSGId string = managementSubnetNSG.id
output nTierDBSubnetNSGId string = managementSubnetNSG.id
output vmssSubnetNSGId string = managementSubnetNSG.id
output clientServicesSubnetNSGId string = managementSubnetNSG.id