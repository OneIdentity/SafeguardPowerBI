VIRTUAL_ENV = .venv
BOOTSTRAP_FINISHED_FLAG = $(VIRTUAL_ENV)/BOOTSTRAP_FINISHED_FLAG

bs: $(BOOTSTRAP_FINISHED_FLAG)

$(BOOTSTRAP_FINISHED_FLAG):
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