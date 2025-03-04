param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Get-Content -Raw -Path $dir\..\..\.venv\$Project.config.json | ConvertFrom-Json
