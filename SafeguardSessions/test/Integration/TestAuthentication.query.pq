section TestSafeguardSessions.Authentication;

TestSafeguardSessions.URL = "dummy_url";

TestSafeguardSessions.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestAuthenticateRaisesErrorForStatusCode = (status_code as number, expectedReason as text, expectedMessage as text) =>
    let
        fakeAuthResponse = FakeRawResponse([#"error" = "reason"], [
            Response.Status = status_code
        ]),
        facts = TestErrorIsRaised(
            try
                Authenticate(
                    TestSafeguardSessions.URL,
                    TestSafeguardSessions.AuthenticationCredentials,
                    [
                        AuthResponse = fakeAuthResponse
                    ]
                ),
            expectedReason,
            expectedMessage,
            [
                ManuallyHandled = true,
                Cause = [#"error" = "reason"],
                RequestUrl = "http://dummy_url/api/authentication"
            ]
        )
    in
        facts;

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
            TestSafeguardSessions.URL,
            TestSafeguardSessions.AuthenticationCredentials,
            [
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
                    RequestUrl = "http://dummy_url/api/authentication"
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
                            TestSafeguardSessions.URL,
                            TestSafeguardSessions.AuthenticationCredentials,
                            [
                                AuthResponse = fakeAuthResponse
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/authentication"
                    ]
                )
            in
                facts,
        cases = {
            {401, "Authentication Error", "The username or password is invalid"},
            {403, "Authorization Error", "You are not authorized to access the given resource"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorisRaised)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestAuthenticateIsSuccessful(), TestAuthenticateRaisesError()},
    report = Facts.Summarize(facts)
][report];
