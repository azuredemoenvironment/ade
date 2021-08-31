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
        $dockerhubImageName = "azuredemoenvironment/$($containerImageName):latest"
        $acrImageName = "$containerRegistryLoginServer/$($containerImageName):latest"

        Write-Log "Pulling $dockerhubImageName from Docker Hub"
        docker pull $dockerhubImageName
        Confirm-LastExitCode

        Write-Log "Tagging $dockerhubImageName as $acrImageName"
        docker tag $dockerhubImageName $acrImageName
        Confirm-LastExitCode

        Write-Log "Pushing $acrImageName to ACR"
        docker push $acrImageName
        Confirm-LastExitCode
    }

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-Status "Finished Tagging and Pushing Docker Images to $containerRegistryLoginServer in $elapsedSeconds seconds"
}