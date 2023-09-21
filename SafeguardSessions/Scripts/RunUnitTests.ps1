Param(
    $Output,
    $TestFile
    )

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

if ($null -eq $Output) {
    $Output = "short"
}

if ($null -eq $TestFile) {
    $TestFile = $config.unit_tests_path
}

& pqtest run-test `
    --extension $config.connector_mez_path `
    --extension $config.test_mez_path `
    --environmentConfiguration output=$Output `
    --queryFile $TestFile `
    --prettyPrint
