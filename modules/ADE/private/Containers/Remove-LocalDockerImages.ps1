function Remove-LocalDockerImages {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Removal of Local Docker Images"

    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer
    
    Write-Log "Removing local docker images"

    $imagesToPullAndPush = @(
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

    $imagesToPullAndPush | ForEach-Object { 
        $containerImageName = "ade-$_"
        $dockerhubImageName = "azuredemoenvironment/$($containerImageName):latest"
        $acrImageName = "$containerRegistryLoginServer/$($containerImageName):latest"

        Write-Log "Removing local image $dockerhubImageName"
        docker rmi $dockerhubImageName

        Write-Log "Removing local image $acrImageName"
        docker rmi $acrImageName
    }

    Write-ScriptSection "Finished Removal of Local Docker Images"
}