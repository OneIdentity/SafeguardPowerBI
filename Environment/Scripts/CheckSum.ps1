Param(
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1 -Project $Project

function CalculateChecksum {
    param (
        $File,
        [switch] $Persist,
        [switch] $Verbose
    )

    $inputFileHashValue = $((Get-FileHash $File -Algorithm SHA256).Hash.ToLower())

    if ($Persist -eq $true) {
        Out-File `
            -FilePath $File".sha256" `
            -Encoding ASCII `
            -InputObject $inputFileHashValue
    }

    if ($Verbose -eq $true) {
        Write-Host "$(Split-Path $File -leaf) : $inputFileHashValue"
    } else {
        $inputFileHashValue
    }
}

function VerifyChecksum {
    param (
        $File
    )

    $readHash = $(Get-Content -Path $File".sha256")
    $calculatedHash = $(CalculateChecksum -File $File)

    Write-Host $(Split-Path $File -leaf) : $(If ($readHash -eq $calculatedHash) { "OK" } Else { "Different" })
}

$reportTemplates = @{}
$config.ReportTemplatePaths.psobject.properties | ForEach-Object { $reportTemplates[$_.Name] = $_.Value }

if ($Verify -eq $true) {
    Write-Host "Verifying checksums"
    $reportTemplates.Values + $config.ConnectorMezPath | ForEach-Object { VerifyChecksum -File $_ }
}
else {
    Write-Host "Calculating checksums"
    $reportTemplates.Values + $config.ConnectorMezPath | ForEach-Object { CalculateChecksum -File $_ -Persist -Verbose }
}
