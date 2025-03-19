param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1 -Project $Project

& dotnet build $config.ConnectorProjPath -target:Clean,BuildMez -v d --no-restore
& dotnet build $config.TestProjPath -target:Clean,BuildMez -v d --no-restore
