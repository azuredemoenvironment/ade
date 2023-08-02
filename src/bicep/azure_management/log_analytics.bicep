// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The value in days for Log Analytics retention.')
param logAnalyticsWorkspaceProperties object

@description('The array of properties for the Log Analytics Workspace Solutions.')
param logAnalyticsWorkspaceSolutions array

@description('The list of resource tags.')
param tags object

// Resource - Log Analytics Workspace
//////////////////////////////////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceProperties.name
  location: location
  tags: tags
  properties: {
    retentionInDays: logAnalyticsWorkspaceProperties.properties.retentionInDays
    sku: {
      name: logAnalyticsWorkspaceProperties.properties.sku.name
    }
  }
}

// Resource - Log Analytics Workspace - Solution
//////////////////////////////////////////////////
resource logAnalyticsWorkspaceSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for (logAnalyticsWorkspaceSolution, i) in logAnalyticsWorkspaceSolutions: {
  name: logAnalyticsWorkspaceSolution.name
  location: location
  tags: tags
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: logAnalyticsWorkspaceSolution.name
    publisher: 'Microsoft'
    product: 'OMSGallery/${logAnalyticsWorkspaceSolution.galleryName}'
    promotionCode: ''
  }
}]

// Resource - Log Analytics Workspace - Diagnostic Settings
//////////////////////////////////////////////////
resource logAnalyticsWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: logAnalyticsWorkspace
  name: '${logAnalyticsWorkspace.name}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
