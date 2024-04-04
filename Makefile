VIRTUAL_ENV = .venv
BOOTSRAP_FINISHED_FLAG = $(VIRTUAL_ENV)/BOOTSRAP_FINISHED_FLAG
PROJECT = $(VIRTUAL_ENV)/PROJECT

COMMON = SafeguardCommon
SESSIONS = SafeguardSessions
PASSWORDS = SafeguardPasswords

bs: $(BOOTSRAP_FINISHED_FLAG)

bootstrap: bs

$(BOOTSRAP_FINISHED_FLAG):
	@powershell Environment\Scripts\Bootstrap.ps1

common: $(PROJECT)
	@powershell Set-Content -Path $(PROJECT) -Value $(COMMON)
	@powershell Get-Content -Path $(PROJECT)

sessions: $(PROJECT)
	@powershell Set-Content -Path $(PROJECT) -Value $(SESSIONS)
	@powershell Get-Content -Path $(PROJECT)

passwords: $(PROJECT)
	@powershell Set-Content -Path $(PROJECT) -Value $(PASSWORDS)
	@powershell Get-Content -Path $(PROJECT)

$(PROJECT):
	@powershell Out-File -FilePath $(PROJECT)

build:
	@powershell Environment\Scripts\Build.ps1 -Project $$(Get-Content -Path $(PROJECT))

unit-tests:
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $$(Get-Content -Path $(PROJECT))

build-cmn: bs
	@powershell Environment\Scripts\Build.ps1 -Project $(COMMON)

unit-test-cmn: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(COMMON) -TestFile $(test_file)

unit-tests-cmn: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(COMMON)

build-sps: bs
	@powershell Environment\Scripts\Build.ps1 -Project $(SESSIONS)

unit-test-sps: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(SESSIONS) -TestFile $(test_file)

unit-tests-sps: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(PASSWORDS)

build-spp: bs
	@powershell Environment\Scripts\Build.ps1 -Project $(PASSWORDS)

unit-test-spp: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(PASSWORDS) -TestFile $(test_file)

unit-tests-spp: bs
	@powershell Environment\Scripts\RunUnitTests.ps1 -Project $(PASSWORDS)



checksum:
	@powershell Scripts\Checksum.ps1

verify-checksum:
	@powershell Scripts\Checksum.ps1 -Verify

clean:
	@powershell Environment\Scripts\Cleanup.ps1
