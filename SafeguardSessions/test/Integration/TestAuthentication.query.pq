section TestSafeguardSessions.Authentication;

TestAuthenticateIsSuccessful = () =>
    let
        fakeAuthResponse = FakeRawResponse(
            [],
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        response = Authenticate(
            "dummy_url", [
                Username = "dummy",
                Password = "pwd"
            ], [
                AuthResponse = fakeAuthResponse
            ]
        ),
        facts = {
            Fact("Authentication response data correct", [], response),
            Fact(
                "Authentication response meta is correct",
                [
                    Response.Status = 200,
                    Headers = [
                        #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                    ],
                    RequestUrl = "dummy_url"
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestAuthenticateRaisesError = () =>
    let
        AssertErrorisRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeAuthResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ]),
                facts = TestErrorIsRaised(
                    try
                        Authenticate(
                            "dummy_url", [
                                Username = "dummy",
                                Password = "pwd"
                            ], [
                                AuthResponse = fakeAuthResponse
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
            {401, "Authentication Error", "Something went wrong while authenticating"},
            {403, "Authorization Error", "Not authorized to access the given resource"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorisRaised)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestAuthenticateIsSuccessful(), TestAuthenticateRaisesError()},
    report = Facts.Summarize(facts)
][report];
