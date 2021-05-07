param location string {
  metadata: {
    description: 'Location For All Resources.'
  }
  default: resourceGroup().location
}
param applicationGatewayPublicIPAddressName string {
  metadata: {
    description: 'The Name of the Application Gateway Public IP Address.'
  }
}
param inspectorGadgetWafPolicyName string {
  metadata: {
    description: 'The Name of the Inspector Gadget WAF Policy.'
  }
}
param applicationGatewayName string {
  metadata: {
    description: 'The Name of the Application Gateway.'
  }
}
param sslCertificateName string {
  metadata: {
    description: 'The Name of the SSL Certificate.'
  }
}
param sslCertificateData string {
  metadata: {
    description: 'The SSL Certificate Data in the Key Vault.'
  }
}
param sslCertificateDataPassword string {
  metadata: {
    description: 'The Password for the SSL Certificate Data in the Key Vault.'
  }
}
param virtualNetwork01ResourceGroupName string {
  metadata: {
    description: 'The Name of Virtual Network 01 Resource Group.'
  }
}
param virtualNetwork01Name string {
  metadata: {
    description: 'The Name of Virtual Network 01.'
  }
}
param imageResizerFQDN string {
  metadata: {
    description: 'The FQDN of the Image Resizer App Service.'
  }
}
param imageResizerHostName string {
  metadata: {
    description: 'The Host Name of Image Resizer.'
  }
}
param inspectorGadgetFQDN string {
  metadata: {
    description: 'The FQDN of the Inspector Gadget App Service.'
  }
}
param inspectorGadgetHostName string {
  metadata: {
    description: 'The Host Name of Inspector Gadget.'
  }
}
param nTierHostName string {
  metadata: {
    description: 'The Host Name of NTier.'
  }
}
param sqlToDoFQDN string {
  metadata: {
    description: 'The FQDN of the SQL ToDo App Service.'
  }
}
param sqlToDoHostName string {
  metadata: {
    description: 'The Host Name of SQL ToDo.'
  }
}
param wordPressHostName string {
  metadata: {
    description: 'The Host Name of WordPress.'
  }
}
param managedIdentityResourceGroupName string {
  metadata: {
    description: 'The Name of the Managed Identity Resource Group.'
  }
}
param managedIdentityName string {
  metadata: {
    description: 'The Name of the Managed Identity.'
  }
}
param logAnalyticsWorkspaceResourceGroupName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace Resource Group.'
  }
}
param logAnalyticsWorkspaceName string {
  metadata: {
    description: 'The Name of the Log Analytics Workspace.'
  }
}

