param ($IntermediatePath)

$configFiles = Get-ChildItem $IntermediatePath *.pqm -rec
Write-Output $configFiles
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "SafeguardCommon.Import", "SafeguardPasswords.Import" } |
    Set-Content $file.PSPath
}
