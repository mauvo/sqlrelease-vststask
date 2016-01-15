If (!$env:DLMAS_HOME)
{
    Write-Host '** Error: DLM Automation Suite not installed. Exiting **'
    Exit
}

$sqlDataCompareDirectory     = $env:DLMAS_HOME + 'SDC\'
$sqlCompareDirectory         = $env:DLMAS_HOME + 'SC\'
$sqlReleaseModulesDirectory  = $env:DLMAS_HOME + 'Modules\'

Remove-Item .\TheTask\SDC      -Recurse
Remove-Item .\TheTask\SC       -Recurse
Remove-Item .\TheTask\Modules  -Recurse

Copy-Item $sqlCompareDirectory         .\TheTask\SC        -recurse -force
Copy-Item $sqlDataCompareDirectory     .\TheTask\SDC       -recurse -force
Copy-Item $sqlReleaseModulesDirectory  .\TheTask\Modules   -recurse -force