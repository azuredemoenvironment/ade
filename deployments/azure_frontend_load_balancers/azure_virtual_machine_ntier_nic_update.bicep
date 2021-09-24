// parameters
param location string
param logAnalyticsWorkspaceId string
param nTierWebSubnetId string
param nTierWeb01NICName string
param nTierWeb01PrivateIpAddress string
param nTierWeb02NICName string
param nTierWeb02PrivateIpAddress string
param nTierWeb03NICName string
param nTierWeb03PrivateIpAddress string
param nTierBackendPoolId string

// variables
var environmentName = 'production'
var functionName = 'nTier'
var costCenterName = 'it'

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
            id: nTierWebSubnetId
          }
          applicationGatewayBackendAddressPools: [
            {
              id: nTierBackendPoolId
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - diagnostic settings - ntierweb01
resource nTierWeb01NICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nTierWeb01NIC
  name: '${nTierWeb01NIC.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
            id: nTierWebSubnetId
          }
          applicationGatewayBackendAddressPools: [
            {
              id: nTierBackendPoolId
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - diagnostic settings - ntierWeb02
resource nTierWeb02NICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nTierWeb02NIC
  name: '${nTierWeb02NIC.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
            id: nTierWebSubnetId
          }
          applicationGatewayBackendAddressPools: [
            {
              id: nTierBackendPoolId
            }
          ]
        }
      }
    ]
  }
}

// resource - network interface - diagnostic settings - ntierWeb03
resource nTierWeb03NICDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = {
  scope: nTierWeb03NIC
  name: '${nTierWeb03NIC.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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
