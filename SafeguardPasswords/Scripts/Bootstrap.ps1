$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

try {

    New-Variable -Name PROJECT_DIR -Value $(Resolve-Path -Path "$dir\..").Path -Option Constant

    $pathConfig = Get-Content -Raw -Path $PROJECT_DIR\config.json | ConvertFrom-Json

    New-Variable -Name SCRIPTS_DIR -Value $(Join-Path -Path $PROJECT_DIR -Childpath "Scripts") -Option Constant
    New-Variable -Name VENV_DIR -Value $(Join-Path -Path $PROJECT_DIR -Childpath ".venv") -Option Constant

    $packageVersions = Get-Content -Raw -Path $PROJECT_DIR\packageVersions.json | ConvertFrom-Json

    New-Variable -Name DOTNET -Value $(Join-Path -Path $VENV_DIR -Childpath "dotnet") -Option Constant
    New-Variable -Name BINARIES -Value $(Join-Path -Path $VENV_DIR -ChildPath "bin") -Option Constant
    New-Variable -Name PACKAGES -Value $(Join-Path -Path $VENV_DIR -ChildPath "packages") -Option Constant
    New-Variable -Name SDK_TOOLS -Value `
        $(Join-Path -Path $PACKAGES -ChildPath "Microsoft.PowerQuery.SdkTools.$($packageVersions.PowerQuerySDKVersion)\tools") -Option Constant

    [void](New-Item -ItemType Directory -Path $VENV_DIR -Force)
    [void](New-Item -ItemType Directory -Path $BINARIES -Force)
    [void](New-Item -ItemType Directory -Path $PACKAGES -Force)
    [void](New-Item -ItemType Directory -Path $DOTNET -Force)

    Set-Alias -Name dotnet-install -Value "$DOTNET\dotnet-install.ps1"
    Set-Alias -Name dotnet -Value "$DOTNET\dotnet.exe"
    Set-Alias -Name nuget -Value "$BINARIES\nuget.exe"
    Set-Alias -Name makepqx -Value "$SDK_TOOLS\MakePQX.exe"
    Set-Alias -Name pqtest -Value "$SDK_TOOLS\PQTest.exe"

    New-Variable -Name ALIASES -Value $(Join-Path -Path $VENV_DIR -ChildPath "aliases") -Option Constant

    New-Variable -Name ALIAS_LIST -Value dotnet, nuget, makepqx, pqtest -Option Constant
    Export-Alias -Name $ALIAS_LIST -Path $ALIASES -Force

    $config = @{
        VenvPath            = $VENV_DIR
        AliasesPath         = $ALIASES
        ConnectorProjPath   = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.ConnectorProjPath)
        TestProjPath        = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.TestProjPath)
        UnitTestsPath       = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.UnitTestsPath)
        ConnectorMezPath    = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.ConnectorMezPath)
        TestMezPath         = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.TestMezPath)
        AccountOwnershipReport = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.AccountOwnershipReport)
        AssetOwnershipReport = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.AssetOwnershipReport)
        EntitlementReport = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.EntitlementReport)
        MetricsReport = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.MetricsReport)
    }

    ConvertTo-Json $config -Depth 1 | Set-Content $VENV_DIR\config.json

    Write-Output "Installing .NET SDK as a background job"
    if (-Not (Test-Path($(Get-Alias -Name dotnet-install).Definition))) {
        Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile $(Get-Alias -Name dotnet-install).Definition
    }

    $job = Start-Job -Name DotnetInstall -ScriptBlock {
        switch ($input) {
            { $true } {
                & $_.DotnetInstall -InstallDir $_.InstallDir -NoPath -Verbose -Version $_.Version
            }
        }
    } -InputObject @{
        DotnetInstall = $(Get-Alias -Name dotnet-install).Definition
        InstallDir    = $DOTNET
        Version       = $packageVersions.DotnetVersion
    }

    $jobIDs = $(Get-Job -Name DotnetInstall -IncludeChildJob).Id

    $timeOutInSeconds = 600
    Wait-Job -Id $jobIDs -Timeout $timeOutInSeconds
    Receive-Job -Id $jobIDs -ErrorAction Stop

    if ($(Get-Job -Id $jobIDs).Where({ $_.State -eq "Running" }, "First").Count -gt 0) {
        Write-Host "Timeout reached. Stopping the .NET SDK installer download job."
        Stop-Job -Id $jobIDs
        throw "Failed to download and install the .NET SDK within $($timeOutInSeconds) seconds."
    }

    Write-Output "Downloading nuget executable"
    if (-Not (Test-Path($(Get-Alias -Name nuget).Definition))) {
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/v$($packageVersions.NugetVersion)/nuget.exe" `
        -OutFile $(Get-Alias -Name nuget).Definition
    }

    Write-Output "Installing PowerQuery SDK Tools"
    & nuget install Microsoft.PowerQuery.SdkTools -ConfigFile $SCRIPTS_DIR\nuget.config -DirectDownload `
        -Version $packageVersions.PowerQuerySDKVersion

    Write-Output "Bootstrap finished"
    [void](New-Item -ItemType "file" -Path "$VENV_DIR\BOOTSTRAP_FINISHED_FLAG")
}
catch {
    Write-Output $_.Exception.Message
    Write-Output $_.ScriptStackTrace

    Write-Output "Cleanup initiated"
    & $SCRIPTS_DIR\Cleanup.ps1

    exit 1
}

