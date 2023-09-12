Param($Output)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

if ($null -eq $Output) {
    $Output = "short"
}

& pqtest run-test `
    --extension $config.connector_mez_path `
    --extension $config.test_mez_path `
    --environmentConfiguration output=$Output `
    --queryFile $config.unit_tests_path `
    --prettyPrint
