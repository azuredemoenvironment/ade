function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Registry' $armParameters -resourceGroupName $armParameters.containerRegistryResourceGroupName -bicep

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $containerRegistryName = $armParameters.acrName
    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer

    Write-ScriptSection "Pushing Docker Images to $containerRegistryLoginServer"

    # Deploy Container Images   
    az acr login -n $containerRegistryName
    Confirm-LastExitCode

    $imagesToPullAndPush = @(
        'apigateway'
        'dataingestorservice'
        'datareporterservice'
        'eventingestorservice'
        'frontend'
        'loadtesting-gatling'
        'loadtesting-grafana'
        'loadtesting-influxdb'
        'loadtesting-redis'
        'userservice'
    )
    
    $imagesToPullAndPush | ForEach-Object { 
        $containerImageName = "ade-$_"
        $dockerHubImageName = "azuredemoenvironment/$($containerImageName):latest"

        Write-Log "Requesting ACR to Pull Docker Hub Image $dockerHubImageName to $containerRegistryLoginServer"
        az acr import --name "$containerRegistryName" --source "docker.io/$dockerHubImageName" --image "$($containerImageName):latest" --force
        Confirm-LastExitCode
    }

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-Status "Finished Tagging and Pushing Docker Images to $containerRegistryLoginServer in $elapsedSeconds seconds"
}