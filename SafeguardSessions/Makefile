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

ifeq ($(filter $(OUTPUT),$(ALLOWED_OUTPUT)),)
    $(error OUTPUT must be set to 'short' or 'long')
endif

define calculate_checksum
	(Get-FileHash "$(1)" -Algorithm SHA256).Hash.ToLower()
endef

define write_checksum
	Out-File \
		-FilePath '$(1).sha256' \
		-Encoding ASCII \
		-InputObject \$\($(call calculate_checksum,$(1))\)
endef

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

checksum:
	@powershell $(call write_checksum,$(MAIN_CONNECTOR))
	@powershell $(call write_checksum,$(REPORT_TEMPLATE))

verify-checksum:
	@powershell (Get-Content -Path $(MAIN_CONNECTOR).sha256) -eq \
		$(call calculate_checksum,$(MAIN_CONNECTOR))
	@powershell (Get-Content -Path $(REPORT_TEMPLATE).sha256) -eq \
		$(call calculate_checksum,$(REPORT_TEMPLATE))
