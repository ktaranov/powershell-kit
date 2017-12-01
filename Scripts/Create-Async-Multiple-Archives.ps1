<#
.SYNOPSIS
    Create archive in the specified directory
.DESCRIPTION
    Create archives for the subdirectories of the specified directory asynchronously with jobs
.PARAMETER InputPath
    The path to the directory, containing subdirecrories with the files/directories
.PARAMETER 7ZPath
    The path to the directory, containing executable file 7z.exe
.PARAMETER ArchiveType
    Specifies archive type, parameter supports value: "zip" or "7z"
.PARAMETER ArchivePassword
    Password for the archive
.PARAMETER CompressionLevel
    Specifies the compression level, supports value: Fastest, Fast, Normal, Maximum or Ultra
.EXAMPLE
    ./Create-AsyncMultipleArchives -InputPath "D:\test\arch"
.EXAMPLE
    ./Create-AsyncMultipleArchives -InputPath "D:\test\arch" -ArchiveType "zip"
.EXAMPLE
    ./Create-AsyncMultipleArchives -InputPath "D:\test\arch" -ArchivePassword "111111" -CompressionLevel "Normal"
.NOTE
    Created:  2017-06-27 Alexander Titenko aleks.titenko@gmail.com
    Modified: 2017-09-12 by Kosntantin Taranov k@taranov.pro
#>

function Create-AsyncMultipleArchives {

param(
    [Parameter(Mandatory=$true)]
    $InputPath,
    #The path to 7Z.exe
    [Parameter(Mandatory=$false)]
    [string]$7ZPath="c:\Program Files\7-Zip\7z.exe",
    #Archive format, parameter support value zip or 7z
    [Parameter(Mandatory=$false)]
    [string]$ArchiveType="7z",
    #Password for archive
    [Parameter(Mandatory=$false)]
    [string]$ArchivePassword = "",
    [Parameter(Mandatory=$false)]
    #Sets level of compression: Fastest, Fast, Normal, Maximum, Ultra
    [string]$CompressionLevel = "Ultra",
    [Parameter(Mandatory=$false)]
    [string]$JobCount = 10

)

$sw = [Diagnostics.Stopwatch]::StartNew()
Write-Host "[*] Start at $(Get-Date -Format 'HH:mm:ss')" -foreground:yellow

if (-Not (Test-Path $InputPath) ) {
    Write-Host "File path $InputPath does not exists!" -foreground:red
    break;
}

$objArray = Get-ChildItem -Path $InputPath

if($objArray.Length -eq 0){
    Write-Host "File path $InputPath does not have files or folders!" -foreground:red
    break;
}


switch ($CompressionLevel){
Fastest {"-mx1"}
Fast {"-mx3"}
Normal {"-mx5"}
Maximim {"-mx7"}
Ultra {"-mx9"}
}

if ($ArchiveType -eq "zip"){
$archTypeParam = "-tzip"
}
else {
$archTypeParam = "-t7z"
}

$ScriptBlock = {
    param($7ZPath, $obj, $ArchTypeParam, $ArchiveType, $ArchivePassword, $CompressionLevel)
    if ($ArchivePassword){ 
    & $7ZPath a $archTypeParam ($obj.FullName + "." + $ArchiveType) ("-p" + $ArchivePassword) $obj.FullName $CompressionLevel "-y"
    }
    else {
    & $7ZPath a $archTypeParam ($obj.FullName + "." + $ArchiveType) $obj.FullName $CompressionLevel "-y"
    }
}

Foreach($obj in $objArray){
    Start-Job -ScriptBlock $ScriptBlock -ArgumentList @($7ZPath, $obj, $ArchTypeParam, $ArchiveType, $ArchivePassword, $CompressionLevel)

    while(@(Get-Job -State Running).Count -gt $JobCount){
        Get-Job | Wait-Job -Any | Out-Null
    }
}

Write-Host "Duration:"
$sw.Stop();
$sw.Elapsed  | Format-Table -Property Minutes, Seconds, Milliseconds -AutoSize;
Write-Host "[*] End at $(Get-Date -Format 'HH:mm:ss')" -foreground:yellow
}
