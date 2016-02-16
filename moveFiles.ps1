If (!$env:DLMAS_HOME)
{
    Write-Host '** Error: DLM Automation Suite not installed. Exiting **'
    Exit
}

$sqlDataCompareDirectory = join-path "$env:DLMAS_HOME" "SDC"
$sqlCompareDirectory = join-path "$env:DLMAS_HOME" "SC"
$sqlReleaseModulesDirectory = join-path "$env:DLMAS_HOME" "Modules"
$targetTheTaskPath = join-path "$PsScriptRoot" "TheTask"
$targetSDCPath = join-path "$targetTheTaskPath" "SDC"
$targetSCPath = join-path "$targetTheTaskPath" "SC"
$targetModulesPath = join-path "$targetTheTaskPath" "Modules"

@($targetSDCPath, $targetSCPath, $targetModulesPath) | foreach {
    if(test-path "$_") {
        Remove-Item "$_" -Recurse
    }
}

Copy-Item "$sqlCompareDirectory" "$targetSCPath" -recurse -force
Copy-Item "$sqlDataCompareDirectory" "$targetSDCPath" -recurse -force
Copy-Item "$sqlReleaseModulesDirectory" "$targetModulesPath" -recurse -force