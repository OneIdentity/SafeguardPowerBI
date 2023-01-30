section TestSafeguardSessions;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

TestResultsContentWithoutStartTime = (response as record, expected_data as any, expected_info as table) =>
    let
        facts = {
            Fact("Data content of response matches", expected_data, response[SessionData]),
            TestFetchInfoContentWithoutStartTime(expected_info, response[FetchInfo])
        }
    in
        facts;

TestGetDataWithoutError = () =>
    let
        fake_auth_response = FakeResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}"),
        expected_data = #table(type table [dummy_field = any, dummy_list = any], {{"value", {0, 1, 2}}}),
        expected_info = FetchInfo(
            "Success", "Data fetch succeeded", null, 1, false, "https://dummy_url/api/audit/sessions"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataHandlesAuthenticationError = () =>
    let
        fake_auth_response = FakeResponse("{""error"": ""value""}", [
            Response.Status = 401
        ]),
        expected_data = [
            Reason = "Authentication Error",
            Message = "Something went wrong while authenticating",
            Detail = [#"error" = "value"],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error", "Something went wrong while authenticating", null, 0, true,
            "https://dummy_url/api/authentication"
        ),
        response = GetData("dummy_url", [
            Username = "dummy",
            Password = "pwd"
        ], [
            AuthResponse = fake_auth_response
        ])
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataHandlesBadRequest = () =>
    let
        fake_auth_response = FakeResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeResponse("{""error"": ""value""}", [Response.Status = 500]),
        expected_data = [
            Reason = "General Error",
            Message = "SPS responded with server error",
            Detail = [#"error" = "value"],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error", "SPS responded with server error", null, 0, true, "https://dummy_url/api/audit/sessions"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestAuthenticateIsSuccessful = () =>
    let
        fake_auth_response = FakeResponse(
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
                    ]
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestAuthenticateRaisesErrorForStatusCode = (status_code as number, expected_reason as text, expected_message as text) =>
    let
        fake_auth_response = FakeResponse("{""error"": ""reason""}", [
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
                #"error" = "reason"
            ]
        )
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

TestFetchDataIsSuccessful = () =>
    let
        fake_response = FakeResponse(
            "{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}", [Response.Status = 200]
        ),
        response = FetchData(
            "dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
                FetchResponse = fake_response
            ]
        ),
        facts = {
            Fact("Data fetch response is correct", [dummy_field = "value", dummy_list = {0, 1, 2}], response),
            Fact("Test data fetch meta is correct", [Response.Status = 200], Value.Metadata(response))
        }
    in
        facts;

TestFetchDataRaisesErrorForStatusCode = (status_code as number, expected_reason as text, expected_message as text) =>
    let
        fake_response = FakeResponse("{""error"": ""reason""}", [
            Response.Status = status_code
        ]),
        facts = TestErrorIsRaised(
            try FetchData("dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
                FetchResponse = fake_response
            ]),
            expected_reason,
            expected_message,
            [
                #"error" = "reason"
            ]
        )
    in
        facts;

TestFetchDataRaisesError = () =>
    let
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "Something went wrong while authenticating"},
            {403, "Authorization Error", "Not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {429, "Snapshot Quota Error", "Snapshot quota exceeded"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, TestFetchDataRaisesErrorForStatusCode)
    in
        facts;

shared TestSafeguardSessions.UnitTest = [
    facts = {
        TestGetDataWithoutError(),
        TestGetDataHandlesAuthenticationError(),
        TestGetDataHandlesBadRequest(),
        TestAuthenticateIsSuccessful(),
        TestAuthenticateRaisesError(),
        TestFetchDataIsSuccessful(),
        TestFetchDataRaisesError()
    },
    report = Facts.Summarize(facts)
][report];
