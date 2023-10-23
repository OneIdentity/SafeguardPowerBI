$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Get-Content -Raw -Path $dir\..\.venv\config.json | ConvertFrom-Json
