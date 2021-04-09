function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Registry' $armParameters -resourceGroupName $armParameters.containerRegistryResourceGroupName -bicep

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $containerRegistryName = $armParameters.acrName
    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer

    Write-ScriptSection "Tagging and Pushing Docker Images to $containerRegistryLoginServer"

    # Deploy Container Images   
    az acr login -n $containerRegistryName
    Confirm-LastExitCode

    docker tag azure-demo-environment "$containerRegistryLoginServer/azure-demo-environment:latest" && docker push "$containerRegistryLoginServer/azure-demo-environment:latest"
    Confirm-LastExitCode

    $imagesToPush = @(
        'apigateway'
        'frontend'
        'dataingestorservice'
        'userservice'
        'datareporterservice'
        'loadtesting-grafana'
        'loadtesting-gatling'
        'loadtesting-influxdb'
        'loadtesting-redis'
    )
    
    $imagesToPush | ForEach-Object { 
        $containerImageName = "ade-$_"

        Write-Log "Tagging and Pushing $containerImageName"

        docker tag "$containerImageName" "$containerRegistryLoginServer/$($containerImageName):latest" && docker push "$containerRegistryLoginServer/$($containerImageName):latest"
        Confirm-LastExitCode
    }

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-Status "Finished Tagging and Pushing Docker Images to $containerRegistryLoginServer in $elapsedSeconds seconds"
}