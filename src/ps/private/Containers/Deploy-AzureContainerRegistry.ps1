function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Registry' $armParameters -resourceLevel 'sub' -bicep

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
        $gitHubContainerRegistryImageName = "azuredemoenvironment/ade-app/$($containerImageName):latest"

        Write-Log "Requesting ACR to Pull GitHub Container Registry Image $gitHubContainerRegistryImageName to $containerRegistryLoginServer"
        az acr import --name "$containerRegistryName" --source "ghcr.io/$gitHubContainerRegistryImageName" --image "$($containerImageName):latest" --force
        Confirm-LastExitCode

        # TODO: Create an ACR Task to Poll Docker Hub for updates: https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview#automate-os-and-framework-patching
    }

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-Status "Finished Tagging and Pushing Docker Images to $containerRegistryLoginServer in $elapsedSeconds seconds"
}