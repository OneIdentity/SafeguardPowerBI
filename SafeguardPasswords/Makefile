# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

MAIN_PROJECT_CONFIG=SafeguardPasswords.proj

MAIN_CONNECTOR=bin\OneIdentitySafeguardForPrivilegedPasswords.mez

SHORT?=true

build:
	MSBuild $(MAIN_PROJECT_CONFIG) -t:Clean;BuildMez