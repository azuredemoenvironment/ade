function Remove-LocalDockerImages {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Removal of Local Docker Images"

    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer
    
    Write-Log "Removing local docker images"
    
    docker rmi microsoft/azure-cli    
    docker rmi mysql:latest    
    docker rmi wordpress:latest    
    docker rmi mcr.microsoft.com/azure-powershell    
    docker rmi "$containerRegistryLoginServer/azure-cli:latest"    
    docker rmi "$containerRegistryLoginServer/mysql:latest"    
    docker rmi "$containerRegistryLoginServer/wordpress:latest"    
    docker rmi "$containerRegistryLoginServer/azure-powershell"

    Write-ScriptSection "Finished Removal of Local Docker Images"
}