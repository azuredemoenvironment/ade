#!/usr/bin/env pwsh

param (
    [Parameter(Position = 0, mandatory = $true)]
    [string]$subscriptionName
)

function Write-Divider {
    Write-Host "************************************************************************" -ForegroundColor Cyan | Out-Null
}

Write-Divider
Write-Host "Logging in to az CLI" -ForegroundColor Yellow | Out-Null
Write-Divider

az login

Write-Divider
Write-Host "Setting az CLI Subscription to $subscriptionName" -ForegroundColor Yellow | Out-Null
Write-Divider

az account set --subscription $subscriptionName

Write-Divider
Write-Host "Logging in to Az PowerShell" -ForegroundColor Yellow | Out-Null
Write-Divider

Connect-AzAccount -UseDeviceAuthentication

Write-Divider
Write-Host "Setting Az PowerShell Subscription to $subscriptionName" -ForegroundColor Yellow | Out-Null
Write-Divider

Get-AzSubscription -SubscriptionName $subscriptionName | Set-AzContext

Write-Divider
Write-Host "Done! Use ./ade.ps1 -deploy to start deploying the Azure Demo Environment!" -ForegroundColor Yellow | Out-Null
Write-Divider