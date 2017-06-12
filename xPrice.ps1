#.\xPricer.ps1 -Purge no -AzureRmResourceGroup tontonompsg -AzureRmStorageAccount tontonompsg -AzureRmBatchAccount tontonompsg -PoolName tontonompsg

param(
    [String]$Purge,
    [String]$AzureRmResourceGroup,
    [String]$AzureRmStorageAccount,
    [String]$AzureRmBatchAccount,
    [String]$PoolName)

Login-AzureRmAccount 
   
$global:ReturnsxPricerKeys = [System.Collections.ArrayList]@("")
$template_json_file = "c:\template.json"
       
if (($Purge -eq "force")) {    
Remove-AzureRmResourceGroup –Name "$AzureRmResourceGroup" -Force         
}     


#create a resource Group
New-AzureRmResourceGroup –Name "$AzureRmResourceGroup" –Location “West Europe” 

#create storage account
New-AzureRmStorageAccount –ResourceGroup "$AzureRmResourceGroup" –StorageAccountName "$AzureRmStorageAccount" –Location "West Europe" –Type "Standard_LRS" 

#create batch service
New-AzureRmBatchAccount –AccountName "$AzureRmBatchAccount" –Location "Central US" –ResourceGroupName "$AzureRmResourceGroup"

$Account = Get-AzureRmBatchAccountKeys –AccountName "$AzureRmBatchAccount"
$PrimaryAccountKey = $Account.PrimaryAccountKey
$SecondaryAccountKey = $Account.SecondaryAccountKey 
$global:ReturnsxPricerKeys.Add("$PrimaryAccountKey")
$global:ReturnsxPricerKeys.Add("$SecondaryAccountKey")

$context = Get-AzureRmBatchAccountKeys -AccountName "$AzureRmBatchAccount"
$configuration = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSCloudServiceConfiguration" -ArgumentList @(4,"*")
New-AzureBatchPool -Id "$PoolName" -VirtualMachineSize "Small" -CloudServiceConfiguration $configuration -AutoScaleFormula '$TargetDedicated=4;' -BatchContext $context
Write-Host "Pool $PoolName has been created ..."

$ServiceBatchURL = Get-AzureRmBatchAccount –AccountName "ompsg2"
$BatchURL = $ServiceBatchURL.TaskTenantUrl

$json = @"
{
   
}
"@

$jobj = ConvertFrom-Json -InputObject $json    
    

$jobj | add-member "AzureRmStorageAccount" "$AzureRmStorageAccount" -MemberType NoteProperty
$jobj | add-member "PrivateKey" "$Key" -MemberType NoteProperty
$jobj | add-member "AzureRmBatchAccount" "$AzureRmBatchAccount" -MemberType NoteProperty
$jobj | add-member "ServiceBatchURL" "$BatchURL" -MemberType NoteProperty
$jobj | add-member "PoolName" "$PoolName" -MemberType NoteProperty
   
ConvertTo-Json $jobj | Out-File $template_json_file
(Get-Content -path "$template_json_file" -Encoding Unicode) | Set-Content -Encoding "Default" -Path "$template_json_file"
