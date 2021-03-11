#!/usr/bin/env pwsh

param (
    [Parameter(Position = 1, mandatory = $true)]
    [string]$resourceType,
    [Parameter(Position = 2, mandatory = $true)]
    [string]$workload,
    [Parameter(Position = 3, mandatory = $true)]
    [string]$environment,
    [Parameter(Position = 4, mandatory = $true)]
    [string]$region,
    [Parameter(Position = 5, mandatory = $false)]
    [string]$number,
    [Parameter(Position = 6, mandatory = $false)]
    [string]$format,
    [Parameter(Position = 7, mandatory = $false)]
    [switch]$shortRegion
)

# We want to stop if *any* error occurs
Set-StrictMode -Version Latest
Set-PSDebug -Trace 0 -Strict
$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Sanitize inputs
if ([string]::IsNullOrWhiteSpace($format)) {
    # Based on: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
    $format = "{type}-{workload}-{environment}-{region}{number}"
}

$resourceType = ($resourceType -replace '[^A-z]').ToLowerInvariant()
$workload = ($workload -replace '[^A-z0-9]').ToLowerInvariant()
$region = ($region -replace '[^A-z]').ToLowerInvariant()
$environment = ($environment -replace '[^A-z0-9]').ToLowerInvariant()
$number = ($number -replace '[^0-9]')

# If a number is specified, prefix with a hyphen and pad it to three digits
if (-not [string]::IsNullOrWhiteSpace($number)) {
    $number = '-' + $number.PadLeft(3, '0')
}

$removeHyphens = $false

# Token Values
$tokenType = ''
$tokenWorkload = ''
$tokenRegion = ''
$tokenEnvironment = ''
$tokenNumber = ''

# Determine Resource Type Short Code
# Based on: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
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

# Determine Workload
$tokenWorkload = $workload

# Determine Region
if ($shortRegion) {
    # regions retrieved with the following query, shortcodes are custom:
    # az account list-locations --query "sort_by([].{DisplayName:displayName, Name:name}, &DisplayName)" --output table
    $tokenRegion = switch ($region) {
        'asia' { 'as' }
        'asiapacific' { 'apac' }
        'australia' { 'aus' }
        'australiacentral' { 'ausc' }
        'australiacentral2' { 'ausc2' }
        'australiaeast' { 'ause' }
        'australiasoutheast' { 'ausse' }
        'brazil' { 'bra' }
        'brazilsouth' { 'bras' }
        'brazilsoutheast' { 'brase' }
        'canada' { 'can' }
        'canadacentral' { 'canc' }
        'canadaeast' { 'cane' }
        'centralindia' { 'cin' }
        'centralus' { 'cus' }
        'centralusstage' { 'cuss' }
        'centraluseuap' { 'cusu' }
        'eastasia' { 'eas' }
        'eastasiastage' { 'eass' }
        'eastus' { 'eus' }
        'eastusstage' { 'euss' }
        'eastus2' { 'eus2' }
        'eastus2stage' { 'eus2s' }
        'eastus2euap' { 'eus2su' }
        'europe' { 'eur' }
        'francecentral' { 'frc' }
        'francesouth' { 'frs' }
        'germanynorth' { 'grn' }
        'germanywestcentral' { 'grwc' }
        'global' { 'global' }
        'india' { 'in' }
        'japan' { 'jp' }
        'japaneast' { 'jpe' }
        'japanwest' { 'jpw' }
        'koreacentral' { 'krc' }
        'koreasouth' { 'krs' }
        'northcentralus' { 'ncus' }
        'northcentralusstage' { 'ncuss' }
        'northeurope' { 'neur' }
        'norwayeast' { 'nwe' }
        'norwaywest' { 'nww' }
        'southafricanorth' { 'safn' }
        'southafricawest' { 'safw' }
        'southcentralus' { 'scus' }
        'southcentralusstage' { 'scuss' }
        'southindia' { 'sin' }
        'southeastasia' { 'seas' }
        'southeastasiastage' { 'seass' }
        'switzerlandnorth' { 'swn' }
        'switzerlandwest' { 'sww' }
        'uaecentral' { 'uaec' }
        'uaenorth' { 'uaen' }
        'uksouth' { 'uks' }
        'ukwest' { 'ukw' }
        'unitedkingdom' { 'uk' }
        'unitedstates' { 'us' }
        'westcentralus' { 'wcus' }
        'westeurope' { 'weur' }
        'westindia' { 'win' }
        'westus' { 'wus' }
        'westusstage' { 'wuss' }
        'westus2' { 'wus2' }
        'westus2stage' { 'wus2s' }
        'westus3' { 'wus3' }
        Default { $region }
    }
}
else {
    $tokenRegion = $region
}

# Determine Name
$tokenEnvironment = $environment

# Determine Number
$tokenNumber = $number

$replacedString = $format.Replace('{type}', $tokenType).Replace('{workload}', $tokenWorkload).Replace('{region}', $tokenRegion).Replace('{environment}', $tokenEnvironment).Replace('{number}', $tokenNumber)

# Check if we violate any naming restrictionslengths, characters, etc)
# Based on: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules

# Common Errors
$NameTooLong = "The generated resource name {replacedString} is longer than the max length of {maxLength}. Consider modifying the name manually to meet that restriction."

# using token type since it would be consolidated from naming possiblities
switch ($tokenType) {
    's' {
        $replacedString = $replacedString -replace '[^a-z]'
        $maxLength = 24
        if ($replacedString.Length -gt $maxLength) {
            $warning = $NameTooLong.Replace('{replacedString}', $replacedString).Replace('{maxLength}', $maxLength)
            Write-Warning $warning
        }
    }
}

if ($removeHyphens) {
    $replacedString = $replacedString.Replace('-', '')
}

# TODO: check if we are past any azure name limits and adjust accordingly (most likely shorten the name)

Write-Host "Generated name is:"
Write-Host $replacedString
