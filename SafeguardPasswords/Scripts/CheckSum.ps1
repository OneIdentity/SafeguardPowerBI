Param(
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

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


if ($Verify -eq $true) {
    Write-Host "Verifying checksums"
    VerifyChecksum -File $config.ConnectorMezPath
    VerifyChecksum -File $config.AccountOwnershipReport
    VerifyChecksum -File $config.AssetOwnershipReport
    VerifyChecksum -File $config.EntitlementReport
    VerifyChecksum -File $config.MetricsReport
}
else {
    Write-Host "Calculating checksums"
    CalculateChecksum -File $config.ConnectorMezPath -Persist -Verbose
    CalculateChecksum -File $config.AccountOwnershipReport -Persist -Verbose
    CalculateChecksum -File $config.AssetOwnershipReport -Persist -Verbose
    CalculateChecksum -File $config.EntitlementReport -Persist -Verbose
    CalculateChecksum -File $config.MetricsReport -Persist -Verbose
}
