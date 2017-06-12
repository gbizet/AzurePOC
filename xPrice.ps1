$global:ReturnsxPricerKeys = [System.Collections.ArrayList]@("")

Function global:Create-xPricer-Azure-Skeleton {

    param(
    [String]$Purge,
    [String]$AzureRmResourceGroup,
    [String]$AzureRmStorageAccount,
    [String]$AzureRmBatchAccount)

    $Purge
    $AzureRmResourceGroup
    $AzureRmStorageAccount
    $AzureRmBatchAccount

       
    if (($Purge -eq "force")) {    
        Remove-AzureRmResourceGroup –Name "$AzureRmResourceGroup" -Force         
    }     


    #create a resource Group
    New-AzureRmResourceGroup –Name "$AzureRmResourceGroup" –Location “West Europe” 

    #create storage account
    New-AzureRmStorageAccount –ResourceGroup "$AzureRmResourceGroup" –StorageAccountName "$AzureRmStorageAccount" –Location "West Europe" –Type "Standard_LRS" 

    #create batch service
    New-AzureRmBatchAccount –AccountName "$AzureRmBatchAccount" –Location "Central US" –ResourceGroupName "$AzureRmResourceGroup"

}

Function global:Returns-xPricer-Keys {

    param([String]$AzureRmBatchAccount)

    $Account = Get-AzureRmBatchAccountKeys –AccountName "$AzureRmBatchAccount"
    $PrimaryAccountKey = $Account.PrimaryAccountKey
    $SecondaryAccountKey = $Account.SecondaryAccountKey 
    $global:ReturnsxPricerKeys.Add("$PrimaryAccountKey")
    $global:ReturnsxPricerKeys.Add("$SecondaryAccountKey")

}

Function global:PoolCreation {

    param([String]$AzureRmBatchAccount)

    $context = Get-AzureRmBatchAccountKeys -AccountName "$AzureRmBatchAccount"
    $configuration = New-Object -TypeName "Microsoft.Azure.Commands.Batch.Models.PSCloudServiceConfiguration" -ArgumentList @(4,"*")
    New-AzureBatchPool -Id "AutoScalePool" -VirtualMachineSize "Small" -CloudServiceConfiguration $configuration -AutoScaleFormula '$TargetDedicated=4;' -BatchContext $context

}

clear;

Login-AzureRmAccount 

Create-xPricer-Azure-Skeleton force xpricer xpricerstorageaccount xpricerbatchaccount

Returns-xPricer-Keys xpricerbatchaccount
$ReturnsxPricerKeys[0]
$ReturnsxPricerKeys[1]

PoolCreation
