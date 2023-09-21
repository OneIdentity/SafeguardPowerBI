Param($TestFile)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

$Output = "short"
if ($null -eq $TestFile){
    $testInput = $config.unit_tests_path
} else {
    $testInput = $TestFile
}

$pqtestOutput =  pqtest run-test `
    --extension $config.connector_mez_path `
    --extension $config.test_mez_path `
    --environmentConfiguration output=$Output `
    --queryFile $testInput `
    --prettyPrint 

$resultsAsObject =  $pqtestOutput | ConvertFrom-Json

function LogError {
    param (
        $testResult
    )
    Write-Host "$($testResult.Name): " -NoNewline
    Write-Host "Error" -ForegroundColor red
    Write-Host "Message: " -NoNewline -ForegroundColor red
    Write-Host $testResult.Error.Message
    Write-Host "Details: " -NoNewline -ForegroundColor red
    Write-Host $testResult.Error.Details

}

function LogSucces {
    param (
        $testResult
    )
    Write-Host "$($testResult.Name): " -NoNewline
    Write-Host  "Success" -ForegroundColor green
}

function LogFail {
    param (
        $testResult
    )
    Write-Host "$($testResult.Name): " -NoNewline
    Write-Host "Fail" -ForegroundColor red
    for (($i = 1); $i -lt $testResult.Output.Details.Length; $i++){
        $cleanedTestResult = $testResult.Output[$i].Details.Trim()
        # remove opening and closing parenthesis and split string to expected and actual output
        $resultArray = $cleanedTestResult.Substring(1, $cleanedTestResult.Length-2) -split "<>" 
        $expectedResult = $resultArray[0].Trim()
        $actualResult = $resultArray[1].Trim()
        Write-Host  "Assert Failed: " -NoNewline -ForegroundColor red
        Write-Host $testResult.Output[$i].Notes 
        Write-Host  "Expected Output: " -NoNewline -ForegroundColor green
        Write-Host $expectedResult
        Write-Host  "Actual Output: " -NoNewline -ForegroundColor red
        Write-Host $actualResult
    }
    
}

$isEveryTestSuccessful =  $true
foreach ($result in $resultsAsObject) {
    if ($null -eq $result.Output.Result) { 
        $isEveryTestSuccessful = $false
        LogError($result)
    } elseif ($result.Output.Result -eq "Success") { 
       LogSucces($result)
    } else {
        $isEveryTestSuccessful = $false
        LogFail($result)
    }
 }

 if (!$isEveryTestSuccessful){
    exit 1
 }