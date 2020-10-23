function Deploy-DockerImagesToAzureContainerRegistry {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Azure Container Registry Docker Images Deployment"

    $containerRegistryName = $armParameters.acrName
    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer

    az acr login -n $containerRegistryName
    Confirm-LastExitCode

    Write-Log "Pulling docker images to local docker repository"
    docker pull microsoft/azure-cli
    Confirm-LastExitCode

    docker pull mysql:latest
    Confirm-LastExitCode

    docker pull wordpress:latest
    Confirm-LastExitCode

    docker pull mcr.microsoft.com/azure-powershell
    Confirm-LastExitCode

    Write-Log "Tagging local docker images with ACR tags"
    docker tag microsoft/azure-cli:latest "$containerRegistryLoginServer/azure-cli:latest"
    Confirm-LastExitCode

    docker tag mysql:latest "$containerRegistryLoginServer/mysql:latest"
    Confirm-LastExitCode

    docker tag wordpress:latest "$containerRegistryLoginServer/wordpress:latest"
    Confirm-LastExitCode

    docker tag mcr.microsoft.com/azure-powershell "$containerRegistryLoginServer/azure-powershell"
    Confirm-LastExitCode
    
    Write-Log "Pushing docker images to ACR"
    docker push "$containerRegistryLoginServer/azure-cli:latest"
    Confirm-LastExitCode
    
    docker push "$containerRegistryLoginServer/mysql:latest"
    Confirm-LastExitCode
    
    docker push "$containerRegistryLoginServer/wordpress:latest"
    Confirm-LastExitCode
    
    docker push "$containerRegistryLoginServer/azure-powershell"
    Confirm-LastExitCode

    Write-ScriptSection "Finished Azure Container Registry Docker Images Deployment"
}