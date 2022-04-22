// Parameters
//////////////////////////////////////////////////
@description('The name of the App Configuration instance.')
param appConfigName string

@description('The connection string of the SQL Server.')
param sqlServerConnectionString string

// Resource - App Congiruation - SQL Database Connection String
//////////////////////////////////////////////////
resource appConfigKeyAdeSqlServerConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${appConfigName}/ADE:SqlServerConnectionString'
  properties: {
    value: sqlServerConnectionString
  }
}
