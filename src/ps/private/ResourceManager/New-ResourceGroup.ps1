function New-ResourceGroup {
    param(
        [string] $resourceGroupName,
        [string] $region
    )

    $resourceGroupExists = (az group exists --name $resourceGroupName)
    if ($resourceGroupExists -eq $false) {
        Write-Log "Creating Resource Group $resourceGroupName"
        
        az group create -n $resourceGroupName -l $region
        Confirm-LastExitCode
    }
}