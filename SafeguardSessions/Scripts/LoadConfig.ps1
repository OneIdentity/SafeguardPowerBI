$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Get-Content -Raw -Path $dir\..\config.json | ConvertFrom-Json
