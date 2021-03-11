#!/usr/bin/env pwsh

param (
    [Parameter(Position = 1, mandatory = $true)]
    [string]$resourceType,
    [Parameter(Position = 2, mandatory = $true)]
    [string]$prefix,
    [Parameter(Position = 3, mandatory = $true)]
    [string]$region,
    [Parameter(Position = 4, mandatory = $true)]
    [string]$name,
    [Parameter(Position = 5, mandatory = $false)]
    [string]$number,
    [Parameter(Position = 6, mandatory = $false)]
    [string]$format
)

# We want to stop if *any* error occurs
Set-StrictMode -Version Latest
Set-PSDebug -Trace 0 -Strict
$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Sanitize inputs
if ([string]::IsNullOrWhiteSpace($format)) {
    # Based on https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
    $format = "{type}-{prefix}-{region}-{name}{number}"
}

$resourceType = ($resourceType -replace '[^A-z]').ToLowerInvariant()
$prefix = ($prefix -replace '[^A-z0-9]').ToLowerInvariant()
$region = ($region -replace '[^A-z]').ToLowerInvariant()
$name = ($name -replace '[^A-z0-9]').ToLowerInvariant()
$removeHyphens = $false

# Token Values
$tokenType = ''
$tokenPrefix = ''
$tokenRegion = ''
$tokenName = ''
$tokenNumber = ''

