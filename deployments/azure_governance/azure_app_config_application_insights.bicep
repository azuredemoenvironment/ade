// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration.')
param appConfigName string

@description('The connection string of the Application Insights instance.')
param applicationInsightsConnectionString string

// Resource - App Configuration - Application Insights Connection String
//////////////////////////////////////////////////
resource appConfigKeyAppInsightsConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ApplicationInsights:ConnectionString'
  properties: {
    value: applicationInsightsConnectionString
  }
}
