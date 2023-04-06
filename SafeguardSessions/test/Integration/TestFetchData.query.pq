section TestSafeguardSessions.FetchData;

TestFetchDataIsSuccessful = () =>
    let
        fakeResponse = FakeRawResponse([
            dummy_field = "value",
            dummy_list = {0, 1, 2}
        ], [Response.Status = 200]),
        response = FetchData("dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
            FetchResponse = fakeResponse
        ]),
        facts = {
            Fact("Data fetch response is correct", [dummy_field = "value", dummy_list = {0, 1, 2}], response),
            Fact(
                "Test data fetch meta is correct",
                [
                    Response.Status = 200,
                    RequestUrl = "dummy_url"
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestFetchDataRaisesError = () =>
    let
        AssertErrorIsRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeResponse = FakeRawResponse([
                    #"error" = "reason"
                ], [
                    Response.Status = statusCode
                ]),
                facts = TestErrorIsRaised(
                    try
                        FetchData(
                            "dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
                                FetchResponse = fakeResponse
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "dummy_url"
                    ]
                )
            in
                facts,
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "Something went wrong while authenticating"},
            {403, "Authorization Error", "Not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {429, "Snapshot Quota Error", "Snapshot quota exceeded"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsRaised)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestFetchDataIsSuccessful(), TestFetchDataRaisesError()},
    report = Facts.Summarize(facts)
][report];
