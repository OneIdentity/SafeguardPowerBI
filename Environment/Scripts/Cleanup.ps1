$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

Write-Host "Cleaning up virtual environment"

if (Test-Path -Path $dir\..\..\.venv) {
    Remove-Item -Path $dir\..\..\.venv `
        -Verbose `
        -Recurse `
        -Force `
        -ErrorAction Ignore

    Write-Host "Clean-up finished"
}
else {
    Write-Host "Nothing to clean-up"
}