var applicationGatewaySubnetName = 'ApplicationGatewaySubnet'
var imageResizerBackendPoolName = 'backendpool-imageresizer'
var imageResizerHealthProbeName = 'healthprobe-imageresizer'
var imageResizerHTTPSettingName = 'httpsetting-imageresizer'
var imageResizerHTTPListenerName = 'listener-http-imageresizer'
var imageResizerHTTPSListenerName = 'listener-https-imageresizer'
var imageResizerRuleName = 'routingrule-imageresizer'
var imageResizerRedirectionConfigName = 'redirectionconfig-imageresizer'
var imageResizerRedirectionRuleName = 'routingrule-redirection-imageresizer'
var inspectorGadgetBackendPoolName = 'backendpool-inspectorgadget'
var inspectorGadgetHealthProbeName = 'healthprobe-inspectorgadget'
var inspectorGadgetHTTPSettingName = 'httpsetting-inspectorgadget'
var inspectorGadgetHTTPListenerName = 'listener-http-inspectorgadget'
var inspectorGadgetHTTPSListenerName = 'listener-https-inspectorgadget'
var inspectorGadgetRuleName = 'routingrule-inspectorgadget'
var inspectorGadgetRedirectionConfigName = 'redirectionconfig-inspectorgadget'
var inspectorGadgetRedirectionRuleName = 'routingrule-redirection-inspectorgadget'
var nTierBackendPoolName = 'backendpool-ntier'
var nTierHealthProbeName = 'healthprobe-ntier'
var nTierHTTPSettingName = 'httpsetting-ntier'
var nTierHTTPListenerName = 'listener-http-ntier'
var nTierHTTPSListenerName = 'listener-https-ntier'
var nTierRuleName = 'routingrule-ntier'
var nTierRedirectionConfigName = 'redirectionconfig-ntier'
var nTierRedirectionRuleName = 'routingrule-redirection-ntier'
var nTierWeb1IPAddress = '10.102.10.4'
var nTierWeb2IPAddress = '10.102.10.5'
var sqlToDoBackendPoolName = 'backendpool-sqltodo'
var sqlToDoHealthProbeName = 'healthprobe-sqltodo'
var sqlToDoHTTPSettingName = 'httpsetting-sqltodo'
var sqlToDoHTTPListenerName = 'listener-http-sqltodo'
var sqlToDoHTTPSListenerName = 'listener-https-sqltodo'
var sqlToDoRuleName = 'routingrule-sqltodo'
var sqlToDoRedirectionConfigName = 'redirectionconfig-sqltodo'
var sqlToDoRedirectionRuleName = 'routingrule-redirection-sqltodo'
var wordPressBackendPoolName = 'backendpool-wordpress'
var wordPressHealthProbeName = 'healthprobe-wordpress'
var wordPressHTTPSettingName = 'httpsetting-wordpress'
var wordPressHTTPListenerName = 'listener-http-wordpress'
var wordPressHTTPSListenerName = 'listener-https-wordpress'
var wordPressRuleName = 'routingrule-wordpress'
var wordPressRedirectionConfigName = 'redirectionconfig-wordpress'
var wordPressRedirectionRuleName = 'routingrule-redirection-wordpress'
var wordPressContainerIPAddress = '10.103.20.5'
var applicationGatewayID = applicationGatewayName_resource.id
var userAssignedManagedIdentity = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${managedIdentityResourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
var logAnalyticsWorkspaceID = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${logAnalyticsWorkspaceResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}'
var environmentName = 'Production'
var functionName = 'Networking'
var costCenterName = 'IT'

resource applicationGatewayPublicIPAddressName_resource 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: applicationGatewayPublicIPAddressName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  dependsOn: []
}

resource applicationGatewayPublicIPAddressName_Microsoft_Insights_applicationGatewayPublicIPAddressName_Diagnostics 'Microsoft.Network/publicIPAddresses/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${applicationGatewayPublicIPAddressName}/Microsoft.Insights/${applicationGatewayPublicIPAddressName}-Diagnostics'
  tags: {}
  properties: {
    name: '${applicationGatewayPublicIPAddressName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
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
  dependsOn: [
    applicationGatewayPublicIPAddressName_resource
  ]
}

