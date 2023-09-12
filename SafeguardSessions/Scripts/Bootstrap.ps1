$ErrorActionPreference = "Stop"

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath


try {
    New-Variable -Name ROOT -Value $(Resolve-Path -Path "$dir\..").Path -Option Constant
    New-Variable -Name SCRIPTS -Value $(Join-Path -Path $ROOT -Childpath "Scripts") -Option Constant
    New-Variable -Name VENV -Value $(Join-Path -Path $ROOT -Childpath ".venv") -Option Constant

    New-Variable -Name DOTNET -Value $(Join-Path -Path $VENV -Childpath "dotnet") -Option Constant
    New-Variable -Name BINARIES -Value $(Join-Path -Path $VENV -ChildPath "bin") -Option Constant
    New-Variable -Name PACKAGES -Value $(Join-Path -Path $VENV -ChildPath "packages") -Option Constant
    New-Variable -Name SDK_TOOLS -Value $(Join-Path -Path $PACKAGES -ChildPath "Microsoft.PowerQuery.SdkTools.2.114.4\tools") -Option Constant

    [void](New-Item -ItemType Directory -Path $VENV -Force)
    [void](New-Item -ItemType Directory -Path $BINARIES -Force)
    [void](New-Item -ItemType Directory -Path $PACKAGES -Force)
    [void](New-Item -ItemType Directory -Path $DOTNET -Force)

    Set-Alias -Name dotnet-install -Value "$DOTNET\dotnet-install.ps1"
    Set-Alias -Name dotnet -Value "$DOTNET\dotnet.exe"
    Set-Alias -Name nuget -Value "$BINARIES\nuget.exe"
    Set-Alias -Name makepqx -Value "$SDK_TOOLS\MakePQX.exe"
    Set-Alias -Name pqtest -Value "$SDK_TOOLS\PQTest.exe"

    New-Variable -Name ALIASES -Value $(Join-Path -Path $VENV -ChildPath "aliases") -Option Constant

    New-Variable -Name ALIAS_LIST -Value dotnet, nuget, makepqx, pqtest -Option Constant
    Export-Alias -Name $ALIAS_LIST -Path $ALIASES -Force

    $config = @{
        venv_path           = $VENV
        aliases_path        = $ALIASES
        connector_proj_path = $(Join-Path -Path $ROOT -ChildPath "SafeguardSessions.proj")
        test_proj_path      = $(Join-Path -Path $ROOT -ChildPath "Test\SafeguardSessionsTest.proj")
        unit_tests_path     = $(Join-Path -Path $ROOT -ChildPath "Test")
        connector_mez_path  = $(Join-Path -Path $ROOT -ChildPath "Deploy\OneIdentitySafeguard\Bin\OneIdentitySafeguard.mez")
        test_mez_path       = $(Join-Path -Path $ROOT -ChildPath "Deploy\UnitTestFramework\Bin\UnitTestFramework.mez")
    }

    ConvertTo-Json $config -Depth 1 | Set-Content $ROOT\config.json

    Write-Output "Installing .NET SDK"
    if (-Not (Test-Path($(Get-Alias -Name dotnet-install).Definition))) {
        Invoke-WebRequest -Uri https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -OutFile $(Get-Alias -Name dotnet-install).Definition
    }

    & dotnet-install -InstallDir $DOTNET -NoCdn -NoPath -Runtime dotnet -Verbose -Version 6.0.22

    Write-Output "Downloading nuget executable"
    if (-Not (Test-Path($(Get-Alias -Name nuget).Definition))) {
        Invoke-WebRequest -Uri https://dist.nuget.org/win-x86-commandline/v6.7.0/nuget.exe -OutFile $(Get-Alias -Name nuget).Definition
    }

    Write-Output "Installing PowerQuery SDK Tools"
    & nuget install Microsoft.PowerQuery.SdkTools -ConfigFile $SCRIPTS\nuget.config -DirectDownload -Version 2.114.4
}
catch {
    Write-Output $_.Exception.Message
    Write-Output $_.ScriptStackTrace

    Write-Output "Cleanup initiated"
    & $SCRIPTS\Cleanup.ps1
}
