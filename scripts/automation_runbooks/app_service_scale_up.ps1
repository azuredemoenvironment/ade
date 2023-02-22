param (
	[parameter(Mandatory = $false)]
    [string]$resourceGroupName,

    [Parameter(Mandatory=$false)] 
    [string] $appServicePlanName
)

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

function GetAutomationVariable{
    param(
        [Parameter(Mandatory=$true)] 
        [string] $targetResourceGroupname,

        [Parameter(Mandatory=$true)] 
        [string] $appServicePlanName,

        [Parameter(Mandatory=$true)] 
        [object] $job,

        [Parameter(Mandatory=$true)] 
        [string] $name
    )

    Write-Output "--- --- --- --- --- Getting Automation Variable '$targetResourceGroupname.$appServicePlanName.$name'..."

    return Get-AzAutomationVariable -Name "$targetResourceGroupname.$appServicePlanName.$name" `
        -AutomationAccountName $job.AutomationAccountName `
        -ResourceGroupName $job.ResourceGroupName `
        -ErrorAction SilentlyContinue
}

Connect-AzAccount -Identity

$jobInfo = Custom-Get-AzAutomationAccount
Write-Output "Automation Account Name: "
Write-Output $jobInfo.AutomationAccountName
Write-Output "Automation Resource Group: "
Write-Output $jobInfo.ResourceGroupName

$resourceGroupNames = @()

if ($resourceGroupName.Length -ne 0) {  
    $resourceGroupNames += $resourceGroupName
}
else{
    $resourceGroups = Get-AzResourceGroup

    $resourceGroups | ForEach-Object{
        $resourceGroupNames += $_.ResourceGroupName    
    }
}

$numberOfresourceGroupNames = $resourceGroupNames.Length

foreach($rgName in $resourceGroupNames){

    $appServicePlanNames = @()

    if ($appServicePlanName.Length -ne 0) {  
        $appServicePlanNames += $appServicePlanName
    }
    else{
        $appServicePlans = Get-AzAppServicePlan -ResourceGroupName $rgName

        $appServicePlans | ForEach-Object{
            $appServicePlanNames += $_.Name    
        }
    }

    $appServicePlans = Get-AzAppServicePlan 
    $numberOfAppServicePlans = $appServicePlanNames.Length

    foreach($aSPName in $appServicePlanNames){
        Write-Output "--- --- --- Processing '$aSPName' App Service Plan..."

        $currentAppServicePlan = Get-AzAppServicePlan -ResourceGroupName "$rgName" -Name $aSPName

        Write-Output "--- --- --- --- Getting App Service Plan Automation Variables..."

        $skuName = GetAutomationVariable -targetResourceGroupname $rgName `
            -appServicePlanName $aSPName `
            -job $jobInfo `
            -name "Sku.Name"

        $skuTier = GetAutomationVariable -targetResourceGroupname $rgName `
            -appServicePlanName $aSPName `
            -job $jobInfo `
            -name "Sku.Tier"

        $skuSize = GetAutomationVariable -targetResourceGroupname $rgName `
            -appServicePlanName $aSPName `
            -job $jobInfo `
            -name "Sku.Size"

        Write-Output "--- --- --- --- Finished getting App Service Plan  Automation Variables"

        $tierValue = $skuTier.Value
        $sizeValue = $skuSize.Value
        Write-Output "--- --- --- Converting '$aSPName' to $tierValue Tier at Size '$sizeValue'..."

        $modifiedAppServicePlan = $currentAppServicePlan

        $modifiedAppServicePlan.Sku.Name = $skuName.Value
        $modifiedAppServicePlan.Sku.Tier = $skuTier.Value
        $modifiedAppServicePlan.Sku.Size = $skuSize.Value

        Set-AzAppServicePlan -AppServicePlan $modifiedAppServicePlan | out-null

        Write-Output "--- --- --- Finished converting '$aSPName' App Service Plan to '$tierValue' Tier at Size '$sizeValue'"


    }
}