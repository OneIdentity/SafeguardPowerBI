section TestGetSessionsCount;

GetSessionsCount = SafeguardSessions.ImportModule("GetSessionsCount.pqm");

GetSessionsCount.GetSessionsCount = GetSessionsCount[GetSessionsCount];

CreateSchema = SafeguardSessions.ImportFunction("CreateSchema", "SchemaUtils.pqm");

TestGetSessionsCountIsSuccessful = () =>
    let
        fakeCountResponse = FakeRawResponse([count = 2]),
        count = GetSessionsCount.GetSessionsCount(
            "dummy_url", [], "dummy_session_id", [
                Mocks = [GetSessionsCountResponse = fakeCountResponse]
            ]
        )
    in
        Fact("Count is returned correctly", 2, count);

TestGetSessionsCountRaisesError = () =>
    let
        requestUrl = "http://dummy_url/api/audit/sessions/_count",
        fakeCountResponse = FakeRawResponse([invalid = "response"], [
            Response.Status = 200,
            RequestUrl = requestUrl
        ]),
        expectedReason = "Not Parsable Response",
        expectedMessage = "Error 10002: The source IP returned a response with missing fields.",
        expectedDetail = [
            Cause = [invalid = "response"],
            MissingField = "count",
            RequestUrl = requestUrl,
            ManuallyHandled = true,
            ErrorCode = 10002
        ]
    in
        AssertError(
            "An error is raised if fields are missing in the response received",
            GetSessionsCount.GetSessionsCount,
            {requestUrl, [], "dummy_session_id", [
                Mocks = [GetSessionsCountResponse = fakeCountResponse]
            ]},
            [
                Reason = expectedReason,
                Message = expectedMessage,
                Detail = expectedDetail
            ]
        );

shared TestOpenSnapshot.UnitTest = [
    facts = {TestGetSessionsCountIsSuccessful(), TestGetSessionsCountRaisesError()},
    report = Summarize(facts)
][report];
