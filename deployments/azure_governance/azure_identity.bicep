// Parameters
//////////////////////////////////////////////////
@description('The name of the Application Gateway Managed Identity.')
param applicationGatewayManagedIdentityName string

@description('The name of the Container Registry Managed Identity.')
param containerRegistryManagedIdentityName string

@description('The name of the Deployment Script Managed Identity.')
param deploymentScriptManagedIdentityName string

@description('The name of the Container Registry Service Principal.')
param containerRegistrySpnName string

@description('The name of the GitHub Actions Service Principal.')
param githubActionsSpnName string

@description('The name of the Rest API Service Principal.')
param restApiSpnName string

// Variables
//////////////////////////////////////////////////
var location = resourceGroup().location
var contributorRoleAssignmentName = guid(resourceGroup().id, 'contributor')
var contributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var tags = {
  environment: 'production'
  function: 'identity'
  costCenter: 'it'
}

// Resource - Managed Identity - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: applicationGatewayManagedIdentityName
  location: location
  tags: tags
}

// Resource - Managed Identity - Container Registry
//////////////////////////////////////////////////
resource containerRegistryManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: containerRegistryManagedIdentityName
  location: location
  tags: tags
}

// Resource - Managed Identity - Deployment Script
//////////////////////////////////////////////////
resource deploymentScriptManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: deploymentScriptManagedIdentityName
  location: location
  tags: tags
}

// Resource - Role Asignment - Contributor
//////////////////////////////////////////////////
resource deploymentScriptRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: contributorRoleAssignmentName
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: deploymentScriptManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Resource - Deployment Script - Service Principals
//////////////////////////////////////////////////
resource servicePrincipalsDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'servicePrincipalsDeploymentScript'
  location: location
  dependsOn: [
    deploymentScriptManagedIdentity
    deploymentScriptRoleAssignment
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${deploymentScriptManagedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.2.0'
    arguments: '-containerRegistrySpnName "${containerRegistrySpnName}" -githubActionsSpnName "${githubActionsSpnName}" -restApiSpnName "${restApiSpnName}"'
    scriptContent: '''
      param([string]$containerRegistrySpnName, [string]$githubActionsSpnName, [string]$restApiSpnName)

      $containerRegistrySpn = $(az ad sp create-for-rbac -n http://$containerRegistrySpnName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
      $containerRegistrySpnPassword = $containerRegistrySpn.password
      $containerRegistrySpnAppId = $containerRegistrySpn.appId      
      Write-Log "Pausing for 10 seconds to allow for propagation."
      Start-Sleep -Seconds 10
      $containerRegistrySpnObjectID = az ad sp show --id $containerRegistrySpn.appId --query objectId --output tsv

      $githubActionsSpn = $(az ad sp create-for-rbac -n http://$githubActionsSpnName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
      $githubActionsSpnPassword = $githubActionsSpn.password
      $githubActionsSpnAppId = $githubActionsSpn.appId      
      Write-Log "Pausing for 10 seconds to allow for propagation."
      Start-Sleep -Seconds 10
      $githubActionsSpnObjectID = az ad sp show --id $githubActionsSpn.appId --query objectId --output tsv

      $restApiSpn = $(az ad sp create-for-rbac -n http://$restApiSpnName --skip-assignment true --role acrpull --output json) | ConvertFrom-Json
      $restApiSpnPassword = $restApiSpn.password
      $restApiSpnAppId = $restApiSpn.appId      
      Write-Log "Pausing for 10 seconds to allow for propagation."
      Start-Sleep -Seconds 10
      $restApiSpnObjectID = az ad sp show --id $restApiSpn.appId --query objectId --output tsv

      $DeploymentScriptOutputs= @{}      
      $DeploymentScriptOutputs['containerRegistrySpnPassword'] = $containerRegistrySpnPassword
      $DeploymentScriptOutputs['containerRegistrySpnAppId'] = $containerRegistrySpnAppId
      $DeploymentScriptOutputs['containerRegistrySpnObjectID'] = $containerRegistrySpnObjectID
      $DeploymentScriptOutputs['githubActionsSpnPassword'] = $githubActionsSpnPassword
      $DeploymentScriptOutputs['githubActionsSpnAppId'] = $githubActionsSpnAppId
      $DeploymentScriptOutputs['githubActionsSpnObjectID'] = $githubActionsSpnObjectID
      $DeploymentScriptOutputs['restApiSpnPassword'] = $restApiSpnPassword
      $DeploymentScriptOutputs['restApiSpnAppId'] = $restApiSpnAppId
      $DeploymentScriptOutputs['restApiSpnObjectID'] = $restApiSpnObjectID
    '''
    retentionInterval: 'P1D'
  }
}

// Outputs
//////////////////////////////////////////////////
output applicationGatewayManagedIdentityPrincipalId string = applicationGatewayManagedIdentity.properties.principalId
output containerRegistryManagedIdentityPrincipalId string = containerRegistryManagedIdentity.properties.principalId
output servicePrincipals array = [
  {
    name: 'containerRegistry'
    password: servicePrincipalsDeploymentScript.properties.outputs.containerRegistrySpnPassword
    appId: servicePrincipalsDeploymentScript.properties.outputs.containerRegistrySpnAppId
    objectId: servicePrincipalsDeploymentScript.properties.outputs.containerRegistrySpnObjectId
  }
  {
    name: 'githubActions'
    password: servicePrincipalsDeploymentScript.properties.outputs.githubActionsSpnPassword
    appId: servicePrincipalsDeploymentScript.properties.outputs.githubActionsSpnAppId
    objectId: servicePrincipalsDeploymentScript.properties.outputs.githubActionsSpnObjectId
  }
  {
    name: 'restApi'
    password: servicePrincipalsDeploymentScript.properties.outputs.restApiSpnPassword
    appId: servicePrincipalsDeploymentScript.properties.outputs.restApiSpnAppId
    objectId: servicePrincipalsDeploymentScript.properties.outputs.restApiSpnObjectId
  }
]
