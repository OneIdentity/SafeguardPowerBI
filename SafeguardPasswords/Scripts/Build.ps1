$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

& dotnet build $config.connectorProjPath -target:Clean,BuildMez -v d --no-restore
