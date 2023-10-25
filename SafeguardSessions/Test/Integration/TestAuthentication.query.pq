section TestSafeguardSessions.Authentication;

TestSafeguardSessions.URL = "dummy_url";

TestSafeguardSessions.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestAuthenticateRaisesErrorForStatusCode = (statusCode as number, expectedReason as text, expectedMessage as text) =>
    let
        fakeAuthResponse = FakeRawResponse([#"error" = "reason"], [
            Response.Status = statusCode
        ]),
        facts = AssertErrorIsRaised(
            Text.Format("Error is raised for status code [#StatusCode]", [StatusCode = statusCode]),
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
        AssertAuthenticationFailure = (
            errorCode as number, statusCode as number, expectedReason as text, expectedMessage as text
        ) =>
            let
                fakeAuthResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ])
            in
                AssertError(
                    "Error is raised if error response is received",
                    Authenticate,
                    {
                        TestSafeguardSessions.URL,
                        TestSafeguardSessions.AuthenticationCredentials,
                        [
                            AuthResponse = fakeAuthResponse
                        ]
                    },
                    [
                        Reason = expectedReason,
                        Message = expectedMessage,
                        Detail = [
                            ManuallyHandled = true,
                            Cause = [#"error" = "reason"],
                            RequestUrl = "http://dummy_url/api/authentication",
                            ErrorCode = errorCode
                        ]
                    ]
                ),
        cases = {
            {
                4010,
                401,
                "Authentication Error",
                "Error 4010: The username or password you have specified is invalid."
            },
            {
                4030,
                403,
                "Authorization Error",
                "Error 4030: You are not authorized to access the specified resource."
            },
            {5000, 500, "Server Error", "Error 5000: The source IP responded with a server error."}
        },
        facts = ProvideDataForTest(cases, AssertAuthenticationFailure)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestAuthenticateIsSuccessful(), TestAuthenticateRaisesError()},
    report = Summarize(facts)
][report];
