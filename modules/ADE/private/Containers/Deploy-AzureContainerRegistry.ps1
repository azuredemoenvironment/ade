function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Deploy-ArmTemplate 'Azure Container Registry' $armParameters -resourceGroupName $armParameters.containerRegistryResourceGroupName -bicep

    $containerRegistryName = $armParameters.acrName
    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer

    # Deploy Container Images
    function TagAndPush {
        param([string]$imageName)

        $containerImageName = "ade-$imageName"

        Write-Log "Tagging and Pushing $containerImageName"

        docker tag "$containerImageName" "$containerRegistryLoginServer/$($containerImageName):latest" && docker push "$containerRegistryLoginServer/$($containerImageName):latest"
        Confirm-LastExitCode
    }
    
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
    
    $imagesToPush | ForEach-Object { TagAndPush $_ }
}