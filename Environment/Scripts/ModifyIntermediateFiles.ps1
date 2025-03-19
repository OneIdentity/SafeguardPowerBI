param (
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [string]$IntermediatePath
    )

$configFiles = Get-ChildItem $IntermediatePath *.pqm -rec
Write-Output $configFiles
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "SafeguardCommon.Import", "$($Project).Import" } |
    Set-Content $file.PSPath
}
