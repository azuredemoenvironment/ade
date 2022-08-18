// Parameters
//////////////////////////////////////////////////
@description('The name of the ADE App Sql Database.')
param adeAppSqlDatabaseName string

@description('The Administrator Login of the ADE App Sql Server.')
param adeAppSqlServerAdministratorLogin string

@description('The Fqdn of the ADE App Sql Server.')
param adeAppSqlServerFqdn string

@description('The Administrator Password of the ADE App Sql Database.')
@secure()
param adminPassword string

@description('The name of the App Configuration instance.')
param appConfigName string

// Variables
//////////////////////////////////////////////////
var sqlServerConnectionString = 'Data Source=tcp:${adeAppSqlServerFqdn},1433;Initial Catalog=${adeAppSqlDatabaseName};User Id=${adeAppSqlServerAdministratorLogin}@${adeAppSqlServerFqdn};Password=${adminPassword};'

// Resource - App Configuration - ADE App SQL Database Connection String
//////////////////////////////////////////////////
resource appConfigKeyAdeSqlServerConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: '${appConfigName}/ADE:SqlServerConnectionString'
  properties: {
    value: sqlServerConnectionString
  }
}
