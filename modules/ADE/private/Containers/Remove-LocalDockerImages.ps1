function Remove-LocalDockerImages {
    param(
        [object] $armParameters
    )

    Write-ScriptSection "Starting Removal of Local Docker Images"

    $containerRegistryLoginServer = $armParameters.containerRegistryLoginServer
    
    Write-Log "Removing local docker images"
    docker rmi microsoft/azure-cli
    Confirm-LastExitCode
    
    docker rmi mysql:latest
    Confirm-LastExitCode
    
    docker rmi wordpress:latest
    Confirm-LastExitCode
    
    docker rmi mcr.microsoft.com/azure-powershell
    Confirm-LastExitCode
    
    docker rmi "$containerRegistryLoginServer/azure-cli:latest"
    Confirm-LastExitCode
    
    docker rmi "$containerRegistryLoginServer/mysql:latest"
    Confirm-LastExitCode
    
    docker rmi "$containerRegistryLoginServer/wordpress:latest"
    Confirm-LastExitCode
    
    docker rmi "$containerRegistryLoginServer/azure-powershell"
    Confirm-LastExitCode

    Write-ScriptSection "Finished Removal of Local Docker Images"
}