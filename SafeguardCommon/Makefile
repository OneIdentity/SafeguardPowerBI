# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

TEST_CONNECTOR_DIR=Test

MAIN_PROJECT_CONFIG=SafeguardCommon.proj
TEST_PROJECT_CONFIG=$(TEST_CONNECTOR_DIR)\SafeguardCommonTest.proj

MAIN_CONNECTOR=Deploy\SafeguardCommon\Bin\SafeguardCommon.mez
TEST_FRAMEWORK=Deploy\UnitTestFramework\Bin\UnitTestFramework.mez

OUTPUT?=short
ALLOWED_OUTPUT:=short long

ifeq ($(filter $(OUTPUT),$(ALLOWED_OUTPUT)),)
    $(error OUTPUT must be set to 'short' or 'long')
endif

build:
	MSBuild $(TEST_PROJECT_CONFIG) -t:Clean;BuildMez \
	&& MSBuild $(MAIN_PROJECT_CONFIG) -t:Clean;BuildMez

unit-test:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--environmentConfiguration output=$(OUTPUT) \
	--queryFile $(test_file) \
	--prettyPrint

unit-tests:
	PQTest run-test \
	--extension $(MAIN_CONNECTOR) \
	--extension $(TEST_FRAMEWORK) \
	--environmentConfiguration output=$(OUTPUT) \
	--queryFile $(TEST_CONNECTOR_DIR) \
	--prettyPrint
