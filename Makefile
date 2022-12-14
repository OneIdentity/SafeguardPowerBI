# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

MAIN_CONNECTOR_DIR=SafeguardSessions
TEST_CONNECTOR_DIR=$(MAIN_CONNECTOR_DIR)/test

MAIN_CONNECTOR=$(MAIN_CONNECTOR_DIR)/bin/SafeguardSessions.mez
TEST_FRAMEWORK=$(TEST_CONNECTOR_DIR)/bin/UnitTestFramework.mez

build:
	MSBuild $(TEST_CONNECTOR_DIR) \
	&& MSBuild $(MAIN_CONNECTOR_DIR)

test:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--queryFile $(test_file) \
	--prettyPrint
