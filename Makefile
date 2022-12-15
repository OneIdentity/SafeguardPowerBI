# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

MAIN_CONNECTOR_DIR=SafeguardSessions
TEST_CONNECTOR_DIR=$(MAIN_CONNECTOR_DIR)\test

MAIN_PROJECT_CONFIG=$(MAIN_CONNECTOR_DIR)\SafeguardSessions.proj
TEST_PROJECT_CONFIG=$(TEST_CONNECTOR_DIR)\test.proj

MAIN_CONNECTOR=$(MAIN_CONNECTOR_DIR)\bin\SafeguardSessions.mez
TEST_FRAMEWORK=$(TEST_CONNECTOR_DIR)\bin\UnitTestFramework.mez

build:
	MSBuild $(TEST_PROJECT_CONFIG) -t:Clean;BuildMez \
	&& MSBuild $(MAIN_PROJECT_CONFIG) -t:Clean;BuildMez

test:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--queryFile $(test_file) \
	--prettyPrint
