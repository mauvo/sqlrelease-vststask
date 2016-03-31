If (!$env:DLMAS_HOME)
{
    Write-Host '** Error: DLM Automation Suite not installed. Exiting **'
    Exit
}

$sqlDataCompareDirectory     = $env:DLMAS_HOME + 'SDC\'
$sqlCompareDirectory         = $env:DLMAS_HOME + 'SC\'
$sqlReleaseModulesDirectory  = $env:DLMAS_HOME + 'Modules\'

@(".\TheTask\SDC", ".\TheTask\SC", ".\TheTask\Modules") | % {
    if (Test-Path $_) {
        Remove-Item $_ -Recurse
    }
}

Copy-Item $sqlCompareDirectory         .\TheTask\SC        -recurse -force
Copy-Item $sqlDataCompareDirectory     .\TheTask\SDC       -recurse -force
Copy-Item $sqlReleaseModulesDirectory  .\TheTask\Modules   -recurse -force

Get-ChildItem .\TheTask -Recurse -Filter *.pdb -File | Remove-Item