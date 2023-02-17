section TestSafeguardSessions.GetData;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

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
        fake_response = FakeRawResponse(
            Json.FromRecord(
                [
                    items = {
                        [
                            body = [
                                subtable = [field1 = 1, field2 = "value1"],
                                flatvalue1 = 1,
                                flatvalue2 = true
                            ],
                            key = "id1",
                            #"meta" = []
                        ],
                        [
                            body = [
                                subtable = [field1 = 2, field2 = "value2"],
                                flatvalue1 = 2,
                                flatvalue2 = false
                            ],
                            key = "id2",
                            #"meta" = []
                        ]
                    },
                    #"meta" = []
                ]
            )
        ),
        expected_data = #table(
            type table [Name = any, Data = any],
            {
                {
                    "sessions",
                    #table(
                        type table [session_id = text, flatvalue1 = number, flatvalue2 = logical],
                        {{"id1", 1, true}, {"id2", 2, false}}
                    )
                },
                {
                    "sessions.subtable",
                    #table(
                        type table [sessions.subtable_id = number, subtable.field1 = number, subtable.field2 = text],
                        {{1, 1, "value1"}, {2, 2, "value2"}}
                    )
                },
                {
                    "sessions.subtable_to_sessions",
                    #table(type table [session_id = text, sessions.subtable_id = number], {{"id1", 1}, {"id2", 2}})
                }
            }
        ),
        expected_info = FetchInfo(
            "Success", "Data fetch succeeded", null, 2, false, "https://dummy_url/api/audit/sessions?fields=%2A"
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
                FetchResponse = fake_response,
                SubTables = {"subtable"},
                Schema = [
                    sessions = CreateSchema(
                        {{"session_id", type text}, {"flatvalue1", type number}, {"flatvalue2", type logical}}
                    ),
                    sessions.subtable = CreateSchema(
                        {
                            {"sessions.subtable_id", type number},
                            {"subtable.field1", type number},
                            {"subtable.field2", type text}
                        }
                    ),
                    sessions.subtable_to_sessions = CreateSchema(
                        {{"session_id", type text}, {"sessions.subtable_id", type number}}
                    )
                ]
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
        fake_response = FakeRawResponse(
            Json.FromRecord([
                items = {[
                    body = [dummy = "value"],
                    key = "id",
                    #"meta" = []
                ]},
                #"meta" = []
            ])
        ),
        expected_data = #table(
            type table [Name = any, Data = any],
            {{"sessions", #table(type table [session_id = text, dummy = text], {{"id", "value"}})}}
        ),
        expected_info = FetchInfo(
            "Success",
            "Data fetch succeeded",
            null,
            1,
            false,
            "https://dummy_url/api/audit/sessions?fields=%2A&start=2023.1.1&end=2023.1.31&q=protocol%3ASSh%20AND%20user.name%3Abalabit"
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
                q = "protocol:SSh AND user.name:balabit"
            ],
            [
                AuthResponse = fake_auth_response,
                FetchResponse = fake_response,
                SubTables = {},
                Schema = [
                    sessions = CreateSchema({{"session_id", type text}, {"dummy", type text}})
                ]
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataHandlesAuthenticationError = () =>
    let
        fake_auth_response = FakeRawResponse(Json.FromRecord([#"error" = "value"]), [
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
        fake_response = FakeRawResponse(Json.FromRecord([#"error" = "value"]), [Response.Status = 500]),
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

TestGetDataHandlesNormalizeError = () =>
    let
        // TODO: implement and actualize
        fake_auth_response = FakeRawResponse(
            "{}",
            [
                Response.Status = 200,
                Headers = [
                    #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
                ]
            ]
        ),
        fake_response = FakeRawResponse(
            Json.FromRecord(
                [
                    items = {
                        [
                            body = [
                                subtable = [field1 = 1, field2 = "value1"],
                                flatvalue1 = 1,
                                flatvalue2 = true
                            ],
                            key = "id1",
                            #"meta" = []
                        ],
                        [
                            body = [
                                subtable = [field1 = 2, field2 = "value2"],
                                flatvalue1 = 2,
                                flatvalue2 = false
                            ],
                            key = "id2",
                            #"meta" = []
                        ]
                    },
                    #"meta" = []
                ]
            )
        ),
        expected_data = [
            Reason = "Normalize Error",
            Message = "Something went wrong during normalization",
            Detail = [
                ManuallyHandled = true,
                Cause = "This is why there was an error",
                RequestUrl = "https://dummy_url/api/audit/sessions?fields=%2A"
            ],
            Message.Format = null,
            Message.Parameters = null
        ],
        expected_info = FetchInfo(
            "Error",
            "Something went wrong during normalization",
            null,
            0,
            true,
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
                FetchResponse = fake_response,
                SubTables = {"subtable"},
                Schema = [
                    sessions = CreateSchema({{"session_id", type text}, {"flatvalue1", type number}}),
                    sessions.subtable = CreateSchema(
                        {{"sessions.subtable_id", type number}, {"subtable.field1", type number}}
                    ),
                    sessions.subtable_to_sessions = CreateSchema(
                        {{"session_id", type text}, {"sessions.subtable_id", type number}}
                    )
                ],
                NormalizeResult = error
                    Error.Record(
                        "This is an error", "This is why there was an error", [Dummy = "Some dummy details"]
                    )
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expected_data, expected_info);

TestGetDataWithActualData = () =>
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
        fake_response = FakeRawResponse(
            Json.FromRecord(UnitTestFramework.ImportFunction("FakeResponse", "GetDataAsset.pqm"))
        ),
        expected_data = UnitTestFramework.ImportFunction("ExpectedData", "GetDataAsset.pqm"),
        expected_info = FetchInfo(
            "Success", "Data fetch succeeded", null, 25, false, "https://dummy_url/api/audit/sessions?fields=%2A"
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

shared TestSafeguardSessions.Integration = [
    facts = {
        TestGetDataWithoutError(),
        TestGetDataWithQueryInputs(),
        TestGetDataHandlesAuthenticationError(),
        TestGetDataHandlesBadRequest(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringAuthenication(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringDataFetch(),
        TestGetDataHandlesNormalizeError(),
        TestGetDataWithActualData()
    },
    report = Facts.Summarize(facts)
][report];
