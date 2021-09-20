# global

- removed \*.parameters.json files from repo (local only)
- moved \*.json templates to \_archive folder

## scripts

### Set-InitialArmParameters.ps1

created insert text here...

modified $primaryRegionResourceGroupNamePrefix = "rg-ade-$aliasRegion"
$secondaryRegionResourceGroupNamePrefix = "rg-ade-$aliasSecondaryRegion"

'applicationGatewayManagedIdentityName' =
"uami-$aliasRegion-applicationgateway"
'containerRegistryManagedIdentityName' = "uami-$aliasRegion-containerregistry"
'containerRegistrySPNName' =
"spn-ade-$aliasRegion-containerregistry"
'githubActionsSPNName'= "spn-ade-$aliasRegion-githubactions"
'keyVaultName' =
"kv-ade-$aliasRegion-001"
'logAnalyticsWorkspaceName' = "log-ade-$aliasRegion-001"
'natGatewayName' =
"natgw-$aliasRegion-001"
'natGatewayPublicIPPrefixName' = "pipp-$aliasRegion-001"
'restAPISPNName' = "spn-ade-$aliasRegion-restapi"

'managedIdentityResourceGroupName' =
"$primaryRegionResourceGroupNamePrefix-identity"
'primaryRegionAppServicePlanResourceGroupName' = "$primaryRegionResourceGroupNamePrefix-appserviceplan"
'secondaryRegionAppServicePlanResourceGroupName' =
"$secondaryRegionResourceGroupNamePrefix-appserviceplan"

removed 'automationAccountName' =
"aa-ade-$aliasRegion-001"
'azureBastionName'                                  = "bastion-ade-$aliasRegion-001"
'azureBastionPublicIPAddressName' =
"pip-ade-$aliasRegion-bastion001"
'azureBastionSubnetNSGName'                         = "nsg-ade-$aliasRegion-azurebastion"
'clientServicesSubnetNSGName' =
"nsg-ade-$aliasRegion-clientservices"
'developerSubnetNSGName'                            = "nsg-ade-$aliasRegion-developer"
'directoryServicesSubnetNSGName' =
"nsg-ade-$aliasRegion-directoryservices"
'internetRouteTableName'                            = "route-ade-$aliasRegion-internet"
'managementSubnetNSGName' =
"nsg-ade-$aliasRegion-management"
'natGatewayName'                                    = "ngw-ade-$aliasRegion-001"
'natGatewayPublicIPPrefixName' =
"pipp-ade-$aliasRegion-ngw001"
'natGatewayPublicIPAddressName'                     = "pip-ade-$aliasRegion-natgw01"
'nTierDBSubnetNSGName' =
"nsg-ade-$aliasRegion-ntierdb"
'nTierWebSubnetNSGName'                             = "nsg-ade-$aliasRegion-ntierweb"
'primaryRegionAppServicePlanName' =
"plan-ade-$aliasRegion-001"
'secondaryRegionAppServicePlanName'                 = "plan-ade-$aliasSecondaryRegion-001"
'vmssSubnetNSGName' = "nsg-ade-$aliasRegion-vmss"

## deployments

### azure_log_analytics.json

- converted to azure_log_analytics.bicep
- modified function tag to 'monitoring and diagnostics'
- updated workspaces api to 2020-10-01
- added solution for key vault analytics
- removed dataSources child resource for Azure Activity log
  - this is configured via the activity log deployment
- removed azure automation account due to region conflict

### azure_policy.bicep

- converted to policy.bicep

### azure_identity.bicep

- renamed resource group to rg-ade-$aliasPrimaryRegion-identity
- migrated user assigned managed identity creation from Deploy-AzureIdentity.ps1
- creates identities for application gateway and container registry

### azure_key_vault.json

- converted to key_vault.bicep
- modified function tag to 'key vault'
- updated vaults api to 2019-09-01
- added creation of encryption key to template file
- TODO: need to consider adding enableRbacAuthorization to the properties and
  enabling rbac authorization

removed azure_key_vault.key.sample

### azure_networking.json

- converted to networking.bicep
- removed natGatewayPublicIPAddressName in favor of natGatewayPublicIPPrefixName
- updated publicIPPrefixes api to 2020-06-01
- updated natGateways api to 2020-06-01

### azure_app_service_plan

- updated deployment that merges both the primary region and secondary region
  deployments
- converted to azure_app_service_plan.bicep
- updated serverFarms api to 2020-10-01
- added an autoscale setting to scale out and in based on cpu utilization to a
  maximum of 10 instances
- updated documentation

### azure_app_service_plan_primary_region

- removed deployment

### azure_app_service_plan_secondary_region

- removed deployment

## modules

### keyvault

#### Deploy-AzureIdentity.ps1

- removed az cli creation of managed identities
- removed az cli commands for key vault access policies

#### Deploy-AzureKeyVault.ps1

- removed New-AzureKeyVaultKey $armParameters.keyVaultName 'containerRegistry'

#### New-AzureKeyVaultKey.ps1

- removed file from repo