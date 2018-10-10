<#
Results:

Where-Object -FilterScript:  3035.69 ms
Simplfied Where syntax:      2855.33 ms
.Where() method:             1445.21 ms
Using a filter:              1281.13 ms
Conditional in foreach loop: 1073.14 ms
#>

$loop = 1000

$v2 = (Measure-Command {
    for ($i = 0; $i -lt $loop; $i++)
    {
        Get-Process | Where-Object { $_.Name -eq 'powershell_ise' }
    }
}).TotalMilliseconds

$v3 = (Measure-Command {
    for ($i = 0; $i -lt $loop; $i++)
    {
        Get-Process | Where Name -eq 'powershell_ise'
    }
}).TotalMilliseconds

$v4 = (Measure-Command {
    for ($i = 0; $i -lt $loop; $i++)
    {
        (Get-Process).Where({ $_.Name -eq 'powershell_ise' })
    }
}).TotalMilliseconds

$filter = (Measure-Command {
    filter isISE { if ($_.Name -eq 'powershell_ise') { $_ } }
    
    for ($i = 0; $i -lt $loop; $i++)
    {
        Get-Process | isISE
    }
}).TotalMilliseconds

$foreachLoop = (Measure-Command {
    for ($i = 0; $i -lt $loop; $i++)
    {
        foreach ($process in (Get-Process))
        {
            if ($process.Name -eq 'powershell_ise')
            {
                # Do something with $process
                $process
            }
        }
    }
}).TotalMilliseconds

Write-Host ('Where-Object -FilterScript:  {0:f2} ms' -f $v2);
Write-Host ('Simplfied Where syntax:      {0:f2} ms' -f $v3);
Write-Host ('.Where() method:             {0:f2} ms' -f $v4);
Write-Host ('Using a filter:              {0:f2} ms' -f $filter);
Write-Host ('Conditional in foreach loop: {0:f2} ms' -f $foreachLoop);
