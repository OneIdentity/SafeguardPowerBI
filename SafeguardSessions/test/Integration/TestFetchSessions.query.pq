section TestSafeguardSessions;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

TestFetchSessionsWithDateInputs = () =>
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
            "https://dummy_url/api/audit/sessions?fields=%2A&start=2023-01-01T00%3A00%3A00.0000000%2B00%3A00&end=2023-01-15T00%3A00%3A00.0000000%2B00%3A00"
        ),
        response = FetchSessions(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            #datetimezone(2023, 1, 1, 0, 0, 0, 0, 0),
            #datetimezone(2023, 1, 15, 0, 0, 0, 0, 0),
            null,
            null,
            null,
            null,
            null,
            null,
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestFetchSessionsWithFilterFieldValueInputPairs = () =>
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
            "https://dummy_url/api/audit/sessions?fields=%2A&q=protocol%3ASSH%20AND%20user.name%3Abalabit"
        ),
        response = FetchSessions(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            null,
            null,
            "protocol",
            "SSH",
            "user.name",
            "balabit",
            null,
            null,
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestFetchSessionsWithOnlyOneFilterValueInput = () =>
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
        response = FetchSessions(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            null,
            null,
            null,
            "SSH",
            null,
            null,
            null,
            null,
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestFetchSessionsWithOnlyOneFilterFieldInput = () =>
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
        expected_result = [
            HasError = true,
            Error = [
                Reason = "Bad search filter input",
                Message = "Filter field was given without value",
                Detail = [ManuallyHandled = false, Cause = "protocol", RequestUrl = null],
                Message.Format = null,
                Message.Parameters = null
            ]
        ],
        response =
            try
                (
                    FetchSessions(
                        "dummy_url",
                        [
                            Username = "dummy",
                            Password = "pwd"
                        ],
                        null,
                        null,
                        "protocol",
                        null,
                        null,
                        null,
                        null,
                        null,
                        [
                            AuthResponse = fake_auth_response
                        ]
                    )
                )
    in
        Fact("Check error is raised", expected_result, response);

TestFetchSessionsWithInvalidFilterFieldValueInputPair = () =>
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
        fake_response = FakeRawResponse("{""error"": ""value""}", [Response.Status = 400]),
        expected_data = [
            Reason = "Bad Request",
            Message = "SPS interpreted a malformed request",
            Detail = [
                ManuallyHandled = true,
                Cause = [#"error" = "value"],
                RequestUrl = "https://dummy_url/api/audit/sessions?fields=%2A&q=apple%3Apeach"
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error",
            "SPS interpreted a malformed request",
            null,
            0,
            true,
            "https://dummy_url/api/audit/sessions?fields=%2A&q=apple%3Apeach"
        ),
        response = FetchSessions(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            null,
            null,
            "apple",
            "peach",
            null,
            null,
            null,
            null,
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

shared TestSafeguardSessions.UnitTest = [
    facts = {
        TestFetchSessionsWithDateInputs(),
        TestFetchSessionsWithFilterFieldValueInputPairs(),
        TestFetchSessionsWithOnlyOneFilterValueInput(),
        TestFetchSessionsWithOnlyOneFilterFieldInput(),
        TestFetchSessionsWithInvalidFilterFieldValueInputPair()
    },
    report = Facts.Summarize(facts)
][report];
