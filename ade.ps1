#!/usr/bin/env pwsh

###################################################################################################
# Parameters and PowerShell Config
###################################################################################################

[CmdletBinding(DefaultParameterSetName = 'deploy-interactive')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", '', Justification = 'Allowing plaintext for CLI purposes')]
param (
    ###################################################################################################
    # Shared Command Set Parameters
    ###################################################################################################
    [Parameter(Position = 1, mandatory = $true)]
    [ValidateLength(1, 8)]
    [string]$alias,

    [Parameter(Position = 4, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 4, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [Parameter(Position = 3, mandatory = $true, ParameterSetName = 'remove')]
    [string]$rootDomainName,

    [Parameter(Position = 8, mandatory = $false, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 8, mandatory = $false, ParameterSetName = 'deploy-cli')]
    [Parameter(Position = 4, mandatory = $false, ParameterSetName = 'remove')]
    [switch]$skipConfirmation,

    ###################################################################################################
    # Deploy Command Sets
    ###################################################################################################
    [Parameter(Position = 0, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 0, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [switch]$deploy,
    [Parameter(Position = 2, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 2, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [string]$email,
    [Parameter(Position = 3, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 3, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [string]$resourceUserName,

    # Required Only for Deploy Interactive
    [Parameter(Position = 5, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [SecureString]$secureResourcePassword,
    [Parameter(Position = 6, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [SecureString]$secureCertificatePassword,

    # Required Only for Deploy CLI
    [Parameter(Position = 5, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [string]$resourcePassword,
    [Parameter(Position = 6, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [string]$certificatePassword,

    [Parameter(Position = 7, mandatory = $true, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 7, mandatory = $true, ParameterSetName = 'deploy-cli')]
    [string]$localNetworkRange,

    [Parameter(Position = 3, mandatory = $false, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 3, mandatory = $false, ParameterSetName = 'deploy-cli')]
    [string]$scriptsBaseUri,

    [Parameter(Position = 9, mandatory = $false, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 9, mandatory = $false, ParameterSetName = 'deploy-cli')]
    [string]$module,

    [Parameter(Position = 10, mandatory = $false, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 10, mandatory = $false, ParameterSetName = 'deploy-cli')]
    [switch]$overwriteParameterFiles,

    ###################################################################################################
    # Remove Command Sets
    ###################################################################################################
    [Parameter(Position = 0, mandatory = $true, ParameterSetName = 'remove')]
    [switch]$remove,
    [Parameter(Position = 2, mandatory = $false, ParameterSetName = 'remove')]
    [switch]$includeKeyVault,

    ###################################################################################################
    # Deallocate Command Sets
    ###################################################################################################
    [Parameter(Position = 0, mandatory = $true, ParameterSetName = 'deallocate')]
    [switch]$deallocate,

    ###################################################################################################
    # Allocate Command Sets
    ###################################################################################################
    [Parameter(Position = 0, mandatory = $true, ParameterSetName = 'allocate')]
    [switch]$allocate
)

# We want to stop if *any* error occurs
Set-StrictMode -Version Latest
# set this to 0 to disable tracing, set to 1 or 2 to show lines being executed (useful for debugging)
Set-PSDebug -Trace 0 -Strict
$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Import Modules
Import-Module "$PSScriptRoot/src/ps/ADE.psm1" -Force -Verbose

try {
    ###################################################################################################
    # Cleanup Parameters
    ###################################################################################################
    if ($null -eq $module -or $module -eq '') {
        $module = 'all'
    }

    $moduleIsValid = Confirm-ModuleIsValid $module

    if (-not $moduleIsValid) {
        throw "You specified an invalid module of $module"
    }

    $wildcardCertificatePath = "$PSScriptRoot/data/wildcard.pfx"

    ###################################################################################################
    # Configuring ARM Parameters Parameters
    ###################################################################################################
    Write-Status 'Configuring Parameters'
    $defaultPrimaryRegion = $(az configure -l --query "[?name == 'location'].value | [0]" --output tsv)
    $defaultSecondaryRegion = $(az configure -l --query "[?name == 'locationpair'].value | [0]" --output tsv)

    if ($secureCertificatePassword -eq $null -and $certificatePassword) {
        $secureCertificatePassword = ConvertTo-SecureString $certificatePassword -AsPlainText -Force
        $certificatePassword = $null
    }

    if ($secureResourcePassword -eq $null -and $resourcePassword) {
        $secureResourcePassword = ConvertTo-SecureString $resourcePassword -AsPlainText -Force
        $resourcePassword = $null
    }

    if ([string]::IsNullOrWhiteSpace($scriptsBaseUri)) {
        $scriptsBaseUri = "https://raw.githubusercontent.com/azuredemoenvironment/ade/main/scripts"
    }

    $armParameters = Set-InitialArmParameters -alias $alias `
        -email $email `
        -resourceUserName $resourceUserName `
        -rootDomainName $rootDomainName `
        -localNetworkRange $localNetworkRange `
        -secureResourcePassword $secureResourcePassword `
        -secureCertificatePassword $secureCertificatePassword `
        -wildcardCertificatePath $wildcardCertificatePath `
        -azureRegion $defaultPrimaryRegion `
        -azurePairedRegion $defaultSecondaryRegion `
        -module $module `
        -scriptsBaseUri $scriptsBaseUri `
        -isDeploying $deploy `
        -overwriteParameterFiles $overwriteParameterFiles `
        -skipConfirmation $skipConfirmation

    ###################################################################################################
    # Start the Requested Action
    ###################################################################################################
    # TODO: only one of these steps should be allowed
    if ($deploy) {
        Deploy-AzureDemoEnvironment $armParameters
    }

    if ($deallocate) {
        Disable-HighCostAzureServices $armParameters
    }

    if ($allocate) {
        Enable-HighCostAzureServices $armParameters
    }

    if ($remove) {
        Remove-AzureDemoEnvironment $armParameters $includeKeyVault
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Log "An error occurred: $ErrorMessage"
    Write-Debug ($ErrorMessage | Format-Table | Out-String)
}
finally {
    # Always set our location back to our script root to make it easier to re-execute
    Set-Location -Path $PSScriptRoot

    Set-PSDebug -Off
}