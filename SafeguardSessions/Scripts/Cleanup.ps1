$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$config = $(. $dir\LoadConfig.ps1)

Write-Host "Cleaning up virtual environment"
Remove-Item -Path $config.VenvPath `
    -Verbose `
    -Recurse `
    -Force `
    -ErrorAction Ignore

Write-Host "Clean-up finished"
