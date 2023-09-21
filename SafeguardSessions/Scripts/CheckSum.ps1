Param(
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

. $dir\PreCheck.ps1

function CalculateChecksum {
    param (
        $Connector,
        [switch] $Persist
    )

    $fileHash = $((Get-FileHash $Connector -Algorithm SHA256).Hash.ToLower())

    if ($Persist -eq $true) {
        Out-File `
            -FilePath $Connector".sha256" `
            -Encoding ASCII `
            -InputObject $fileHash
    }

    $fileHash
}

function VerifyChecksum {
    param (
        $Connector
    )

    $readHash = $(Get-Content -Path $Connector".sha256")
    $calculatedHash = $(CalculateChecksum -Connector $Connector)

    Write-Host $(Split-Path $Connector -leaf) : $(If ($readHash -eq $calculatedHash) { "OK" } Else { "Different" })
}


if ($Verify -eq $true) {
    Write-Host "Verifying checksums"
    VerifyChecksum -Connector $config.connector_mez_path
    VerifyChecksum -Connector $config.test_mez_path
}
else {
    Write-Host "Calculating checksums"
    CalculateChecksum -Connector $config.connector_mez_path -Persist
    CalculateChecksum -Connector $config.test_mez_path -Persist
}
