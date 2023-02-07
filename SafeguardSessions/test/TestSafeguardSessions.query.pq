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
        fake_auth_response = FakeRawResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeRawResponse("{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}"),
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
        fake_auth_response = FakeRawResponse("{""error"": ""value""}", [
            Response.Status = 401
        ]),
        expected_data = [
            Reason = "Authentication Error",
            Message = "Something went wrong while authenticating",
            Detail = [Cause = [#"error" = "value"], RequestUrl = "https://dummy_url/api/authentication"],
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
        fake_auth_response = FakeRawResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeRawResponse("{""error"": ""value""}", [Response.Status = 500]),
        expected_data = [
            Reason = "General Error",
            Message = "SPS responded with server error",
            Detail = [Cause = [#"error" = "value"], RequestUrl = "https://dummy_url/api/audit/sessions"],
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

TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth = () =>
    let
        unexpected_error = [
            HasError = true,
            Error = [
                Reason = "A corner case",
                Message = "This is an error no-one expects",
                Detail = [Cause = [#"error" = "value"]]
            ]
        ],
        expected_info = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [Authenticate = unexpected_error]
        )
    in
        TestResultsContentWithoutStartTime(response, unexpected_error[Error], expected_info);

TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch = () =>
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
        unexpected_error = [
            HasError = true,
            Error = [
                Reason = "A corner case",
                Message = "This is an error no-one expects",
                Detail = [Cause = [#"error" = "value"]]
            ]
        ],
        expected_info = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [
                AuthResponse = fake_auth_response,
                FetchData = unexpected_error
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, unexpected_error[Error], expected_info);

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
                Cause = [#"error" = "reason"],
                RequestUrl = "dummy_url"
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
        fake_response = FakeRawResponse(
            "{""dummy_field"": ""value"", ""dummy_list"": [0, 1, 2]}", [Response.Status = 200]
        ),
        response = FetchData(
            "dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
                FetchResponse = fake_response
            ]
        ),
        facts = {
            Fact("Data fetch response is correct", [dummy_field = "value", dummy_list = {0, 1, 2}], response),
            Fact(
                "Test data fetch meta is correct",
                [Response.Status = 200, RequestUrl = "dummy_url"],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestFetchDataRaisesErrorForStatusCode = (status_code as number, expected_reason as text, expected_message as text) =>
    let
        fake_response = FakeRawResponse("{""error"": ""reason""}", [
            Response.Status = status_code
        ]),
        facts = TestErrorIsRaised(
            try FetchData("dummy_url", "e8e5f0a0d3367043150187f81df3484e91e365d5", [
                FetchResponse = fake_response
            ]),
            expected_reason,
            expected_message,
            [
                Cause = [#"error" = "reason"],
                RequestUrl = "dummy_url"
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
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch(),
        TestAuthenticateIsSuccessful(),
        TestAuthenticateRaisesError(),
        TestFetchDataIsSuccessful(),
        TestFetchDataRaisesError()
    },
    report = Facts.Summarize(facts)
][report];