resource inspectorGadgetWafPolicyName_resource 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2020-05-01' = {
  name: inspectorGadgetWafPolicyName
  location: location
  tags: {
    Environment: 'Production'
    Function: 'Networking'
    'Cost Center': 'IT'
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
              applicationGatewayPublicIPAddressName_resource.properties.ipAddress
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

resource applicationGatewayName_resource 'Microsoft.Network/applicationGateways@2020-05-01' = {
  name: applicationGatewayName
  location: location
  tags: {
    Environment: environmentName
    Function: functionName
    'Cost Center': costCenterName
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
            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${virtualNetwork01ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetwork01Name}/subnets/${applicationGatewaySubnetName}'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIPAddressName_resource.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: imageResizerBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: imageResizerFQDN
            }
          ]
        }
      }
      {
        name: inspectorGadgetBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: inspectorGadgetFQDN
            }
          ]
        }
      }
      {
        name: nTierBackendPoolName
        properties: {
          backendAddresses: [
            {
              ipAddress: nTierWeb1IPAddress
            }
            {
              ipAddress: nTierWeb2IPAddress
            }
          ]
        }
      }
      {
        name: sqlToDoBackendPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: sqlToDoFQDN
            }
          ]
        }
      }
      {
        name: wordPressBackendPoolName
        properties: {
          backendAddresses: [
            {
              ipAddress: wordPressContainerIPAddress
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: imageResizerHealthProbeName
        properties: {
          backendHttpSettings: [
            {
              id: '${applicationGatewayID}/backendHttpSettingsCollection/${imageResizerHTTPSettingName}'
            }
          ]
          interval: 30
          minServers: 0
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
      {
        name: inspectorGadgetHealthProbeName
        properties: {
          backendHttpSettings: [
            {
              id: '${applicationGatewayID}/backendHttpSettingsCollection/${inspectorGadgetHTTPSettingName}'
            }
          ]
          interval: 30
          minServers: 0
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
      {
        name: nTierHealthProbeName
        properties: {
          backendHttpSettings: [
            {
              id: '${applicationGatewayID}/backendHttpSettingsCollection/${nTierHTTPSettingName}'
            }
          ]
          interval: 30
          minServers: 0
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
      {
        name: sqlToDoHealthProbeName
        properties: {
          backendHttpSettings: [
            {
              id: '${applicationGatewayID}/backendHttpSettingsCollection/${sqlToDoHTTPSettingName}'
            }
          ]
          interval: 30
          minServers: 0
          path: '/'
          protocol: 'Http'
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
        }
      }
      {
        name: wordPressHealthProbeName
        properties: {
          backendHttpSettings: [
            {
              id: '${applicationGatewayID}/backendHttpSettingsCollection/${wordPressHTTPSettingName}'
            }
          ]
          interval: 30
          minServers: 0
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
        name: imageResizerHTTPSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: '${applicationGatewayID}/probes/${imageResizerHealthProbeName}'
          }
        }
      }
      {
        name: inspectorGadgetHTTPSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: '${applicationGatewayID}/probes/${inspectorGadgetHealthProbeName}'
          }
        }
      }
      {
        name: nTierHTTPSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: '${applicationGatewayID}/probes/${nTierHealthProbeName}'
          }
        }
      }
      {
        name: sqlToDoHTTPSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probe: {
            id: '${applicationGatewayID}/probes/${sqlToDoHealthProbeName}'
          }
        }
      }
      {
        name: wordPressHTTPSettingName
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: false
          hostName: wordPressHostName
          probe: {
            id: '${applicationGatewayID}/probes/${wordPressHealthProbeName}'
          }
        }
      }
    ]
    httpListeners: [
      {
        name: imageResizerHTTPListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostName: imageResizerHostName
          requireServerNameIndication: false
        }
      }
      {
        name: imageResizerHTTPSListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGatewayID}/sslCertificates/${sslCertificateName}'
          }
          hostName: imageResizerHostName
          requireServerNameIndication: true
        }
      }
      {
        name: inspectorGadgetHTTPListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicyName_resource.id
          }
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostName: inspectorGadgetHostName
          requireServerNameIndication: false
        }
      }
      {
        name: inspectorGadgetHTTPSListenerName
        properties: {
          firewallPolicy: {
            id: inspectorGadgetWafPolicyName_resource.id
          }
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGatewayID}/sslCertificates/${sslCertificateName}'
          }
          hostName: inspectorGadgetHostName
          requireServerNameIndication: true
        }
      }
      {
        name: nTierHTTPListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostName: nTierHostName
          requireServerNameIndication: false
        }
      }
      {
        name: nTierHTTPSListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGatewayID}/sslCertificates/${sslCertificateName}'
          }
          hostName: nTierHostName
          requireServerNameIndication: true
        }
      }
      {
        name: sqlToDoHTTPListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostName: sqlToDoHostName
          requireServerNameIndication: false
        }
      }
      {
        name: sqlToDoHTTPSListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGatewayID}/sslCertificates/${sslCertificateName}'
          }
          hostName: sqlToDoHostName
          requireServerNameIndication: true
        }
      }
      {
        name: wordPressHTTPListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostName: wordPressHostName
          requireServerNameIndication: false
        }
      }
      {
        name: wordPressHTTPSListenerName
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGatewayID}/frontendIPConfigurations/appGatewayFrontendIP'
          }
          frontendPort: {
            id: '${applicationGatewayID}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGatewayID}/sslCertificates/${sslCertificateName}'
          }
          hostName: wordPressHostName
          requireServerNameIndication: true
        }
      }
    ]
    redirectConfigurations: [
      {
        name: imageResizerRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGatewayID}/httpListeners/${imageResizerHTTPSListenerName}'
          }
        }
      }
      {
        name: inspectorGadgetRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGatewayID}/httpListeners/${inspectorGadgetHTTPSListenerName}'
          }
        }
      }
      {
        name: nTierRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGatewayID}/httpListeners/${nTierHTTPSListenerName}'
          }
        }
      }
      {
        name: sqlToDoRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGatewayID}/httpListeners/${sqlToDoHTTPSListenerName}'
          }
        }
      }
      {
        name: wordPressRedirectionConfigName
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: '${applicationGatewayID}/httpListeners/${wordPressHTTPSListenerName}'
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: imageResizerRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${imageResizerHTTPSListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayID}/backendAddressPools/${imageResizerBackendPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayID}/backendHttpSettingsCollection/${imageResizerHTTPSettingName}'
          }
        }
      }
      {
        name: imageResizerRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${imageResizerHTTPListenerName}'
          }
          redirectConfiguration: {
            id: '${applicationGatewayID}/redirectConfigurations/${imageResizerRedirectionConfigName}'
          }
        }
      }
      {
        name: inspectorGadgetRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${inspectorGadgetHTTPSListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayID}/backendAddressPools/${inspectorGadgetBackendPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayID}/backendHttpSettingsCollection/${inspectorGadgetHTTPSettingName}'
          }
        }
      }
      {
        name: inspectorGadgetRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${inspectorGadgetHTTPListenerName}'
          }
          redirectConfiguration: {
            id: '${applicationGatewayID}/redirectConfigurations/${inspectorGadgetRedirectionConfigName}'
          }
        }
      }
      {
        name: nTierRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${nTierHTTPSListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayID}/backendAddressPools/${nTierBackendPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayID}/backendHttpSettingsCollection/${nTierHTTPSettingName}'
          }
        }
      }
      {
        name: nTierRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${nTierHTTPListenerName}'
          }
          redirectConfiguration: {
            id: '${applicationGatewayID}/redirectConfigurations/${nTierRedirectionConfigName}'
          }
        }
      }
      {
        name: sqlToDoRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${sqlToDoHTTPSListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayID}/backendAddressPools/${sqlToDoBackendPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayID}/backendHttpSettingsCollection/${sqlToDoHTTPSettingName}'
          }
        }
      }
      {
        name: sqlToDoRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${sqlToDoHTTPListenerName}'
          }
          redirectConfiguration: {
            id: '${applicationGatewayID}/redirectConfigurations/${sqlToDoRedirectionConfigName}'
          }
        }
      }
      {
        name: wordPressRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${wordPressHTTPSListenerName}'
          }
          backendAddressPool: {
            id: '${applicationGatewayID}/backendAddressPools/${wordPressBackendPoolName}'
          }
          backendHttpSettings: {
            id: '${applicationGatewayID}/backendHttpSettingsCollection/${wordPressHTTPSettingName}'
          }
        }
      }
      {
        name: wordPressRedirectionRuleName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${applicationGatewayID}/httpListeners/${wordPressHTTPListenerName}'
          }
          redirectConfiguration: {
            id: '${applicationGatewayID}/redirectConfigurations/${wordPressRedirectionConfigName}'
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
      '${userAssignedManagedIdentity}': {}
    }
  }
}

resource applicationGatewayName_Microsoft_Insights_applicationGatewayName_Diagnostics 'Microsoft.Network/applicationGateways/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${applicationGatewayName}/Microsoft.Insights/${applicationGatewayName}-Diagnostics'
  tags: {}
  properties: {
    name: '${applicationGatewayName}-Diagnostics'
    workspaceId: logAnalyticsWorkspaceID
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
  dependsOn: [
    applicationGatewayName_resource
  ]
}