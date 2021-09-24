// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration.')
param appConfigName string

@description('The connection string of the Application Insights instance.')
param applicationInsightsConnectionString string

@description('The instrumentation key of the Application Insights instance.')
param applicationInsightsInstrumentationKey string

// Resource - App Congiruation - Application Insights Connection String
//////////////////////////////////////////////////
resource appConfigKeyAppInsightsConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/AppInsights:ConnectionString'
  properties: {
    value: applicationInsightsConnectionString
  }
}

// Resource - App Configuration - Application Insights Instrumentation Key
//////////////////////////////////////////////////
resource appConfigKeyAppInsightsInstrumentationKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/AppInsights:InstrumentationKey'
  properties: {
    value: applicationInsightsInstrumentationKey
  }
}
