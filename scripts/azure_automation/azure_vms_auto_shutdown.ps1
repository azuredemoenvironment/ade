[OutputType([String])]

param (
    [Parameter(Mandatory = $false)]
	[String]$AzureSubscriptionID,
    
    [Parameter(Mandatory=$false)] 
    [String] $ResourceGroupName
)
#Connect to Azure

Connect-AzAccount -Identity


if ($ResourceGroupName) { 
	$VMs = Get-AzVM -ResourceGroupName $ResourceGroupName
}
else { 
	$VMs = Get-AzVM
}

# Stop each of the VMs
foreach ($VM in $VMs) {
	$StopRtn = $VM | Stop-AzVM -Force -ErrorAction Continue
	
	if ($StopRtn.Status -ne 'Succeeded') {
		# The VM failed to stop, so send notice
        Write-Output ($VM.Name + " failed to stop")
        Write-Error ($VM.Name + " failed to stop. Error was:") -ErrorAction Continue
		Write-Error (ConvertTo-Json $StopRtn) -ErrorAction Continue
	}
	else {
		# The VM stopped, so send notice
		Write-Output ($VM.Name + " has been stopped")
	}
}
