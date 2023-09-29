VIRTUAL_ENV = .venv
BOOTSRAP_FINISHED_FLAG = $(VIRTUAL_ENV)/BOOTSRAP_FINISHED_FLAG

bs: $(BOOTSRAP_FINISHED_FLAG)

$(BOOTSRAP_FINISHED_FLAG):
	@powershell Scripts\Bootstrap.ps1

bootstrap: bs

build: bs
	@powershell Scripts\Build.ps1

unit-test: bs
	@powershell Scripts\RunUnitTests.ps1 -TestFile $(test_file)

unit-tests: bs
	@powershell Scripts\RunUnitTests.ps1

checksum:
	@powershell Scripts\Checksum.ps1

verify-checksum:
	@powershell Scripts\Checksum.ps1 -Verify

clean:
	@powershell Scripts\Cleanup.ps1
