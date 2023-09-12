$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

& dotnet build $config.connector_proj_path -target:Clean,BuildMez -v d --no-restore
& dotnet build $config.test_proj_path -target:Clean,BuildMez -v d --no-restore
