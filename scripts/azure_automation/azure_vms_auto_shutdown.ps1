[OutputType([String])]

#Connect to Azure

Connect-AzAccount -Identity

#Get all the VMs in the subscription
#Since we are using managed identity and the scope is subscription, the command below will pull all the VMs of that subscription
$VMs = Get-AzVM


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
