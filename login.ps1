#!/usr/bin/env pwsh

param (
  [Parameter(Position = 0, mandatory = $false)]
  [string]$subscriptionName
)

Write-Header "Logging in to az CLI"

az login

if ($subscriptionName -eq $null -or $subscriptionName -eq "") {
  $subscriptions = $(az account list --query "[].{Name:name,subscriptionId:id}" --output json) | ConvertFrom-Json
  $subscriptionCount = $subscriptions.Count
  Write-Host ($subscriptions | Format-Table | Out-String)

  Write-Header "Select a Subscription; found $subscriptionCount"
  
  for ($i = 0; $i -lt $subscriptionCount; $i++) {
    $subscription = $subscriptions[$i]
    Write-Host "$i`: $($subscription.Name) ($($subscription.SubscriptionId))"
  }
  
  do {
    [int]$subscriptionChoice = Read-Host -prompt "Select number & press enter"
  }
  until ($subscriptionChoice -le $subscriptionCount)

  Write-Host "You selected" $subscriptions[$subscriptionChoice].Name
  $subscriptionName = $subscriptions[$subscriptionChoice].Name
}

Write-Header "Setting az CLI Subscription to $subscriptionName"

az account set --subscription $subscriptionName

Write-Header "Getting Access Token to Login to Powershell"

$accountShowResponse = $(az account show --output json) | ConvertFrom-Json
$accountId = $accountShowResponse.id
$accessTokenResponse = $(az account get-access-token --output json) | ConvertFrom-Json
$accessToken = $accessTokenResponse.accessToken

Write-Header "Logging in to Az PowerShell"

Connect-AzAccount -AccountId $accountId -AccessToken $accessToken

Write-Header "Setting Az PowerShell Subscription to $subscriptionName"

Get-AzSubscription -SubscriptionName $subscriptionName | Set-AzContext

# Write-Header 'Logging in to Docker'
# docker login

Write-Header "Setting Region To Deploy"
$regions = $(az account list-locations --query "[].{RegionName:name,SecondaryRegionName:metadata.pairedRegion[0].name}" --output json) | ConvertFrom-Json
$regionCount = $regions.Count

Write-Header "Select a Region; found $regionCount"

for ($i = 0; $i -lt $regionCount; $i++) {
  $region = $regions[$i]
  Write-Host "$i`: $($region.regionName)"
}

do {
  [int]$regionChoice = Read-Host -prompt "Select number & press enter"
} 
until ($regionChoice -le $regionCount)

$selectedRegion = $regions[$regionChoice].regionName
$selectedSecondaryRegion = $regions[$regionChoice].secondaryRegionName

Write-Host "Setting the Default Resource Location to $selectedRegion"
az configure --defaults location=$selectedRegion locationPair=$selectedSecondaryRegion group=
