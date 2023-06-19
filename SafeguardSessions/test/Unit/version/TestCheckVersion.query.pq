section TestCheckVersion;

Version = Extension.ImportModule("Version.pqm");

Version.CheckVersion = Version[CheckVersion];

SupportedVersions = Extension.ImportModule("SupportedVersions.pqm");

SupportedVersions.Versions = SupportedVersions[Versions];
SupportedVersions.LatestVersion = SupportedVersions[LatestVersion];

AssertVersionCheck = (description as text, version as text, supportedVersions as list, expectedValue as logical) =>
    Fact(description, expectedValue, Version.CheckVersion(version, supportedVersions));

TestCheckVersion = () =>
    let
        dummySupportedVersions = {"custom", "1.1", "2.0", "2.1"},
        cases = {
            {
                "Custom SPS version for testing is supported by the custom connector",
                "custom_version_for_testing",
                dummySupportedVersions,
                true
            },
            {
                "Latest supported SPS version is supported by the custom connector",
                "2.1",
                dummySupportedVersions,
                true
            },
            {
                "Future supported SPS version without breaking change will be supported by the custom connector",
                "2.1.1",
                dummySupportedVersions,
                true
            },
            {"Supported LTS SPS version is supported by the custom connector", "2.0", dummySupportedVersions, true},
            {
                "Future supported LTS version without breaking change will be supported by the custom connector",
                "2.0.1",
                dummySupportedVersions,
                true
            },
            {"Supported older SPS version is supported by the custom connector", "1.1", dummySupportedVersions, true},
            {
                "Future SPS version with breaking change is not supported by the custom connector",
                "2.2",
                dummySupportedVersions,
                false
            },
            {
                "Unsupported LTS SPS version is not supported by the custom connector",
                "1.0",
                dummySupportedVersions,
                false
            }
        },
        facts = ProvideDataForTest(cases, AssertVersionCheck)
    in
        facts;

TestLatestSPSVersionIsSupported = () =>
    let
        description = Text.Format("SPS #[Version] is supported", [Version = SupportedVersions.LatestVersion])
    in
        AssertVersionCheck(description, SupportedVersions.LatestVersion, SupportedVersions.Versions, true);

shared TestCheckVersion.UnitTest = [
    facts = {TestCheckVersion(), TestLatestSPSVersionIsSupported()},
    report = Facts.Summarize(facts)
][report];
