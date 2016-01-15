param(
    [string]$Operation,

    # Create parameters
    [string]$NuGetFile, 
    [string]$ExportPath,
    
    # DeployFromPackage parameters
    [string]$PackagePath, 

    # DeployFromResources parameters
    [string]$ImportPath, 
    
    # DeployFromDB parameters
    [string]$SourceDatabaseServer,
    [string]$SourceDatabaseName,
    [string]$SourceAuthMethod,
    [string]$SourceDatabaseUsername,
    [string]$SourceDatabasePassword,

    # Shared parameters
    [string]$TargetDatabaseServer,
    [string]$TargetDatabaseName,
    [string]$TargetAuthMethod,
    [string]$TargetDatabaseUsername,
    [string]$TargetDatabasePassword,

    # Partially shared parameters
    [string]$DeleteFilesInExportFolder, 
    [string]$IgnoreStaticDataCreate, 
    [string]$IgnoreStaticDataDeployFromPackage, 
    [string]$SqlCompareOptions, 
    [string]$QueryBatchTimeout, 
    [string]$FilterPath
)

$ErrorActionPreference = "Stop"

# Show arguments
Write-Debug "Operation = $Operation"
Write-Debug "NuGetFile = $NuGetFile"
Write-Debug "ExportPath = $ExportPath"
Write-Debug "PackagePath = $PackagePath"
Write-Debug "ImportPath = $ImportPath"

Write-Debug "SourceDatabaseServer = $SourceDatabaseServer"
Write-Debug "SourceDatabaseName = $SourceDatabaseName"
Write-Debug "SourceAuthMethod = $SourceAuthMethod"
Write-Debug "SourceDatabaseUsername = $SourceDatabaseUsername"
Write-Debug "SourceDatabasePassword = $SourceDatabasePassword"

Write-Debug "TargetDatabaseServer = $TargetDatabaseServer"
Write-Debug "TargetDatabaseName = $TargetDatabaseName"
Write-Debug "TargetAuthMethod = $TargetAuthMethod"
Write-Debug "TargetDatabaseUsername = $TargetDatabaseUsername"
Write-Debug "TargetDatabasePassword = $TargetDatabasePassword"

Write-Debug "DeleteFilesInExportFolder = $DeleteFilesInExportFolder"
Write-Debug "IgnoreStaticData = $IgnoreStaticDataCreate"
Write-Debug "IgnoreStaticData = $IgnoreStaticDataDeployFromPackage"
Write-Debug "SqlCompareOptions = $SqlCompareOptions"
Write-Debug "QueryBatchTimeout = $QueryBatchTimeout"
Write-Debug "FilterPath = $FilterPath"

# Import SQL Release
Import-Module -Name .\Modules\SQLRelease\SQLRelease.dll -Verbose


if($TargetAuthMethod -eq 'sqlServerAuth') {
     $targetDB = New-DlmDatabaseConnection -ServerInstance $TargetDatabaseServer -Database $TargetDatabaseName -Username $TargetDatabaseUsername -Password $TargetDatabasePassword | Test-DatabaseConnection
}else {
     $targetDB = New-DlmDatabaseConnection -ServerInstance $TargetDatabaseServer -Database $TargetDatabaseName | Test-DlmDatabaseConnection
}


switch($operation)
{
"Create"{

    $ignoreStaticDataOption = $IgnoreStaticData -eq "True"

    # If export path is not specified, let's create one
    if(!($ExportPath)){
        $ExportPath = Join-Path $Env:AGENT_RELEASEDIRECTORY "Export.zip"
    }

    # Make sure the directory we're about to create doesn't already exist, and delete any files if requested.
    if ((Test-Path $ExportPath) -AND ((Get-ChildItem $ExportPath | Measure-Object).Count -ne 0)) {
        if ($DeleteFilesInExportFolder -eq 'True') {
            Write-Host "Deleting all files in $ExportPath"
            rmdir $ExportPath -Recurse -Force
        } else {
            Write-Error "The export path is not empty: $ExportPath.  Select the 'Delete files in export folder' option to overwrite the existing folder contents."
        }
    }
    
    Write-Host "NuGetFile is: $NuGetFile"
    Write-Host "ExportPath is: $ExportPath"
    
    # Create the deployment resources from the database to the NuGet package
    $release = New-DlmDatabaseRelease -Target $targetDB -Source $NuGetFile -Verbose -IgnoreStaticData:$ignoreStaticDataOption -SQLCompareOptions $SQLCompareOptions -FilterPath $FilterPath
    
    # Export the deployment resources to disk
    $release | Export-DlmDatabaseRelease -Path $ExportPath -Verbose
    
}
"DeployFromPackage" {

    $release = New-DlmDatabaseRelease -Source $PackagePath -Target $targetDB -Verbose  -SQLCompareOptions $SQLCompareOptions -FilterPath $FilterPath 
    $release | Use-DlmDatabaseRelease -DeployTo $targetDB 

}
"DeployFromResources" {

    # If import path is not specified, let's create one
    if(!($ImportPath)){
        $ImportPath = Join-Path $Env:AGENT_RELEASEDIRECTORY "Export.zip"
    }
    
    $queryBatchTimeoutOption = 30
    if (![string]::IsNullOrWhiteSpace($QueryBatchTimeout)) {
        if (![int32]::TryParse($QueryBatchTimeout , [ref]$queryBatchTimeoutOption )) {
            Write-Error 'The query batch timeout must be a numerical value (in seconds).'
        }
        if ($queryBatchTimeout -lt 0) {
            Write-Error "The query batch timeout can't be negative."
        }
    }
    
    # Do import then use it against target DB
    Import-DlmDatabaseRelease -Path $ImportPath -Verbose | Use-DlmDatabaseRelease -DeployTo $targetDB -Verbose -QueryBatchTimeout $queryBatchTimeoutOption

}
"DeployFromDatabase" {

    $queryBatchTimeoutOption = 30
    if (![string]::IsNullOrWhiteSpace($QueryBatchTimeout)) {
        if (![int32]::TryParse($QueryBatchTimeout , [ref]$queryBatchTimeoutOption )) {
            Write-Error 'The query batch timeout must be a numerical value (in seconds).'
        }
        if ($queryBatchTimeout -lt 0) {
            Write-Error "The query batch timeout can't be negative."
        }
    }

    if($SourceAuthMethod -eq 'sqlServerAuth') {
        $sourceDB = New-DlmDatabaseConnection -ServerInstance $SourceDatabaseServer -Database $SourceDatabaseName -Username $SourceDatabaseUsername -Password $SourceDatabasePassword | Test-DlmDatabaseConnection
    }else {
        $sourceDB = New-DlmDatabaseConnection -ServerInstance $SourceDatabaseServer -Database $SourceDatabaseName | Test-DlmDatabaseConnection
    }

    $release = New-DlmDatabaseRelease -Source $sourceDB -Target $targetDB  -FilterPath $FilterPath -SQLCompareOptions $SQLCompareOptions -Verbose
    $release | Use-DlmDatabaseRelease -DeployTo $targetDB  -SkipPreUpdateSchemaCheck -QueryBatchTimeout $queryBatchTimeoutOption -Verbose

}
}