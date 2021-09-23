param appConfigName string
param applicationInsightsConnectionString string
param applicationInsightsInstrumentationKey string

resource appConfigKeyAppInsightsConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/AppInsights:ConnectionString'
  properties: {
    value: applicationInsightsConnectionString
  }
}

resource appConfigKeyAppInsightsInstrumentationKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/AppInsights:InstrumentationKey'
  properties: {
    value: applicationInsightsInstrumentationKey
  }
}
