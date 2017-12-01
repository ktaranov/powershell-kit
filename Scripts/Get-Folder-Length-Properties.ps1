#requires -version 4
#requires -modules PoshRSJob
<#
.SYNOPSIS
Outputs folders length properties.

.DESCRIPTION
Script measure in parallel folders length properties: files count, average files size, folder summary size, minimum and maximum file size

.EXAMPLE
Get-SubFolders-Info -FilePath "C:/"

.NOTE
Original link: 
Author: Konstantin Taranov
#>


function Get-SubFolders-Info {

    param (
        [Parameter(Mandatory=$true)]
        [String]$FilePath = "C:/",
        [Parameter(Mandatory=$false)]
        [String]$InfoType = "-Average -Sum -Maximum -Minimum",
        [Parameter(Mandatory=$false)]
        [String]$SortBy = "Sum -Desc"
    )
    #if (Test-Path $check) {
    #Write-Host "First delete installed Microsoft Management Studio 2016" -foreground:red
    #break;
    #}

    Write-Host "[*] Start folder $FilePath calculation at $(Get-Date -Format 'yyyy-mm-dd HH.mm.ss')" -foreground:yellow

    Get-ChildItem -Directory $FilePath | `
    Start-RSJob -Name {$_.Name} -ScriptBlock `
    {Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | `
     Measure-Object -Property Length -Average -Sum -Maximum -Minimum | `
     Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -PassThru} | `
    Wait-RSJob | Receive-RSJob | Sort-Object Sum -Desc | Format-Table -Property * -AutoSize 
    
    Write-Host "[*] Finished folder $FilePath calculation at $(Get-Date -Format 'yyyy-mm-dd HH.mm.ss')" -foreground:yellow
}

Get-SubFolders-Info -FilePath "C:/"
