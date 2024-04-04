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

# Check SPP report template path: "AccountOwnershipReport", "AssetOwnershipReport", "EntitlementReport", "MetricsReport"
# Rework report template path

if ($Verify -eq $true) {
    Write-Host "Verifying checksums"

    foreach($file in $config.HashFor) {
        $hashFor = $config | Select-Object -ExpandProperty $file
        VerifyChecksum -File $hashFor
    }
}
else {
    Write-Host "Calculating checksums"

    foreach($file in $config.HashFor) {
        $hashFor = $config | Select-Object -ExpandProperty $file
        CalculateChecksum -File $hashFor -Persist -Verbose
    }
}
