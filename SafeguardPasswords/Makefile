# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

TEST_CONNECTOR_DIR=test

MAIN_PROJECT_CONFIG=SafeguardPasswords.proj
TEST_PROJECT_CONFIG=$(TEST_CONNECTOR_DIR)\test.proj

MAIN_CONNECTOR=bin\OneIdentitySafeguardForPrivilegedPasswords.mez
TEST_FRAMEWORK=$(TEST_CONNECTOR_DIR)\bin\UnitTestFramework.mez

SHORT?=true

build:
	MSBuild $(TEST_PROJECT_CONFIG) -t:Clean;BuildMez \
	&& MSBuild $(MAIN_PROJECT_CONFIG) -t:Clean;BuildMez

unit-test:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--environmentConfiguration short=$(SHORT) \
	--queryFile $(test_file) \
	--prettyPrint

unit-tests:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--environmentConfiguration short=$(SHORT) \
	--queryFile $(TEST_CONNECTOR_DIR) \
	--prettyPrint
