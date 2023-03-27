section TestSafeguardSessions.GetData;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

TestSafeguardSessions.SuccessfulAuthenticationResponse = FakeRawResponse(
    [],
    [
        Response.Status = 200,
        Headers = [
            #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
        ]
    ]
);

TestSafeguardSessions.ActualResponseData = UnitTestFramework.ImportFunction("FakeResponse", "GetDataAsset.pqm");

TestSafeguardSessions.ExpectedDataForActualResponse = UnitTestFramework.ImportFunction(
    "ExpectedData", "GetDataAsset.pqm"
);

TestSafeguardSessions.ActualResponse = FakeRawResponse(TestSafeguardSessions.ActualResponseData);

TestEmptyResponseIsHandled = () =>
    let
        fetchResponse = FakeRawResponse([
            items = {},
            #"meta" = []
        ]),
        expectedData = #table(
            type table [
                session_id = text,
                subtable.field1 = number,
                subtable.field2 = text,
                flatvalue1 = number,
                flatvalue2 = logical
            ],
            {}
        ),
        expectedInfo = FetchInfo(
            "Success", "Data fetch succeeded", null, 0, false, "https://dummy_url/api/audit/sessions?fields=%2A"
        ),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [],
            [
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchResponse = fetchResponse,
                Schema = [
                    Sessions = CreateSchema(
                        {
                            {"session_id", type text},
                            {"subtable.field1", type number},
                            {"subtable.field2", type text},
                            {"flatvalue1", type number},
                            {"flatvalue2", type logical}
                        }
                    )
                ]
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestGetDataWithoutError = () =>
    let
        fetchResponse = FakeRawResponse(
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
        ),
        expectedData = #table(
            type table [
                session_id = text,
                subtable.field1 = number,
                subtable.field2 = text,
                flatvalue1 = number,
                flatvalue2 = logical
            ],
            {{"id1", 1, "value1", 1, true}, {"id2", 2, "value2", 2, false}}
        ),
        expectedInfo = FetchInfo(
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
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchResponse = fetchResponse,
                Schema = [
                    Sessions = CreateSchema(
                        {
                            {"session_id", type text},
                            {"subtable.field1", type number},
                            {"subtable.field2", type text},
                            {"flatvalue1", type number},
                            {"flatvalue2", type logical}
                        }
                    )
                ]
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestGetDataWithQueryInputs = () =>
    let
        fetchResponse = FakeRawResponse(
            [
                items = {[
                    body = [dummy = "value"],
                    key = "id",
                    #"meta" = []
                ]},
                #"meta" = []
            ]
        ),
        expectedData = #table(type table [session_id = text, dummy = text], {{"id", "value"}}),
        expectedInfo = FetchInfo(
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
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchResponse = fetchResponse,
                Schema = [
                    Sessions = CreateSchema({{"session_id", type text}, {"dummy", type text}})
                ]
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestGetDataHandlesAuthenticationError = () =>
    let
        fakeAuthResponse = FakeRawResponse([#"error" = "value"], [
            Response.Status = 401
        ]),
        expectedData = [
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
        expectedInfo = FetchInfo(
            "Error", "Something went wrong while authenticating", null, 0, true,
            "https://dummy_url/api/authentication"
        ),
        response = GetData(
            "dummy_url", [
                Username = "dummy",
                Password = "pwd"
            ], [], [
                AuthResponse = fakeAuthResponse
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestGetDataHandlesBadRequest = () =>
    let
        fetchResponse = FakeRawResponse([#"error" = "value"], [Response.Status = 500]),
        expectedData = [
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
        expectedInfo = FetchInfo(
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
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchResponse = fetchResponse
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

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
        errorMock = [Value = error errorRecord],
        expectedInfo = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData("dummy_url", [
            Username = "dummy",
            Password = "pwd"
        ], [], [Authenticate = errorMock])
    in
        TestResultsContentWithoutStartTime(response, errorRecord, expectedInfo);

TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch = () =>
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
        errorMock = [Value = error errorRecord],
        expectedInfo = FetchInfo("Error", "This is an error no-one expects", null, 0, true, "N/A"),
        response = GetData(
            "dummy_url",
            [
                Username = "dummy",
                Password = "pwd"
            ],
            [],
            [
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchData = errorMock
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, errorRecord, expectedInfo);

TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringAuthenication = () =>
    let
        unexpectedErrorRecord = [
            Reason = "Wrong variable",
            Message = "Variable type mismatch error",
            Detail = "The variable badVariable is of the type text, but it should be of the type number"
        ],
        errorMock = [Value = error unexpectedErrorRecord],
        expectedResponse = [
            HasError = true,
            Error = [
                Reason = "Wrong variable",
                Message = "Variable type mismatch error",
                Detail = "The variable badVariable is of the type text, but it should be of the type number",
                Message.Format = null,
                Message.Parameters = null
            ]
        ],
        response = try (GetData("dummy_url", [
            Username = "dummy",
            Password = "pwd"
        ], [], [Authenticate = errorMock]))
    in
        Fact("Check error is raised", expectedResponse, response);

TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringDataFetch = () =>
    let
        unexpectedErrorRecord = [
            Reason = "Wrong variable",
            Message = "Variable type mismatch error",
            Detail = "The variable badVariable is of the type text, but it should be of the type number"
        ],
        errorMock = [Value = error unexpectedErrorRecord],
        expectedResponse = [
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
                            AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                            FetchData = errorMock
                        ]
                    )
                )
    in
        Fact("Check error is raised", expectedResponse, response);

TestGetDataWithActualData = () =>
    let
        expectedData = TestSafeguardSessions.ExpectedDataForActualResponse,
        expectedInfo = FetchInfo(
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
                AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                FetchResponse = TestSafeguardSessions.ActualResponse
            ]
        )
    in
        TestResultsContentWithoutStartTime(
            response, TestSafeguardSessions.ExpectedDataForActualResponse, expectedInfo
        );

shared TestSafeguardSessions.IntegrationTest = [
    facts = {
        TestEmptyResponseIsHandled(),
        TestGetDataWithoutError(),
        TestGetDataWithQueryInputs(),
        TestGetDataHandlesAuthenticationError(),
        TestGetDataHandlesBadRequest(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringAuth(),
        TestGetDataHandlesErrorWithoutRequestUrlInErrorDetailDuringDataFetch(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringAuthenication(),
        TestGetDataReturnWithAnUnexpectedErrorBecauseSomethingUnexpectedHappendDuringDataFetch(),
        TestGetDataWithActualData()
    },
    report = Facts.Summarize(facts)
][report];
