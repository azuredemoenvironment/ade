function Deploy-ArmTemplate {
    param(
        [string] $stepName,
        [object] $armParameters,
        [string] $resourceGroupName = '',
        [string] $region = 'EastUS',
        [string] $resourceLevel = 'group'
    )

    $overwriteParameterFiles = [System.Convert]::ToBoolean($armParameters.overwriteParameterFiles)
    $folderName = $stepName.replace(' ', '_').replace(':', '').toLowerInvariant()
    $fileName = $folderName

    $deploymentName = $stepName.replace(' ', '').replace(':', '') + 'Deployment'
    # TODO: move the templates to be in the module
    $deploymentRootFolder = "$PSScriptRoot/../../../../deployments/$folderName"
    $templateFile = "$deploymentRootFolder/$fileName.json"
    $parametersSampleFile = "$deploymentRootFolder/$fileName.parameters.sample.json"
    $parametersFile = "$deploymentRootFolder/$fileName.parameters.json"

    Write-ScriptSection "Starting $stepName Deployment"
    Write-Log "Deployment Name: $deploymentName"
    Write-Log "Template File: $templateFile"
    Write-Log "Parameters Sample File: $parametersSampleFile"
    Write-Log "Parameters File: $parametersFile"

    # Checking if the parameter file exists, if not, copy sample and replace tokens
    if (-not (Test-Path $parametersFile) -or $overwriteParameterFiles) {
        Set-ArmParameters $parametersSampleFile $parametersFile $armParameters
    }

    $commandToExecute = "az deployment $resourceLevel create -n $deploymentName --template-file '$templateFile' --parameters '$parametersFile'"
    if ($resourceLevel -eq 'sub') {
        Write-Status "Deploying $stepName to Subscription"

        $commandToExecute += " -l $region"
    
        Write-Log "Executing Command: $commandToExecute"
        $commandResults = Invoke-Expression -Command $commandToExecute | ConvertFrom-Json
        Write-Host $commandResults

        Confirm-LastExitCode

        Write-Status "Finished $stepName to Subscription"
    }
    else {
        Write-Status "Deploying $stepName to Resource Group $resourceGroupName"

        $commandToExecute += " -g $resourceGroupName"

        New-ResourceGroup $resourceGroupName $region
    
        Write-Log "Executing Command: $commandToExecute"
        $commandResults = Invoke-Expression -Command $commandToExecute | ConvertFrom-Json
        Write-Host $commandResults

        Confirm-LastExitCode

        Write-Status "Finished Deploying $stepName to Resource Group $resourceGroupName"
    }
}