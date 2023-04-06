section TestSafeguardSessions;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

TestSafeguardSessions.URL = "dummy_url";

TestSafeguardSessions.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestSafeguardSessions.SuccessfulAuthenticationResponse = FakeRawResponse(
    [],
    [
        Response.Status = 200,
        Headers = [
            #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
        ]
    ]
);

TestSafeguardSessions.SubTables = {"user"};

TestSafeguardSessions.Schema = [
    Sessions = CreateSchema(
        {
            {"session_id", type text},
            {"start", type datetimezone},
            {"end", type datetimezone},
            {"protocol", type text},
            {"user.name", type text}
        }
    )
];

TestSafeguardSessions.Mocks = [
    AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
    SubTables = TestSafeguardSessions.SubTables,
    Schema = TestSafeguardSessions.Schema
];

TestFetchSessionsWithOnlyOneFilterFieldInput = () =>
    let
        expectedResult = [
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
                        TestSafeguardSessions.URL,
                        TestSafeguardSessions.AuthenticationCredentials,
                        null,
                        null,
                        "protocol",
                        null,
                        null,
                        null,
                        null,
                        null,
                        [
                            AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse
                        ]
                    )
                )
    in
        Fact("Check error is raised", expectedResult, response);

TestFetchingSessions = () =>
    let
        AssertFetching = (description as text, args as list, mocks as record, expectedData, expectedInfo) as list =>
            let
                response = Function.Invoke(
                    FetchSessions,
                    List.Combine(
                        {{TestSafeguardSessions.URL, TestSafeguardSessions.AuthenticationCredentials}, args, {mocks}}
                    )
                )
            in
                TestResultsContentWithoutStartTime(response, expectedData, expectedInfo),
        cases = {
            {
                "Fetching sessions with date inputs",
                {
                    #datetimezone(2023, 1, 1, 0, 0, 0, 0, 0),
                    #datetimezone(2023, 1, 15, 0, 0, 0, 0, 0),
                    null,
                    null,
                    null,
                    null,
                    null,
                    null
                },
                [
                    FetchResponse = FakeRawResponse(
                        [
                            items = {
                                [
                                    body = [
                                        start = #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                        end = #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                        protocol = "SSH",
                                        user = [name = "balabit"]
                                    ],
                                    key = "id1",
                                    #"meta" = []
                                ],
                                [
                                    body = [
                                        start = #datetimezone(2023, 1, 14, 22, 11, 33, 0, 0),
                                        end = #datetimezone(2023, 1, 16, 2, 3, 12, 0, 0),
                                        protocol = "RDP",
                                        user = [name = "other_username"]
                                    ],
                                    key = "id2",
                                    #"meta" = []
                                ]
                            },
                            #"meta" = []
                        ]
                    )
                ]
                    & TestSafeguardSessions.Mocks,
                #table(
                    type table [
                        session_id = text, start = datetimezone, end = datetimezone, protocol = text, user.name = text
                    ],
                    {
                        {
                            "id1",
                            #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                            #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                            "SSH",
                            "balabit"
                        },
                        {
                            "id2",
                            #datetimezone(2023, 1, 14, 22, 11, 33, 0, 0),
                            #datetimezone(2023, 1, 16, 2, 3, 12, 0, 0),
                            "RDP",
                            "other_username"
                        }
                    }
                ),
                FetchInfo(
                    "Success",
                    "Data fetch succeeded",
                    null,
                    2,
                    false,
                    "https://dummy_url/api/audit/sessions?fields=%2A&start=2023-01-01T00%3A00%3A00.0000000%2B00%3A00&end=2023-01-15T00%3A00%3A00.0000000%2B00%3A00"
                )
            },
            {
                "Fetching sessions with field-value pairs",
                {null, null, "protocol", "SSH", "user.name", "balabit", null, null},
                [
                    FetchResponse = FakeRawResponse(
                        [
                            items = {
                                [
                                    body = [
                                        start = #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                        end = #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                        protocol = "SSH",
                                        user = [name = "balabit"]
                                    ],
                                    key = "id1",
                                    #"meta" = []
                                ]
                            },
                            #"meta" = []
                        ]
                    )
                ]
                    & TestSafeguardSessions.Mocks,
                #table(
                    type table [
                        session_id = text, start = datetimezone, end = datetimezone, protocol = text, user.name = text
                    ],
                    {
                        {
                            "id1",
                            #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                            #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                            "SSH",
                            "balabit"
                        }
                    }
                ),
                FetchInfo(
                    "Success",
                    "Data fetch succeeded",
                    null,
                    1,
                    false,
                    "https://dummy_url/api/audit/sessions?fields=%2A&q=protocol%3ASSH%20AND%20user.name%3Abalabit"
                )
            },
            {
                "Fetching sessions with only filter value",
                {null, null, null, "SSH", null, null, null, null},
                [
                    FetchResponse = FakeRawResponse(
                        [
                            items = {
                                [
                                    body = [
                                        start = #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                        end = #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                        protocol = "SSH",
                                        user = [name = "username"]
                                    ],
                                    key = "id1",
                                    #"meta" = []
                                ]
                            },
                            #"meta" = []
                        ]
                    )
                ]
                    & TestSafeguardSessions.Mocks,
                #table(
                    type table [
                        session_id = text, start = datetimezone, end = datetimezone, protocol = text, user.name = text
                    ],
                    {
                        {
                            "id1",
                            #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                            #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                            "SSH",
                            "username"
                        }
                    }
                ),
                FetchInfo(
                    "Success", "Data fetch succeeded", null, 1, false,
                    "https://dummy_url/api/audit/sessions?fields=%2A"
                )
            },
            {
                "Fetching sessions with invalid field-value pair",
                {null, null, "apple", "peach", null, null, null, null},
                [
                    AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                    FetchResponse = FakeRawResponse([#"error" = "value"], [Response.Status = 400])
                ],
                [
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
                FetchInfo(
                    "Error",
                    "SPS interpreted a malformed request",
                    null,
                    0,
                    true,
                    "https://dummy_url/api/audit/sessions?fields=%2A&q=apple%3Apeach"
                )
            }
        },
        facts = ProvideDataForTest(cases, AssertFetching)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestFetchingSessions(), TestFetchSessionsWithOnlyOneFilterFieldInput()},
    report = Facts.Summarize(facts)
][report];
