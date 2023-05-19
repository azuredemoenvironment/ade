// Parameters
//////////////////////////////////////////////////
@description('The array of Front Door Custom Domains.')
param frontDoorCustomDomains array

@description('The properties of the Front Door Enpoint.')
param frontDoorEndpointProperties object

@description('The array of Front Door Origin Groups.')
param frontDoorOriginGroups array

@description('The array of Front Door Origins.')
param frontDoorOrigins array

@description('The properties of the Front Door Profile.')
param frontDoorProfileProperties object

@description('The array of Front Door Routes.')
param frontDoorRoutes array

@description('The properties of the Front Door Secret.')
@secure()
param frontDoorSecretProperties object

@description('The properties of the Security Policy.')
param securityPolicyProperties object

@description('The list of resource tags.')
param tags object

@description('The properties of the Waf Policy.')
param wafPolicyProperties object

// Resource - WAF Policy
//////////////////////////////////////////////////
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: wafPolicyProperties.name
  location: 'global'
  sku: wafPolicyProperties.sku
  properties: wafPolicyProperties.properties
}

// Resource - Front Door - Profile
//////////////////////////////////////////////////
resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: frontDoorProfileProperties.name
  location: 'global'
  tags: tags
  sku: frontDoorProfileProperties.sku
  identity: frontDoorProfileProperties.identity
}

// Resource - Front Door - Endpoint
//////////////////////////////////////////////////
resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  parent: profile
  name: frontDoorEndpointProperties.name
  location: 'global'
  properties: {
    enabledState: frontDoorEndpointProperties.enabledState
  }
}

// Resource - Front Door - Security Policy
//////////////////////////////////////////////////
resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2021-06-01' = {
  parent: profile
  name: securityPolicyProperties.name
  properties: {
    parameters: {
      type: securityPolicyProperties.type
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: endpoint.id
            }
          ]
          patternsToMatch: securityPolicyProperties.patternsToMatch
        }
      ]
    }
  }
}

// Resource - Front Door - Origin Group
//////////////////////////////////////////////////
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = [for (frontDoorOriginGroup, i) in frontDoorOriginGroups: {
  parent: profile
  name: frontDoorOriginGroup.name
  properties: {
    loadBalancingSettings: {
      sampleSize: frontDoorOriginGroup.sampleSize
      successfulSamplesRequired: frontDoorOriginGroup.successfulSamplesRequired
    }
    healthProbeSettings: {
      probePath: frontDoorOriginGroup.probePath
      probeRequestType: frontDoorOriginGroup.probeRequestType
      probeProtocol: frontDoorOriginGroup.probeProtocol
      probeIntervalInSeconds: frontDoorOriginGroup.probeIntervalInSeconds
    }
  }
}]

// Resource - Front Door - Origin
//////////////////////////////////////////////////
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [for (frontDoorOrigin, i) in frontDoorOrigins: {
  parent: originGroup[i]
  name: frontDoorOrigin.name
  properties: {
    hostName: frontDoorOrigin.hostName
    httpPort: frontDoorOrigin.httpPort
    httpsPort: frontDoorOrigin.httpsPort
    originHostHeader: frontDoorOrigin.originHostHeader
    priority: frontDoorOrigin.priority
    weight: frontDoorOrigin.weight
  }
}]

// Resource - Front Door - Secret
//////////////////////////////////////////////////
resource secret 'Microsoft.Cdn/profiles/secrets@2021-06-01' = {
  parent: profile
  name: frontDoorSecretProperties.name
  properties: {
    parameters: {
      type: frontDoorSecretProperties.type
      useLatestVersion: frontDoorSecretProperties.useLatestVersion
      secretVersion: frontDoorSecretProperties.secretVersion
      secretSource: {
        id: frontDoorSecretProperties.id
      }
    }
  }
}

// Resource - Front Door - Custom Domain
//////////////////////////////////////////////////
resource customDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = [for (frontDoorCustomDomain, i) in frontDoorCustomDomains: {
  parent: profile
  name: frontDoorCustomDomain.name
  properties: {
    hostName: frontDoorCustomDomain.hostName
    tlsSettings: {
      certificateType: frontDoorCustomDomain.certificateType
      minimumTlsVersion: frontDoorCustomDomain.minimumTlsVersion
      secret: {
        id: secret.id
      }
    }
  }
}]

// Resource - Front Door - Route
//////////////////////////////////////////////////
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = [for (frontDoorRoute, i) in frontDoorRoutes: {
  parent: endpoint
  name: frontDoorRoute.name
  dependsOn:[
    origin
    // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    customDomains: [
      {
        id: customDomain[i].id
      }
    ]
    originGroup: {
      id: originGroup[i].id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Disabled'
    httpsRedirect: 'Enabled'
  }
}]

// Outputs
//////////////////////////////////////////////////
output frontDoorCustomDomainVerificationIds array = [for (frontDoorCustomDomain, i) in frontDoorCustomDomains: {
  frontDoorCustomDomainVerificationId: customDomain[i].properties.validationProperties.validationToken
}]
output frontDoorEndpointHostName string = endpoint.properties.hostName
