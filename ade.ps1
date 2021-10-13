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
    [Parameter(Position = 8, mandatory = $false, ParameterSetName = 'deploy-interactive')]
    [Parameter(Position = 8, mandatory = $false, ParameterSetName = 'deploy-cli')]
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
Set-PSDebug -Trace 0 -Strict
$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Import Modules
Import-Module "$PSScriptRoot/modules/ADE" -Force -Verbose

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
    $defaultPrimaryRegion = 'EastUS'
    $defaultSecondaryRegion = 'WestUS'
    $armParameters = Set-InitialArmParameters $alias $email $resourceUserName $rootDomainName $localNetworkRange $defaultPrimaryRegion $defaultSecondaryRegion $module $overwriteParameterFiles $skipConfirmation

    ###################################################################################################
    # Configuring AZ CLI
    ###################################################################################################

    # Setting the default location for services
    Write-Status "Setting the Default Resource Location to $defaultPrimaryRegion"
    az configure --defaults location=$defaultPrimaryRegion group=
    Confirm-LastExitCode

    ###################################################################################################
    # Start the Requested Action
    ###################################################################################################
    # TODO: only one of these steps should be allowed
    if ($deploy) {
        # $isInteractive = $PSCmdlet.ParameterSetName -eq 'interactive'
        if ($secureCertificatePassword -eq $null) {
            $secureCertificatePassword = ConvertTo-SecureString $certificatePassword -AsPlainText -Force
            $certificatePassword = $null
        }
    
        if ($secureResourcePassword -eq $null) {
            $secureResourcePassword = ConvertTo-SecureString $resourcePassword -AsPlainText -Force
            $resourcePassword = $null
        }

        Deploy-AzureDemoEnvironment $armParameters $secureResourcePassword $secureCertificatePassword $wildcardCertificatePath
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
    Resolve-AdeError $_
    Write-Log "An error occurred: $ErrorMessage"
    Write-Debug ($ErrorMessage | Format-Table | Out-String)
}
finally {
    # Clearing the default location
    Write-Log "Clearing the Default Resource Location"
    az configure --defaults location=''

    # Always set our location back to our script root to make it easier to re-execute
    Set-Location -Path $PSScriptRoot

    Set-PSDebug -Off
}