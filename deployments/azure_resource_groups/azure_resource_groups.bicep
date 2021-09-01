// Target Scope - This option sets the scope of the deployment to the subscription.
targetScope = 'subscription'

// Parameters
@description('Parameter for the default primary Azure region. Currently set to East US.')
param defaultPrimaryRegion string

@description('Parameter for the user alias and default primary Azure region defined from user input.')
param aliasRegion string

@description('Parameter for the Resource Group names for the Azure Demo Environment.')
param resourceGroupNames array = [
  'adeappweb'
  'adeapploadtesting'
  'adeappdb'
  'appserviceplan'
  'containerregistry'
  'inspectorgadget'
  'jumpbox'
  'keyvault'
  'identity'
  'monitor'
  'networking'
  'ntier'
  'vmss'
  'w10client'
]

// Resource - Resource Groups
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = [for resourceGroupName in resourceGroupNames: {
  name: 'rg-ade-${aliasRegion}-${resourceGroupName}'
  location: defaultPrimaryRegion
}]
