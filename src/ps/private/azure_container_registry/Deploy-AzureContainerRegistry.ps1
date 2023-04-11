function Deploy-AzureContainerRegistry {
    param(
        [object] $armParameters
    )

    # Deploy Azure Container Registry
    ##################################################
    Write-ScriptSection "Initializing Container Registry Deployment"

    # Parameters
    ##################################################
    $azureRegion = $armParameters.azureRegion
    $resourceGroupName = $armParameters.containerResourceGroupName
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $containerRegistryName = $armParameters.acrName
    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer

    # Create the Azure Container Registry Resource Group
    ##################################################
    az group create -n $resourceGroupName -l $azureRegion

    # Deploy the Azure Container Registry Bicep Template at the Resource Group Scope.
    ##################################################
    Deploy-ArmTemplate 'Azure Container Registry' $armParameters $resourceGroupName -bicep

    Write-Status "Finished Azure Container Registry Deployment"

    # Push Docker Images to Azure Container Registry
    ##################################################
    Write-ScriptSection "Pushing Docker Images to $containerRegistryLoginServer"

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

    Write-Status "Finished Pushing Docker Images to $containerRegistryLoginServer in $elapsedSeconds seconds"
}