section TestSafeguardSessions.Authentication;

TestAuthenticateRaisesErrorForStatusCode = (status_code as number, expected_reason as text, expected_message as text) =>
    let
        fake_auth_response = FakeRawResponse("{""error"": ""reason""}", [
            Response.Status = status_code
        ]),
        facts = TestErrorIsRaised(
            try
                Authenticate(
                    "dummy_url", [
                        Username = "dummy",
                        Password = "pwd"
                    ], [
                        AuthResponse = fake_auth_response
                    ]
                ),
            expected_reason,
            expected_message,
            [
                ManuallyHandled = true,
                Cause = [#"error" = "reason"],
                RequestUrl = "dummy_url"
            ]
        )
    in
        facts;

TestAuthenticateIsSuccessful = () =>
    let
        fake_auth_response = FakeRawResponse(
            "{}",
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
                AuthResponse = fake_auth_response
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
        cases = {
            {401, "Authentication Error", "Something went wrong while authenticating"},
            {403, "Authorization Error", "Not authorized to access the given resource"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, TestAuthenticateRaisesErrorForStatusCode)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestAuthenticateIsSuccessful(), TestAuthenticateRaisesError()},
    report = Facts.Summarize(facts)
][report];
