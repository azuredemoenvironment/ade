#!/usr/bin/env pwsh

# We want to stop if *any* error occurs
Set-StrictMode -Version Latest
Set-PSDebug -Trace 0 -Strict
$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

. ./modules/ADE/shared/Write-Divider.ps1
. ./modules/ADE/shared/Write-Log.ps1
. ./modules/ADE/shared/Write-ScriptSection.ps1
. ./modules/ADE/shared/Write-Status.ps1
. ./modules/ADE/public/Confirm/Confirm-LastExitCode.ps1

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

Write-ScriptSection 'Building the Azure Demo Environment'

Write-ScriptSection 'Building Docker Images'

docker-compose build
Confirm-LastExitCode

Write-ScriptSection "Tagging and Pushing Docker Images to Docker Hub"

$imagesToTagAndPush = @(
    'ade'
    'ade-apigateway'
    'ade-frontend'
    'ade-dataingestorservice'
    'ade-userservice'
    'ade-datareporterservice'
    'ade-loadtesting-grafana'
    'ade-loadtesting-gatling'
    'ade-loadtesting-influxdb'
    'ade-loadtesting-redis'
)

$imagesToTagAndPush | ForEach-Object { 
    $containerImageName = $_

    Write-Log "Tagging and Pushing $containerImageName"

    docker tag "$containerImageName" "azuredemoenvironment/$($containerImageName):latest" && docker push "azuredemoenvironment/$($containerImageName):latest"
    Confirm-LastExitCode
}

$stopwatch.Stop()
$elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

Write-Status "Finished Building the Azure Demo Environment in $elapsedSeconds seconds"
