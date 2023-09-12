$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

$config = $(. $dir\LoadConfig.ps1)

if ($null -eq $config) {
    & Bootstrap.ps1
}

Import-Alias -Path $config.aliasesPath -Force
