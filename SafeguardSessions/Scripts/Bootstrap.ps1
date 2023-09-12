$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath


try {
    New-Variable -Name PROJECT_DIR -Value $(Resolve-Path -Path "$dir\..").Path -Option Constant
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
        venvPath            = $VENV_DIR
        aliasesPath         = $ALIASES
        connectorProjPath  = $(Join-Path -Path $PROJECT_DIR -ChildPath "SafeguardSessions.proj")
        testProjPath       = $(Join-Path -Path $PROJECT_DIR -ChildPath "Test\SafeguardSessionsTest.proj")
        unitTestsPath      = $(Join-Path -Path $PROJECT_DIR -ChildPath "Test")
        connectorMezPath   = $(Join-Path -Path $PROJECT_DIR -ChildPath "Deploy\OneIdentitySafeguard\Bin\OneIdentitySafeguard.mez")
        testMezPath        = $(Join-Path -Path $PROJECT_DIR -ChildPath "Deploy\UnitTestFramework\Bin\UnitTestFramework.mez")
        reportTemplatePath = $(Join-Path -Path $PROJECT_DIR -ChildPath "ReportTemplate\OneIdentitySafeguard.pbit")
    }

    ConvertTo-Json $config -Depth 1 | Set-Content $VENV_DIR\config.json

    Write-Output "Installing .NET SDK"
    if (-Not (Test-Path($(Get-Alias -Name dotnet-install).Definition))) {
        Invoke-WebRequest -Uri https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -OutFile $(Get-Alias -Name dotnet-install).Definition
    }

    & dotnet-install -InstallDir $DOTNET -NoCdn -NoPath -Runtime dotnet -Verbose -Version $packageVersions.DotnetVersion

    Write-Output "Downloading nuget executable"
    if (-Not (Test-Path($(Get-Alias -Name nuget).Definition))) {
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/v$($packageVersions.NugetVersion)/nuget.exe" `
        -OutFile $(Get-Alias -Name nuget).Definition
    }

    Write-Output "Installing PowerQuery SDK Tools"
    & nuget install Microsoft.PowerQuery.SdkTools -ConfigFile $SCRIPTS_DIR\nuget.config -DirectDownload `
        -Version $packageVersions.PowerQuerySDKVersion
}
catch {
    Write-Output $_.Exception.Message
    Write-Output $_.ScriptStackTrace

    Write-Output "Cleanup initiated"
    & $SCRIPTS_DIR\Cleanup.ps1
}
