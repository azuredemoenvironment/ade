function Deploy-ArmTemplate {
    param(
        [string] $stepName,
        [object] $armParameters,
        [string] $resourceGroupName = '',
        [string] $region = 'EastUS',
        [string] $resourceLevel = 'group',
        [switch] $noWait = $false,
        [switch] $bicep = $false
    )

    $stopwatch = [system.diagnostics.stopwatch]::StartNew()

    $overwriteParameterFiles = [System.Convert]::ToBoolean($armParameters.overwriteParameterFiles)
    $folderName = $stepName.replace(' ', '_').replace(':', '').toLowerInvariant()
    $fileName = $folderName

    $deploymentName = $stepName.replace(' ', '').replace(':', '') + 'Deployment'
    # TODO: move the templates to be in the module
    $deploymentRootFolder = "$PSScriptRoot/../../../../src/bicep/$folderName"
    $templateFile = "$deploymentRootFolder/$fileName."
    if ($bicep) {
        $templateFile += "bicep"
    }
    else {
        $templateFile += "json"
    }
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

    if ($noWait) {
        $commandToExecute += " --no-wait"
    }

    $resourceType = ""
    if ($resourceLevel -eq 'sub') {
        $resourceType = "Subscription"
        $commandToExecute += " -l $region"
    }
    else {
        $resourceType = "Resource Group $resourceGroupName";
        $commandToExecute += " -g $resourceGroupName"
        New-ResourceGroup $resourceGroupName $region
    }

    Write-Status "Deploying $stepName to $resourceType"

    Write-Log "Executing Command: $commandToExecute"
    $commandResults = Invoke-Expression -Command $commandToExecute
    # Write-Log "Command Results:\n$commandResults"

    Confirm-LastExitCode

    $stopwatch.Stop()
    $elapsedSeconds = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)

    Write-Status "Finished $stepName Deployment to $resourceType in $elapsedSeconds seconds"
}