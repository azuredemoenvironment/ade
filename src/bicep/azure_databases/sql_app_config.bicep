// Parameters
//////////////////////////////////////////////////
@description('The Administrator Password of the Sql Database.')
@secure()
param adminPassword string

@description('The name of the App Configuration instance.')
param appConfigName string

@description('The name of the  Sql Database.')
param sqlDatabaseName string

@description('The Administrator Login of the Sql Server.')
param sqlServerAdministratorLogin string

@description('The Fqdn of the Sql Server.')
param sqlServerFqdn string

// Variables
//////////////////////////////////////////////////
var sqlServerConnectionString = 'Data Source=tcp:${sqlServerFqdn},1433;Initial Catalog=${sqlDatabaseName};User Id=${sqlServerAdministratorLogin}@${sqlServerFqdn};Password=${adminPassword};'

// Resource - App Configuration -  App Sql Database Connection String
//////////////////////////////////////////////////
resource appConfigKeyAdeSqlServerConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  name: '${appConfigName}/Ade:SqlServerConnectionString'
  properties: {
    value: sqlServerConnectionString
  }
}
