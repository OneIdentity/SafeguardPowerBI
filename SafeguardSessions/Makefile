# Install chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gnu make
# choco install make

TEST_CONNECTOR_DIR=test

MAIN_PROJECT_CONFIG=SafeguardSessions.proj
TEST_PROJECT_CONFIG=$(TEST_CONNECTOR_DIR)\test.proj

MAIN_CONNECTOR=bin\OneIdentitySafeguard.mez
TEST_FRAMEWORK=$(TEST_CONNECTOR_DIR)\bin\UnitTestFramework.mez

REPORT_TEMPLATE=assets/template/OneIdentitySafeguard.pbit

SHORT?=true

define calculate_checksum
	(Get-FileHash "$(1)" -Algorithm SHA256).Hash.ToLower()
endef

define write_checksum
	Out-File \
		-FilePath '$(1).sha256' \
		-Encoding ASCII \
		-InputObject \$\($(call calculate_checksum,$(1))\)
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

checksum:
	@powershell $(call write_checksum,$(MAIN_CONNECTOR))
	@powershell $(call write_checksum,$(REPORT_TEMPLATE))

verify-checksum:
	@powershell (Get-Content -Path $(MAIN_CONNECTOR).sha256) -eq \
		$(call calculate_checksum,$(MAIN_CONNECTOR))
	@powershell (Get-Content -Path $(REPORT_TEMPLATE).sha256) -eq \
		$(call calculate_checksum,$(REPORT_TEMPLATE))
