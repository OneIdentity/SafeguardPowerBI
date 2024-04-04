$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

try {
    New-Variable -Name ROOT_DIR -Value $(Resolve-Path -Path "$dir\..\..").Path -Option Constant
    New-Variable -Name ENVIRONMENT_DIR -Value $(Join-Path -Path $ROOT_DIR -Childpath "Environment") -Option Constant
    New-Variable -Name CONFIG_DIR -Value $(Join-Path -Path $ENVIRONMENT_DIR -Childpath "Config") -Option Constant
    New-Variable -Name SCRIPTS_DIR -Value $(Join-Path -Path $ENVIRONMENT_DIR -Childpath "Scripts") -Option Constant

    New-Variable -Name VENV_DIR -Value $(Join-Path -Path $ROOT_DIR -Childpath ".venv") -Option Constant

    New-Variable -Name DOTNET -Value $(Join-Path -Path $VENV_DIR -Childpath "dotnet") -Option Constant
    New-Variable -Name BINARIES -Value $(Join-Path -Path $VENV_DIR -ChildPath "bin") -Option Constant
    New-Variable -Name PACKAGES -Value $(Join-Path -Path $VENV_DIR -ChildPath "packages") -Option Constant

    $packageVersions = Get-Content -Raw -Path $CONFIG_DIR\packageVersions.json | ConvertFrom-Json
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
    & nuget install Microsoft.PowerQuery.SdkTools -ConfigFile $CONFIG_DIR\nuget.config -DirectDownload `
        -Version $packageVersions.PowerQuerySDKVersion
    
    Get-ChildItem -Path $dir\..\..\ -Filter "Safeguard*" | ForEach-Object -Process {
        
        New-Variable -Name PROJECT_DIR -Value $(Join-Path -Path $ROOT_DIR -Childpath $_) -Force

        $pathConfig = Get-Content -Raw -Path $(Join-Path -Path $PROJECT_DIR -Childpath "config.json") | ConvertFrom-Json

        $reportTemplatePaths = @{}
        $pathConfig.ReportTemplatePaths.psobject.properties | ForEach-Object { $reportTemplatePaths[$_.Name] = $(Join-Path -Path $PROJECT_DIR -ChildPath $_.Value) }


        $config = @{
            VenvPath               = $VENV_DIR
            AliasesPath            = $ALIASES
            ConnectorProjPath      = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.ConnectorProjPath)
            TestProjPath           = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.TestProjPath)
            UnitTestsPath          = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.UnitTestsPath)
            ConnectorMezPath       = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.ConnectorMezPath)
            TestMezPath            = $(Join-Path -Path $PROJECT_DIR -ChildPath $pathConfig.TestMezPath)
            ReportTemplatePaths    = $reportTemplatePaths
        }
    
        ConvertTo-Json $config | Set-Content $VENV_DIR\$_.config.json
    }   

    Write-Output "Bootstrap finished"
    [void](New-Item -ItemType "file" -Path "$VENV_DIR\BOOTSRAP_FINISHED_FLAG")
}
catch {
    Write-Output $_.Exception.Message
    Write-Output $_.ScriptStackTrace

    Write-Output "Cleanup initiated"
    & $SCRIPTS_DIR\Cleanup.ps1

    exit 1
}
