#!/usr/bin/env pwsh

param (
    [Parameter(Position = 0, mandatory = $false)]
    [string]$subscriptionName
)

Write-Header "Logging in to az CLI"

az login

$subscriptions = $(az account list --query "[].{Name:name,subscriptionId:id}" --output json) | ConvertFrom-Json
[int]$subscriptionCount = $subscriptions.count
[int]$subscriptionChoice = $null;
if ($subscriptionName -eq $null -or $subscriptionName -eq "") {
    # get all subscriptions and save into variable
    #$subscriptions = $(az account list --query "[].{Name:name,subscriptionId:id}" --output json) | ConvertFrom-Json

    # get a count of subscriptions for loop
    #[int]$subscriptionCount = $subscriptions.count
    # if (1 -eq $subscriptionCount) {
    #     $subscriptionName = $subscriptions[0].Name
    #     return
    # }

    Write-Header "Select a Subscription; found $subscriptionCount"
    
    # starting value for array for loop
    $i = 0
    foreach ($subscription in $subscriptions) {

        
        # start of menu - value = 0
        $subValue = $i

        # print out all subscriptions
        Write-Host $subValue ":" $subscription.Name "("$subscription.SubscriptionId")"

        # increment value
        $i++
    }
}

Do {
    # repeat loop until valid number is chosen
     if (1 -eq $subscriptionCount) {
        $subscriptionName = $subscriptions[0].Name
        $subscriptionChoice -le $subscriptionCount
        break
    }
    $subscriptionChoice = read-host -prompt "Select number & press enter"
}


# exit criteria for loop
until ($subscriptionChoice -le $subscriptionCount)

Write-Host "You selected" $subscriptions[$subscriptionChoice].Name
$subscriptionName = $subscriptions[$subscriptionChoice].Name

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

Write-Header 'Logging in to Docker'

docker login