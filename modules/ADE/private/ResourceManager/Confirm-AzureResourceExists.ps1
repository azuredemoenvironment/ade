function Confirm-AzureResourceExists {
    param(
        [string] $resourceType,
        [string] $resourceNamePartOne,
        [string] $resourceNamePartTwo,
        [string] $resourceNamePartThree
    )

    $resourceType = $resourceType.toLowerInvariant()

    # Natively Supports "exists"
    # These can be executed and returned immediately

    switch ($resourceType) {
        'cdn' { return -not (az cdn name-exists --name $resourceNamePartOne | ConvertFrom-Json).nameAvailable }
        'group' { return (az group exists --name $resourceNamePartOne) -eq 'true' }
        'storage account' { return -not (az storage account check-name --name $resourceNamePartOne | ConvertFrom-Json).nameAvailable }
        'storage container' { return (az storage container exists --account-name $resourceNamePartOne --name $resourceNamePartTwo | ConvertFrom-Json).exists }
        # TODO: Add additional "exists" az types
    }

    # Doesn't natively support "exists"
    # Need to check by "show"ing and validating an error

    $azCommandToExecute = switch ($resourceType) {
        'dns a record' { "az network dns record-set a show -g $resourceNamePartOne -z $resourceNamePartTwo -n $resourceNamePartThree" }
        'dns cname record' { "az network dns record-set cname show -g $resourceNamePartOne -z $resourceNamePartTwo -n $resourceNamePartThree" }
        'dns zone' { "az network dns zone show -g $resourceNamePartOne -n $resourceNamePartTwo" }
        'keyvault' { "az keyvault show -g $resourceNamePartOne -n $resourceNamePartTwo" }
        'service principal' { "az ad sp show --id http://$resourceNamePartOne" }
        
        # TODO: add other az types

        default {
            throw 'Unsupported resourceType in Confirm-AzureResourceExists'
        }
    }

    Write-Log "Executing az command to find existing resource: $azCommandToExecute" | Out-Null
    # This executes the command that we built, but redirects any stderr to null (supressing the error from console output)
    $originalErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    ($azCommandResults = Invoke-Expression -Command "$azCommandToExecute 2>`$null" | ConvertFrom-Json) | Out-Null
    $ErrorActionPreference = $originalErrorActionPreference
    $resourceExists = $null -ne $azCommandResults

    return $resourceExists
}