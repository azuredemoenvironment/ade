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

$resourceType = $resourceType.Replace(' ', '').ToLowerInvariant()
$prefix = $prefix.Replace(' ', '').ToLowerInvariant()
$region = $region.Replace(' ', '').ToLowerInvariant()
$name = $name.Replace(' ' , '').ToLowerInvariant()
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
    'appinsights' { 'appin' }
    'applicationinsights' { 'appin' }
    'resourcegroup' { 'rg' }
    'sqldatabase' { 'sqld' }
    'sqldb' { 'sqld' }
    'sqlserver' { 'sql' }
    'sqlserverdatabase' { 'sqld' }
    'sqlserverdb' { 'sqld' }
    'loganalytics' { 'log' }
    'logicapp' { 'la' }
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
