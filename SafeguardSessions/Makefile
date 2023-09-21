# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

TEST_CONNECTOR_DIR=Test
DEPLOY_DIR=Deploy
REPORT_TEMPLATE_DIR = ReportTemplate

MAIN_PROJECT_CONFIG=SafeguardSessions.proj
TEST_PROJECT_CONFIG=$(TEST_CONNECTOR_DIR)\SafeguardSessionsTest.proj

MAIN_CONNECTOR=$(DEPLOY_DIR)\OneIdentitySafeguard\Bin\OneIdentitySafeguard.mez
TEST_FRAMEWORK=$(DEPLOY_DIR)\UnitTestFramework\Bin\UnitTestFramework.mez

REPORT_TEMPLATE=ReportTemplate\OneIdentitySafeguard.pbit

OUTPUT?=short
ALLOWED_OUTPUT:=short long

bs: bootstrap

bootstrap:
	@powershell Scripts\Bootstrap.ps1

build: bs
	@powershell Scripts\Build.ps1

unit-test: bs
	@powershell Scripts\RunUnitTests.ps1 -Output $(OUTPUT) -TestFile $(test_file)

unit-tests: bs
	@powershell Scripts\RunUnitTests.ps1 -Output $(OUTPUT)

checksum:
	@powershell Scripts\Checksum.ps1

verify-checksum:
	@powershell Scripts\Checksum.ps1 -Verify

clean:
	@powershell Scripts\Cleanup.ps1
