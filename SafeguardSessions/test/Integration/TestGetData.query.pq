section TestSafeguardSessions.GetData;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

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
            "Success", "Data fetch succeeded", null, 1, false, "https://dummy_url/api/audit/sessions?fields=%2A"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataWithQueryInputs = () =>
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
            "Success",
            "Data fetch succeeded",
            null,
            1,
            false,
            "https://dummy_url/api/audit/sessions?fields=%2A&start=2023.1.1&end=2023.1.31&q=protcol%3ASSh%20AND%20user.name%3Abalabit"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [
                start = "2023.1.1",
                end = "2023.1.31",
                q = "protcol:SSh AND user.name:balabit"
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
            Detail = [
                ManuallyHandled = true,
                Cause = [#"error" = "value"],
                RequestUrl = "https://dummy_url/api/authentication"
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error", "Something went wrong while authenticating", null, 0, true,
            "https://dummy_url/api/authentication"
        ),
        response = GetData(
            "dummy_url", [
                Username = "dummy",
                Password = "pwd"
            ], [], [
                AuthResponse = fake_auth_response
            ]
        )
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
            Detail = [
                ManuallyHandled = true,
                Cause = [#"error" = "value"],
                RequestUrl = "https://dummy_url/api/audit/sessions?fields=%2A"
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error", "SPS responded with server error", null, 0, true,
            "https://dummy_url/api/audit/sessions?fields=%2A"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth = () =>
    let
        errorRecord = [
            Reason = "A corner case",
            Message = "This is an error no-one expects",
            Detail = [
                ManuallyHandled = true,
                Cause = [#"error" = "value"]
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        error_mock = [Value = error errorRecord],
        expected_info = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData("dummy_url", [
            Username = "dummy",
            Password = "pwd"
        ], [], [Authenticate = error_mock])
    in
        TestResultsContentWithoutStartTime(response, errorRecord, expected_info);

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
        errorRecord = [
            Reason = "A corner case",
            Message = "This is an error no-one expects",
            Detail = [
                ManuallyHandled = true,
                Cause = [#"error" = "value"]
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        error_mock = [Value = error errorRecord],
        expected_info = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [],
            [
                AuthResponse = fake_auth_response,
                FetchData = error_mock
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, errorRecord, expected_info);

TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringAuthenication = () =>
    let
        unexpectedErrorRecord = [
            Reason = "Wrong variable",
            Message = "Variable type mismatch error",
            Detail = "The variable badVariable is of the type text, but it should be of the type number"
        ],
        error_mock = [Value = error unexpectedErrorRecord],
        expected_response = [
            HasError = true,
            Error = [
                Reason = "Wrong variable",
                Message = "Variable type mismatch error",
                Detail = "The variable badVariable is of the type text, but it should be of the type number",
                Message.Format = null,
                Message.Parameters = null
            ]
        ],
        response =
            try (GetData("dummy_url", [
                Username = "dummy",
                Password = "pwd"
            ], [], [Authenticate = error_mock]))
    in
        Fact("Check error is raised", expected_response, response);

TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringDataFetch = () =>
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
        unexpectedErrorRecord = [
            Reason = "Wrong variable",
            Message = "Variable type mismatch error",
            Detail = "The variable badVariable is of the type text, but it should be of the type number"
        ],
        error_mock = [Value = error unexpectedErrorRecord],
        expected_response = [
            HasError = true,
            Error = [
                Reason = "Wrong variable",
                Message = "Variable type mismatch error",
                Detail = "The variable badVariable is of the type text, but it should be of the type number",
                Message.Format = null,
                Message.Parameters = null
            ]
        ],
        response =
            try
                (
                    GetData(
                        "dummy_url",
                        [
                            Username = "dummy",
                            Password = "pwd"
                        ],
                        [],
                        [
                            AuthResponse = fake_auth_response,
                            FetchData = error_mock
                        ]
                    )
                )
    in
        Fact("Check error is raised", expected_response, response);

shared TestSafeguardSessions.Integration = [
    facts = {
        TestGetDataWithoutError(),
        TestGetDataWithQueryInputs(),
        TestGetDataHandlesAuthenticationError(),
        TestGetDataHandlesBadRequest(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringAuthenication(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringDataFetch()
    },
    report = Facts.Summarize(facts)
][report];
