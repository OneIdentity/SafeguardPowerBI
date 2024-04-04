param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$config = $(. $dir\LoadConfig.ps1 -Project $Project)

if ($null -eq $config) {
    & Bootstrap.ps1
}

Import-Alias -Path $config.AliasesPath -Force
