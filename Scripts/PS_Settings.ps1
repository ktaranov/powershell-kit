<#
.SYNOPSIS
Microsoft.PowerShell_profile.ps1 - My Custom PowerShell profile

.DESCRIPTION
Customizes the PowerShell console

.NOTES
Author: Nicolas PRIGENT
Source: https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-day-to-day-sysadmin-tasks-securing-scripts/
#>

#PART 1

if ($host.name -eq 'ConsoleHost')
{
$Shell=$Host.UI.RawUI
$size=$Shell.BufferSize
$size.width=120
$size.height=3000
$Shell.BufferSize=$size
$size=$Shell.WindowSize
$size.width=120
$size.height=30
$Shell.WindowSize=$size
$Shell.BackgroundColor="Black"
$Shell.ForegroundColor="White"
$Shell.CursorSize=10
$Shell.WindowTitle="Console PowerShell - By Nicolas"
}

#PART 2

function Get-Uptime {

 $os = Get-WmiObject win32_operatingsystem
 $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
 $Display = "" + $Uptime.Days + "days / " + $Uptime.Hours + "hours / " + $Uptime.Minutes + "minutes"
 Write-Output $Display
}

function Get-Time {return $(Get-Date | ForEach {$_.ToLongTimeString()})}

function prompt
{
 Write-Host "[" -noNewLine
 Write-Host $(Get-Time) -ForegroundColor DarkYellow -noNewLine
 Write-Host "] " -noNewLine
 Write-Host $($(Get-Location).Path.replace($home,"~")) -ForegroundColor DarkGreen -noNewLine
 Write-Host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
 return "> "
}

function rdp ($IPAddr) {
 Start-Process -FilePath mstsc -ArgumentList "/admin /w:1024 /h:768 /v:$IPAddr"
}

#PART 3

Set-Location C:\

$MaximumHistoryCount=1024
$IPAddress=@(Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DefaultIpGateway})[0].IPAddress[0]
$IPGateway=@(Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DefaultIpGateway})[0].DefaultIPGateway[0]
$PSExecPolicy=Get-ExecutionPolicy
$PSVersion=$PSVersionTable.PSVersion.Major

#PART 4

Clear-Host
Write-Host " -------------------------------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host " ¦`tComputerName:`t`t" -nonewline -ForegroundColor Green;Write-Host $($env:COMPUTERNAME)"`t`t`t`t" -nonewline -ForegroundColor Cyan;Write-Host "UserName:`t" -nonewline -ForegroundColor Green;Write-Host $env:UserDomain\$env:UserName"`t`t" -nonewline -ForegroundColor Cyan;Write-Host " ¦" -ForegroundColor Green
Write-Host " ¦`tLogon Server:`t`t" -nonewline -ForegroundColor Green;Write-Host $($env:LOGONSERVER)"`t`t`t`t" -nonewline -ForegroundColor Cyan;Write-Host "IP Address:`t" -nonewline -ForegroundColor Green;Write-Host $IPAddress"`t`t" -nonewline -ForegroundColor Cyan;Write-Host " ¦" -ForegroundColor Green
Write-Host " ¦`tPS Execution Policy:`t" -nonewline -ForegroundColor Green;Write-Host $($PSExecPolicy)"`t`t`t" -nonewline -ForegroundColor Cyan;Write-Host "PS Version:`t" -nonewline -ForegroundColor Green;Write-Host $PSVersion"`t`t`t" -nonewline -ForegroundColor Cyan;Write-Host " ¦" -ForegroundColor Green
Write-Host " ¦`tUptime:`t`t`t" -nonewline -ForegroundColor Green;Write-Host $(Get-Uptime)"`t`t`t`t`t`t" -nonewline -ForegroundColor Cyan;Write-Host " ¦" -ForegroundColor Green
Write-Host " -------------------------------------------------------------------------------------------------------`n" -ForegroundColor Green
Write-Host "Customs functions : Get-Uptime / Get-Time / RDP <IPAddr>`n" -ForegroundColor
