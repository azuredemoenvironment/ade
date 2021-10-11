// Parameters
//////////////////////////////////////////////////
@description('The name of the Azure Basion Subnet NSG.')
param azureBastionSubnetNSGName string

@description('The name of the Client Services Subnet NSG.')
param clientServicesSubnetNSGName string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The name of the Management Subnet NSG.')
param managementSubnetNSGName string

@description('The name of the NTier App Subnet NSG.')
param nTierAppSubnetNSGName string

@description('The name of the NTier Web Subnet NSG.')
param nTierWebSubnetNSGName string

@description('The public IP address of the on-premises network.')
param sourceAddressPrefix string

@description('The name of the VMSS Subnet NSG.')
param vmssSubnetNSGName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var tags = {
  environment: 'production'
  function: 'networking'
  costCenter: 'it'
}

// Resource - Network Security Group - Azure Bastion Subnet
//////////////////////////////////////////////////
resource azureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: azureBastionSubnetNSGName
  location: location
  tags: tags
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

// Resource - Network Security Group - Diagnostic Settings - Azure Bastion Subnet
//////////////////////////////////////////////////
resource azureBastionSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Network Security Group - Management Subnet
//////////////////////////////////////////////////
resource managementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: managementSubnetNSGName
  location: location
  tags: tags
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

// Resource - Network Security Group - Diagnostic Settings - Azure Bastion Subnet
//////////////////////////////////////////////////
resource managementSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Network Security Group - Ntier Web Subnet
//////////////////////////////////////////////////
resource nTierWebSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: nTierWebSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Ntier Web Subnet
//////////////////////////////////////////////////
resource nTierWebSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Network Security Group - Ntier App Subnet
//////////////////////////////////////////////////
resource nTierAppSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: nTierAppSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Ntier App Subnet
//////////////////////////////////////////////////
resource nTierAppSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Network Security Group - Vmss Subnet
//////////////////////////////////////////////////
resource vmssSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: vmssSubnetNSGName
  location: location
  tags: tags
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

// Resource - Network Security Group - Diagnostic Settings - Vmss Subnet
//////////////////////////////////////////////////
resource vmssSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Resource - Network Security Group - Client Services Subnet
//////////////////////////////////////////////////
resource clientServicesSubnetNSG 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: clientServicesSubnetNSGName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Resource - Network Security Group - Diagnostic Settings - Client Services Subnet
//////////////////////////////////////////////////
resource clientServicesSubnetNSGDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
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

// Outputs
//////////////////////////////////////////////////
output azureBastionSubnetNSGId string = azureBastionSubnetNSG.id
output managementSubnetNSGId string = managementSubnetNSG.id
output nTierWebSubnetNSGId string = nTierWebSubnetNSG.id
output nTierAppSubnetNSGId string = nTierAppSubnetNSG.id
output vmssSubnetNSGId string = vmssSubnetNSG.id
output clientServicesSubnetNSGId string = clientServicesSubnetNSG.id
