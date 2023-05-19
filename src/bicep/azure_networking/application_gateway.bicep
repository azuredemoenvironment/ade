// Parameters
//////////////////////////////////////////////////
@description('The properties of the Application Gateway')
param applicationGatewayProperties object

@description('The ID of the Event Hub Namespace Authorization Rule.')
param eventHubNamespaceAuthorizationRuleId string

@description('The location for all resources.')
param location string

@description('The ID of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

@description('The properties of the Public IP Address')
param publicIpAddressProperties object

@description('The data of the SSL Certificate (stored in KeyVault.)')
@secure()
param sslCertificateData string

@description('The password of the SSL Certificate (stored in KeyVault.)')
param sslCertificateDataPassword string

@description('The name of the SSL Certificate (stored in KeyVault).')
param sslCertificateName string

@description('The ID of the Diagnostics Storage Account.')
param storageAccountId string

@description('The list of resource tags.')
param tags object

// Resource - Public Ip Address
//////////////////////////////////////////////////
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIpAddressProperties.name
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: publicIpAddressProperties.publicIPAllocationMethod
    publicIPAddressVersion: publicIpAddressProperties.publicIPAddressVersion
  }
  sku: {
    name: publicIpAddressProperties.sku
  }
}

// Resource - Public Ip Address - Diagnostic Settings
//////////////////////////////////////////////////
resource publicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: publicIpAddress
  name: '${publicIpAddress.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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

// Resource - Application Gateway
//////////////////////////////////////////////////
resource applicationGateway 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: applicationGatewayProperties.name
  location: location
  tags: tags
  identity: {
    type: applicationGatewayProperties.identity.type
    userAssignedIdentities: applicationGatewayProperties.identity.userAssignedIdentities
  }
  properties: { 
    backendAddressPools: applicationGatewayProperties.properties.backendAddressPools
    backendHttpSettingsCollection: applicationGatewayProperties.properties.backendHttpSettingsCollection
    frontendIPConfigurations: [
      {
        name: 'frontendIpConfiguration'
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    enableHttp2: false
    frontendPorts: applicationGatewayProperties.properties.frontendPorts
    gatewayIPConfigurations: applicationGatewayProperties.properties.gatewayIPConfigurations
    httpListeners: applicationGatewayProperties.properties.httpListeners
    probes: applicationGatewayProperties.properties.probes
    redirectConfigurations: applicationGatewayProperties.properties.redirectConfigurations
    requestRoutingRules: applicationGatewayProperties.properties.requestRoutingRules
    sku: {
      name: applicationGatewayProperties.properties.sku.name
      tier: applicationGatewayProperties.properties.sku.tier
      capacity: applicationGatewayProperties.properties.sku.capacity
    }
    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          data: sslCertificateData
          password: sslCertificateDataPassword
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: applicationGatewayProperties.properties.webApplicationFirewallConfiguration.enabled
      firewallMode: applicationGatewayProperties.properties.webApplicationFirewallConfiguration.firewallMode
      ruleSetType: applicationGatewayProperties.properties.webApplicationFirewallConfiguration.ruleSetType
      ruleSetVersion: applicationGatewayProperties.properties.webApplicationFirewallConfiguration.ruleSetVersion
    }
  }
}

// Resource - Application Gateway - Diagnostic Settings
//////////////////////////////////////////////////
resource applicationGatewayDiagnostics 'Microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: applicationGateway
  name: '${applicationGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    storageAccountId: storageAccountId
    eventHubAuthorizationRuleId: eventHubNamespaceAuthorizationRuleId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
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
