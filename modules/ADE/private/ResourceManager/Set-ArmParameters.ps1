function Set-ArmParameters {
    param(
        [string] $sourceFile,
        [string] $destinationFile,
        [object] $parameters
    )

    Write-Log "Copying $parametersSampleFile to $parametersFile"
    $sampleParametersContent = Get-Content -Path $parametersSampleFile
        
    # Replace all known tokens with generated or retrieved values
    $parameters.GetEnumerator() | ForEach-Object {
        $parameterName = "@@$($_.Key)@@"
        $parameterValue = $_.Value

        $sampleParametersContent = $sampleParametersContent -replace $parameterName, $parameterValue
    }
            
    $sampleParametersContent | Set-Content -Path $parametersFile
}