# Determine Resource Type Short Code
# https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
$tokenType = switch ($resourceType) {
    'akscluster' { 'aks' }
    'analysisservices' { 'a' }
    'analysisservicesserver' { 'a' }
    'apimanagementserviceinstance' { 'apim' }
    'appconfiguration' { 'appcs' }
    'appconfigurationstore' { 'appcs' }
    'appgateway' { 'agw' }
    'appinsights' { 'appi' }
    'applicationgateway' { 'agw' }
    'applicationinsights' { 'appi' }
    'applicationsecuritygroup' { 'asg' }
    'appservice' { 'app' }
    'appserviceenvironment' { 'ase' }
    'appserviceplan' { 'plan' }
    'automationaccount' { 'aa' }
    'availabilityset' { 'avail' }
    'azureanalysisservicesserver' { 'a' }
    'azurearcenabledkubernetescluster' { 'arc' }
    'azurearcenabledserver' { 'arcs' }
    'azurecacheforredisinstance' { 'redis' }
    'azurecognitivesearch' { 'srch' }
    'azurecognitiveservices' { 'cog' }
    'azurecontainerregistry' { 'ac' }
    'azurecosmosdb' { 'cosmos' }
    'azurecosmosdbdatabase' { 'cosmos' }
    'azuredatabricksworkspace' { 'dbw' }
    'azuredataexplorer' { 'de' }
    'azuredataexplorercluster' { 'de' }
    'azuredatafactory' { 'adf' }
    'azurekeyvault' { 'kv' }
    'azuremachinelearningworkspace' { 'mlw' }
    'azuremigrateproject' { 'migr' }
    'azuremonitoractiongroup' { 'ag' }
    'azurepurviewinstance' { 'pview' }
    'azuresqldatabase' { 'sqldb' }
    'azuresqldatabaseserver' { 'sql' }
    'azuresqldatawarehouse' { 'sqldw' }
    'azurestaticwebapps' { 'stap' }
    'azurestorsimple' { 'ssim' }
    'azurestreamanalytics' { 'asa' }
    'azuresynapseanalytics' { 'syn' }
    'blueprint' { 'bp' }
    'blueprintassignment' { 'bpa' }
    'cdnendpoint' { 'cdne' }
    'cdnprofile' { 'cdnp' }
    'cloudservice' { 'cld' }
    'cognitivesearch' { 'srch' }
    'cognitiveservices' { 'cog' }
    'containerinstance' { 'ci' }
    'containerregistry' { 'ac' }
    'containerregistry' { 'c' }
    'cosmosdb' { 'cosmos' }
    'cosmosdbdatabase' { 'cosmos' }
    'databasemigrationservice' { 'dms' }
    'databasemigrationserviceinstance' { 'dms' }
    'databricks' { 'dbw' }
    'databricksworkspace' { 'dbw' }
    'dataexplorer' { 'de' }
    'dataexplorercluster' { 'de' }
    'datafactory' { 'adf' }
    'datalake' { 'dl' }
    'datalakeanalytics' { 'dl' }
    'datalakeanalyticsaccount' { 'dl' }
    'datalakestore' { 'dl' }
    'datalakestoreaccount' { 'dl' }
    'datamanageddisk' { 'dis' }
    'eventgriddomain' { 'evgd' }
    'eventgridtopic' { 'evgt' }
    'eventhub' { 'evh' }
    'eventhubs' { 'evhns' }
    'eventhubsnamespace' { 'evhns' }
    'expressroutecircuit' { 'erc' }
    'externalloadbalancer' { 'lbe' }
    'frontdoor' { 'fd' }
    'function' { 'func' }
    'functionapp' { 'func' }
    'hadoopcluster' { 'hadoop' }
    'hbasecluster' { 'hbase' }
    'hdinsighthadoopcluster' { 'hadoop' }
    'hdinsighthbasecluster' { 'hbase' }
    'hdinsightkafkacluster' { 'kafka' }
    'hdinsightmlservicescluster' { 'mls' }
    'hdinsightsparkcluster' { 'spark' }
    'hdinsightstormcluster' { 'storm' }
    'integrationaccount' { 'ia' }
    'internalloadbalancer' { 'lbi' }
    'iothub' { 'iot' }
    'kafkacluster' { 'kafka' }
    'keyvault' { 'kv' }
    'loadbalancer(external)' { 'lbe' }
    'loadbalancer(internal)' { 'lbi' }
    'localnetworkgateway' { 'lgw' }
    'loganalyticsworkspace' { 'log' }
    'logicapp' { 'logic' }
    'logicapps' { 'logic' }
    'machinelearningworkspace' { 'mlw' }
    'manageddisk' { 'dis' }
    'manageddisk(data)' { 'dis' }
    'manageddisk(os)' { 'osdis' }
    'managedidentity' { 'id' }
    'managementgroup' { 'mg' }
    'migrateproject' { 'migr' }
    'mlservicescluster' { 'mls' }
    'monitoractiongroup' { 'ag' }
    'mysqldatabase' { 'mysql' }
    'networkinterface' { 'nic' }
    'networksecuritygroup' { 'nsg' }
    'notificationhubs' { 'ntf' }
    'notificationhubsnamespace' { 'ntfns' }
    'osmanageddisk' { 'osdis' }
    'policydefinition' { 'policy' }
    'postgresql' { 'psql' }
    'postgresqldatabase' { 'psql' }
    'powerbiembedded' { 'pbi' }
    'publicipaddress' { 'pip' }
    'purview' { 'pview' }
    'purviewinstance' { 'pview' }
    'recoveryservicesvault' { 'rsv' }
    'resourcegroup' { 'rg' }
    'routetable' { 'route' }
    'servicebus' { 'sb' }
    'servicebusqueue' { 'sbq' }
    'servicebustopic' { 'sbt' }
    'servicefabriccluster' { 'sf' }
    'sparkcluster' { 'spark' }
    'sqldatabase' { 'sqldb' }
    'sqldatabaseserver' { 'sql' }
    'sqldatawarehouse' { 'sqldw' }
    'sqlmanagedinstance' { 'sqlmi' }
    'sqlserverstretchdatabase' { 'sqlstrdb' }
    'staticwebapp' { 'stap' }
    'storage' { 's' }
    'storageaccount' { 's' }
    'stormcluster' { 'storm' }
    'storsimple' { 'ssim' }
    'streamanalytics' { 'asa' }
    'subnet' { 'snet' }
    'synapse' { 'syn' }
    'synapseanalytics' { 'syn' }
    'timeseriesinsights' { 'tsi' }
    'timeseriesinsightsenvironment' { 'tsi' }
    'trafficmanager' { 'traf' }
    'trafficmanagerprofile' { 'traf' }
    'userdefinedroute' { 'udr' }
    'virtualmachine' { 'v' }
    'virtualmachinescaleset' { 'vmss' }
    'virtualmachinestorage' { 'stv' }
    'virtualmachinestorageaccount' { 'stv' }
    'virtualnetwork' { 'vnet' }
    'virtualnetworkgateway' { 'vgw' }
    'virtualnetworkpeering' { 'peer' }
    'vm' { 'v' }
    'vmscaleset' { 'vmss' }
    'vmstorage' { 'stv' }
    'vmstorageaccount' { 'stv' }
    'vpnconnection' { 'cn' }
    'waf' { 'wa' }
    'webapp' { 'app' }
    'webapplicationfirewall' { 'wa' }
    'webapplicationfirewallpolicy' { 'wa' }
    Default { $resourceType }
}

# Determine Prefix
$tokenPrefix = $prefix

# Determine Region
$tokenRegion = switch ($region) {
    'eastus' { 'eus' }
    'eastus2' { 'eus2' }
    'westus' { 'wus' }
    Default {}
}

# Determine Name
$tokenName = $name

# Determine Number
$tokenNumber = $number

$replacedString = $format.Replace('{type}', $tokenType).Replace('{prefix}', $tokenPrefix).Replace('{region}', $tokenRegion).Replace('{name}', $tokenName).Replace('{number}', $tokenNumber)

if ($removeHyphens) {
    $replacedString = $replacedString.Replace('-', '')
}

# TODO: check if we are past any azure name limits and adjust accordingly (most likely shorten the name)

Write-Host "Generated name is:"
Write-Host $replacedString
