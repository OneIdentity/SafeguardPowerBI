section TestGetVersion;

Version = SafeguardSessions.ImportModule("Version.pqm");

Version.GetVersion = Version[GetVersion];

TestGetVersionIsSuccesful = () =>
    let
        fakeInfoResponse = FakeRawResponse([
            body = [firmware_version = "dummy_version"]
        ]),
        version = Version.GetVersion("dummy_url", "dummy_session_id", [
            Mocks = [
                InfoResponse = fakeInfoResponse
            ]
        ])
    in
        Fact("Version is returned correctly", "dummy_version", version);

TestGetVersionRaisesError = () =>
    let
        requestUrl = "http://dummy_url/api/info",
        fakeInfoResponse = FakeRawResponse([invalid = "response"], [
            Response.Status = 200,
            RequestUrl = requestUrl
        ]),
        expectedReason = "Not Parsable Response",
        expectedMessage = "Error 10002: The source IP returned a response with missing fields.",
        expectedDetail = [
            ManuallyHandled = true,
            ErrorCode = 10002,
            Cause = [invalid = "response"],
            MissingField = "body.firmware_version",
            RequestUrl = requestUrl
        ]
    in
        AssertError(
            "An error is raised if fields are missing in the response received",
            Version.GetVersion,
            {requestUrl, "dummy_session_id", [
                Mocks = [
                    InfoResponse = fakeInfoResponse
                ]
            ]},
            [
                Reason = expectedReason,
                Message = expectedMessage,
                Detail = expectedDetail
            ]
        );

shared TestGetVersion.UnitTest = [
    facts = {TestGetVersionIsSuccesful(), TestGetVersionRaisesError()},
    report = Summarize(facts)
][report];
