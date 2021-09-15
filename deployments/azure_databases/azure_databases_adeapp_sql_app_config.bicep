param appConfigName string
param sqlServerConnectionString string

resource appConfigKeyAdeSqlServerConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:SqlServerConnectionString'
  properties: {
    value: sqlServerConnectionString
  }
}
