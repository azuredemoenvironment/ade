<#
.SYNOPSIS
  Connects to Azure and starts of all VMs in the specified Azure subscription or resource group
.DESCRIPTION
  This runbook connects to Azure and starts all VMs in an Azure subscription or resource group.  
  You can attach a schedule to this runbook to run it at a specific time. Note that this runbook does not start
  Azure classic VMs. Use https://gallery.technet.microsoft.com/scriptcenter/Start-Azure-Classic-VMs-86ef746b for that.
  REQUIRED AUTOMATION ASSETS
  1. An Automation variable asset called "AzureSubscriptionId" that contains the GUID for this Azure subscription.  
     To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.
  2. An Automation credential asset called "AzureCredential" that contains the Azure AD user credential with authorization for this subscription. 
     To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.
.PARAMETER AzureCredentialAssetName
   Optional with default of "AzureCredential".
   The name of an Automation credential asset that contains the Azure AD user credential with authorization for this subscription. 
   To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.
.PARAMETER AzureSubscriptionIdAssetName
   Optional with default of "AzureSubscriptionId".
   The name of An Automation variable asset that contains the GUID for this Azure subscription.
   To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.
.PARAMETER ResourceGroupName
   Optional
   Allows you to specify the resource group containing the VMs to start.  
   If this parameter is included, only VMs in the specified resource group will be started, otherwise all VMs in the subscription will be started.  
.NOTES
   AUTHOR: System Center Automation Team 
   LASTEDIT: January 7, 2016
#>

param (
    [Parameter(Mandatory=$false)] 
    [String]  $AzureCredentialAssetName = 'AzureCredential',
        
    [Parameter(Mandatory=$false)]
    [String] $AzureSubscriptionIdAssetName = 'AzureSubscriptionId',

    [Parameter(Mandatory=$false)] 
    [String] $ResourceGroupName
)

# Returns strings with status messages
[OutputType([String])]

# Connect to Azure and select the subscription to work against
$Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName -ErrorAction Stop

$null = Add-AzAccount -Credential $Cred -ErrorAction Stop -ErrorVariable err
if($err) {
	throw $err
}

$SubId = Get-AutomationVariable -Name $AzureSubscriptionIdAssetName -ErrorAction Stop

# If there is a specific resource group, then get all VMs in the resource group,
# otherwise get all VMs in the subscription.
if ($ResourceGroupName) 
{ 
	$VMs = Get-AzVM -ResourceGroupName $ResourceGroupName
}
else 
{ 
	$VMs = Get-AzVM
}

# Start each of the VMs
foreach ($VM in $VMs)
{
	$StartRtn = $VM | Start-AzVM -ErrorAction Continue

	if ($StartRtn.Status -ne 'Succeeded')
	{
		# The VM failed to start, so send notice
        Write-Output ($VM.Name + " failed to start")
        Write-Error ($VM.Name + " failed to start. Error was:") -ErrorAction Continue
		Write-Error (ConvertTo-Json $StartRtn.Error) -ErrorAction Continue
	}
	else
	{
		# The VM stopped, so send notice
		Write-Output ($VM.Name + " has been started")
	}
}
