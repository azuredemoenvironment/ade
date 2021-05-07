// parameters
param location string
param logAnalyticsWorkspaceId string
param sslCertificateName string
param sslCertificateData string
param sslCertificateDataPassword string
param applicationGatewaySubnetId string
param applicationGatewayPublicIpAddressName string
param inspectorGadgetWafPolicyName string
param applicationGatewayName string
param adeAppFrontEndAppServiceFqdn string
param adeAppFrontEndAppServiceHostName string
param adeAppApiGatewayAppServiceFqdn string
param adeAppApiGatewayAppServiceHostName string
param applicationGatewayManagedIdentity string

// variables
var applicationGatewayFrontendIPConfigurationName = 'applicationGatewayFrontendIPConfiguration'
var applicationGatewayFrontendPortHttp = 'port_80'
var applicationGatewayFrontendPortHttps = 'port_443'

var adeAppFrontEndAppServiceBackendPoolName = 'backendPool-ade-frontend'
var adeAppFrontEndAppServiceProbeName = 'probe-ade-frontend'
var adeAppFrontEndAppServiceHttpSettingName = 'httpsetting-ade-frontend'
var adeAppFrontEndAppServiceHttpListenerName = 'listener-http-ade-frontend'
var adeAppFrontEndAppServiceHttpsListenerName = 'listener-https-ade-frontend'
var adeAppFrontEndAppServiceRedirectionConfigName = 'redirectionconfig-ade-frontend'
var adeAppFrontEndAppServiceRuleName = 'routingrule-ade-frontend'
var adeAppFrontEndAppServiceRedirectionRuleName = 'routingrule-redirection--ade-frontend'

var adeAppApiGatewayAppServiceBackendPoolName = 'backendPool-ade-apigateway'
var adeAppApiGatewayAppServiceProbeName = 'probe-ade-apigateway'
var adeAppApiGatewayAppServiceHttpSettingName = 'httpsetting-ade-apigateway'
var adeAppApiGatewayAppServiceHttpListenerName = 'listener-http-ade-apigateway'
var adeAppApiGatewayAppServiceHttpsListenerName = 'listener-https-ade-apigateway'
var adeAppApiGatewayAppServiceRedirectionConfigName = 'redirectionconfig-ade-apigateway'
var adeAppApiGatewayAppServiceRuleName = 'routingrule-ade-apigateway'
var adeAppApiGatewayAppServiceRedirectionRuleName = 'routingrule-redirection--ade-apigateway'

// variables
var environmentName = 'production'
var functionName = 'networking'
var costCenterName = 'it'

// resource - public ip address - application gateway
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: applicationGatewayPublicIpAddressName
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
    name: 'Standard'
  }
}

// resource - public ip address - diagnostic settings - application gateway
resource applicationGatewayPublicIpAddressDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: applicationGatewayPublicIpAddress
  name: '${applicationGatewayPublicIpAddress.name}-diagnostics'
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

// resource - waf policy - inspector gadget
resource inspectorGadgetWafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-11-01' = {
  name: inspectorGadgetWafPolicyName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    customRules: [
      {
        name: 'inspectorgadget'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              applicationGatewayPublicIpAddress.properties.ipAddress
            ]
            transforms: []
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Detection'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.0'
          ruleGroupOverrides: []
        }
      ]
      exclusions: []
    }
  }
}

// resource - application gateway
resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  tags: {
    environment: environmentName
    function: functionName
    costCenter: costCenterName
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    enableHttp2: false
    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          data: sslCertificateData
          password: sslCertificateDataPassword
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIPConfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: applicationGatewayFrontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGatewayFrontendPortHttp
        properties: {
          port: 80
        }
      }
      {
        name: applicationGatewayFrontendPortHttps
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: adeAppFrontEndAppServiceBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppFrontEndAppServiceFqdn
            }
          ]
        }
      }
      {
        name: adeAppApiGatewayAppServiceBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: adeAppApiGatewayAppServiceFqdn
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: adeAppFrontEndAppServiceProbeName
        properties: {
          interval: 30
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
      {
        name: adeAppApiGatewayAppServiceProbeName
        properties: {
          interval: 30
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: adeAppFrontEndAppServiceHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppFrontEndAppServiceProbeName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, adeAppApiGatewayAppServiceProbeName)
          }
        }
      }
    ]
    httpListeners: [
      {
        name: adeAppFrontEndAppServiceHttpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: adeAppFrontEndAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppFrontEndAppServiceHttpsListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: adeAppFrontEndAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttp)
          }
          protocol: 'Http'
          hostName: adeAppApiGatewayAppServiceHostName
          requireServerNameIndication: false
        }
      }
      {
        name: adeAppApiGatewayAppServiceHttpsListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, applicationGatewayFrontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, applicationGatewayFrontendPortHttps)
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, sslCertificateName)
          }
          hostName: adeAppApiGatewayAppServiceHostName
          requireServerNameIndication: false
        }
      }
    ]
    redirectConfigurations: [
      {
        name: adeAppFrontEndAppServiceRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpsListenerName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpsListenerName)
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: adeAppFrontEndAppServiceRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppFrontEndAppServiceBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppFrontEndAppServiceHttpSettingName)
          }
        }
      }
      {
        name: adeAppFrontEndAppServiceRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppFrontEndAppServiceHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppFrontEndAppServiceRedirectionConfigName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpsListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, adeAppApiGatewayAppServiceBackendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, adeAppApiGatewayAppServiceHttpSettingName)
          }
        }
      }
      {
        name: adeAppApiGatewayAppServiceRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, adeAppApiGatewayAppServiceHttpListenerName)
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, adeAppApiGatewayAppServiceRedirectionConfigName)
          }
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayManagedIdentity}': {}
    }
  }
}

// resource - application gateway - diagnostic settings
resource applicationGatewayDiagnostics 'Microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  scope: applicationGateway
  name: '${applicationGateway.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'ApplicationGatewayFirewallLog'
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
