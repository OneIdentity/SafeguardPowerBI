section TestSafeguardSessions.ValidateSPSVersion;

Version = SafeguardSessions.ImportModule("Version.pqm");

Version.GetVersion = Version[GetVersion];

Yes = SafeguardSessions.ImportFunction("Yes", "Constants.pqm");
No = SafeguardSessions.ImportFunction("No", "Constants.pqm");

TestValidateSPSVersion.SpsURL = "dummy_url";
TestValidateSPSVersion.SessionId = "dummy_session_id";

TestValidateSPSVersionReturnsSessionId = () =>
    let
        AssertValidation = (description as text, fakeInfoResponse as binary, skipVersionCheck as nullable text) =>
            Fact(
                description,
                TestValidateSPSVersion.SessionId,
                ValidateSPSVersion(
                    TestValidateSPSVersion.SpsURL,
                    TestValidateSPSVersion.SessionId,
                    skipVersionCheck,
                    [
                        InfoResponse = fakeInfoResponse
                    ]
                )
            ),
        cases = {
            {
                "Version check is performed by default",
                FakeRawResponse([
                    body = [firmware_version = "7.4.0"]
                ]),
                null
            },
            {
                "Version is supported and version check is performed",
                FakeRawResponse([
                    body = [firmware_version = "7.4.0"]
                ]),
                No
            },
            {
                "Version is supported and version check is skipped",
                FakeRawResponse([
                    body = [firmware_version = "7.4.0"]
                ]),
                Yes
            },
            {
                "Version is unsupported and version check is skipped",
                FakeRawResponse([
                    body = [firmware_version = "unsupported_version"]
                ]),
                Yes
            }
        },
        facts = ProvideDataForTest(cases, AssertValidation)
    in
        facts;

TestValidateSPSVersionRaisesError = () =>
    let
        AssertValidationError = (
            description as text,
            fakeInfoResponse as binary,
            expectedReason as text,
            expectedMessage as text,
            expectedDetail as record
        ) =>
            AssertError(
                description,
                ValidateSPSVersion,
                {
                    TestValidateSPSVersion.SpsURL,
                    TestValidateSPSVersion.SessionId,
                    No,
                    [
                        InfoResponse = fakeInfoResponse
                    ]
                },
                [
                    Reason = expectedReason,
                    Message = expectedMessage,
                    Detail = expectedDetail
                ]
            ),
        cases = {
            {
                "Version is unsupported",
                FakeRawResponse([
                    body = [firmware_version = "unsupported_version"]
                ]),
                "Not Supported Version",
                "Error 10001: Your version of the connector (v2.0.2sps8.1.0) is not compatible with your SPS version (unsupported_version). For a connector version that is compatible with your SPS version, visit the official release page of the connector: https://github.com/OneIdentity/SafeguardPowerBI/releases",
                [
                    Version = "unsupported_version",
                    SupportedVersions = "7.3, 7.4, 7.5, 8.0, 8.1",
                    ManuallyHandled = false,
                    ErrorCode = 10001
                ]
            },
            {
                "An invalid response has been received",
                FakeRawResponse([invalid = "response"]),
                "Not Parsable Response",
                "Error 10002: The source IP returned a response with missing fields.",
                [
                    Cause = [invalid = "response"],
                    MissingField = "body.firmware_version",
                    RequestUrl = "http://dummy_url/api/info",
                    ManuallyHandled = true,
                    ErrorCode = 10002
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertValidationError)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestValidateSPSVersionReturnsSessionId(), TestValidateSPSVersionRaisesError()},
    report = Summarize(facts)
][report];
