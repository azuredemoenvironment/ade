param (
	[parameter(Mandatory = $false)]
    [string]$resourceGroupName,

    [Parameter(Mandatory=$false)] 
    [string] $appServicePlanName
)

#App Scale down from Premium to Basic, requires following logs disabled
#Report Antivirus Audit Logs
#Site Content Change Audit Logs


function Custom-Get-AzAutomationAccount{

    $AutomationResource = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts

    foreach ($Automation in $AutomationResource)
    {
        $Job = Get-AzAutomationJob -ResourceGroupName $Automation.ResourceGroupName -AutomationAccountName $Automation.Name -Id $PSPrivateMetadata.JobId.Guid -ErrorAction SilentlyContinue
        if (!([string]::IsNullOrEmpty($Job)))
        {
            return $Job
        }
    }

    Write-Output "ERROR: Unable to find current Automation Account"
    exit
}

function CreateIfNotExistsAutomationVariable{
    param(
        [Parameter(Mandatory=$true)] 
        [string] $targetResourceGroupname,

        [Parameter(Mandatory=$true)] 
        [string] $appServicePlanName,

        [Parameter(Mandatory=$true)] 
        [object] $job,

        [Parameter(Mandatory=$true)] 
        [string] $name,

        [Parameter(Mandatory=$true)] 
        [object] $value
    )

    $variable = Get-AzAutomationVariable -Name "$targetResourceGroupname.$appServicePlanName.$name" `
        -AutomationAccountName $job.AutomationAccountName `
        -ResourceGroupName $job.ResourceGroupName `
        -ErrorAction SilentlyContinue

    if($variable -eq $null){
        Write-Output "--- --- --- --- --- Creating new variable '$targetResourceGroupname.$appServicePlanName.$name' with value '$value'..."

        New-AzAutomationVariable -Name "$targetResourceGroupname.$appServicePlanName.$name" `
            -AutomationAccountName $job.AutomationAccountName `
            -ResourceGroupName $job.ResourceGroupName `
            -Value $value `
            -Encrypted $false `
            | out-null

        Write-Output "--- --- --- --- --- Finished creating new variable '$targetResourceGroupname.$appServicePlanName.$name'"
    }else{
        $currentValue = $variable.Value
        Write-Output "--- --- --- --- --- Not creating variable '$targetResourceGroupname.$appServicePlanName.$name'. It already exists with value '$currentValue'"
    }
}

Connect-AzAccount -Identity

$jobInfo = Custom-Get-AzAutomationAccount
Write-Output "Automation Account Name: "
Write-Output $jobInfo.AutomationAccountName
Write-Output "Automation Resource Group: "
Write-Output $jobInfo.ResourceGroupName


	$AppServicePlans = Get-AzAppServicePlan 
    Write-Output "Test App Service Plans " $AppServicePlans
	foreach ($asplan in $AppServicePlans)
	{
		CreateIfNotExistsAutomationVariable -targetResourceGroupname $asplan.resourcegroup `
		-appServicePlanName $asplan.name `
		-job $jobInfo `
		-name "SKU.name" `
		-value $asplan.sku.name

		CreateIfNotExistsAutomationVariable -targetResourceGroupname $asplan.resourcegroup `
		-appServicePlanName $asplan.name `
		-job $jobInfo `
		-name "SKU.Tier" `
		-value $asplan.sku.Tier

		CreateIfNotExistsAutomationVariable -targetResourceGroupname $asplan.resourcegroup `
		-appServicePlanName $asplan.name `
		-job $jobInfo `
		-name "SKU.size" `
		-value $asplan.sku.size

    Set-AzAppServicePlan -ResourceGroupName $asplan.resourcegroup -Name $asplan.name -Tier "Basic" | out-null
        Write-Output "--- --- --- Finished converting" $asplan.name "App Service Plan to Basic Tier"
	}
