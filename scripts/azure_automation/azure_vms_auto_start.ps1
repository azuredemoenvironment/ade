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
	$StartRtn = $VM | Start-AzVM -ErrorAction Continue
	
	if ($StartRtn.Status -ne 'Succeeded') {
		# The VM failed to start, so send notice
        Write-Output ($VM.Name + " failed to Start")
        Write-Error ($VM.Name + " failed to Start. Error was:") -ErrorAction Continue
		Write-Error (ConvertTo-Json $StopRtn) -ErrorAction Continue
	}
	else {
		# The VM started, so send notice
		Write-Output ($VM.Name + " has been Started")
	}
}
