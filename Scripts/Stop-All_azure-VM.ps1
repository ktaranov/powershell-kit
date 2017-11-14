#requires -version 5
#requires -modules AzureRM
## Install the Azure Resource Manager modules from the PowerShell Gallery
#Install-Module AzureRM

<#
.SYNOPSIS
Turn all VMs On or Off

.DESCRIPTION
Script measure in parallel folders length properties: files count, average files size, folder summary size, minimum and maximum file size

.NOTE
Original link: https://sqlstudies.com/2017/09/12/turn-onoff-azure-vms-with-powershell/
Author: Kenneth Fisher
#>

## This is only really required if you aren't already logged in. Unfortunately there
## appears to be a problem using regular MS accounts as credentials for
## Login-AzureRmAccount so you have to go through the window & log in manually.
## Log into Azure
Login-AzureRmAccount
 
$NewStatus = "Off"  ## Values = On, Off, or Flip
                    ## If an values other than Running (on) or VM deallocated (off) then
                    ## deallocate (stop).
$RGName = ""        ## Optional. If not "" then restrict to just VMs in the Resource Group.
 
IF ($RGName -ne "") {
    ## Get only those VMs for the RG requested.
    $VMs = Get-AzureRmVM -Status -ResourceGroupName $RGName }
ELSE {
    ## Get all VMs regardless of RG.
    $VMs = Get-AzureRmVM -Status }
 
## Flip through each VM
foreach ($VM in $VMs)
{
    ## If the VM is deallocated and we want to turn it on or flip it
    ## turn it on.
    IF ($VM.PowerState -eq "VM deallocated" -and 
            ($NewStatus -eq "On" -Or $NewStatus -eq "Flip")){
        "Start " + $VM.Name
        Start-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name}
    ## If the VM is not deallocated and we want to turn it off or flip it
    ## turn it off.  Note: This means that if the VM is in stopped but not deallocated
    ## it will be deallocated. There are almost certainly allocations that cause an 
    ## error & those can be added to an exclusion list if need be.
    ELSEIF ($VM.PowerState -ne "VM deallocated" -and
            ($NewStatus -eq "Off" -Or $NewStatus -eq "Flip")){
        "Stop " + $VM.Name
        Stop-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force}
}

## List current status
Get-AzureRmVM -Status | SELECT Name, PowerState
