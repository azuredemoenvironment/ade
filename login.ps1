#!/usr/bin/env pwsh

param (
    [Parameter(Position = 0, mandatory = $false)]
    [string]$subscriptionName
)

function Write-Header {
    param([string] $message)

    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host $message -ForegroundColor Yellow | Out-Null
    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
    Write-Host "" | Out-Null
}

Write-Header "Logging in to az CLI"

if ($subscriptionName -eq $null -or $subscriptionName -eq "")
{
    ## get all subscriptions and save into variable
    $subscriptions=$(az account list --query "[].{Name:name,subscriptionId:id}" --output json)

    ## get a count of subscriptions for loop
    [int]$subscriptionCount = ($subscriptions | ConvertFrom-Json).count

    ## Convert to JSON for easier manipulation of data
    $subscriptions = ($subscriptions | ConvertFrom-Json)
    Write-Host "Found" $subscriptionCount "Subscriptions"
    
    ##starting value for array for loop
    $i = 0
    foreach ($subscription in $subscriptions)
    {
        ## start of menu - vlaue = 0
        $subValue = $i
        ## print out all subscriptions
        Write-Host $subValue ":" $subscription.Name "("$subscription.SubscriptionId")"
        ## increment value
        $i++
    }
    Do 
    {
        ## repeat loop until valid number is chosen
        [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
    }
    ## exit criteria for loop
    until ($subscriptionChoice -le $subscriptionCount)

    Write-Host "You selected" $subscriptions[$subscriptionChoice].Name
    $subscriptionName = $subscriptions[$subscriptionChoice].Name
}
else 
{
    $subscriptionName = $subscriptionName
}

az login

Write-Header "Setting az CLI Subscription to $subscriptionName"

az account set --subscription $subscriptionName

Write-Header "Logging in to Az PowerShell"

Connect-AzAccount -UseDeviceAuthentication

Write-Header "Setting Az PowerShell Subscription to $subscriptionName"

Get-AzSubscription -SubscriptionName $subscriptionName | Set-AzContext

Write-Header "Done! Use ./ade.ps1 -deploy to start deploying the Azure Demo Environment!"