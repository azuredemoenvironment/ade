#!/usr/bin/env pwsh

param (
    [Parameter(Position = 0, mandatory = $true)]
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

az login

Write-Header "Setting az CLI Subscription to $subscriptionName"

az account set --subscription $subscriptionName

Write-Header "Logging in to Az PowerShell"

Connect-AzAccount -UseDeviceAuthentication

Write-Header "Setting Az PowerShell Subscription to $subscriptionName"

Get-AzSubscription -SubscriptionName $subscriptionName | Set-AzContext

Write-Header "Done! Use ./ade.ps1 -deploy to start deploying the Azure Demo Environment!"