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
    $TestFile = $config.unitTestsPath
}

& pqtest run-test `
    --extension $config.connectorMezPath `
    --extension $config.testMezPath `
    --environmentConfiguration output=$Output `
    --queryFile $TestFile `
    --prettyPrint
