section TestSafeguardSessions;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");
CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

TestSafeguardSessions.URL = "dummy_url";

TestSafeguardSessions.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestSafeguardSessions.SuccessfulAuthentication = FakeRawResponse(
    "{}",
    [
        Response.Status = 200,
        Headers = [
            #"Set-Cookie" = "session_id=e8e5f0a0d3367043150187f81df3484e91e365d5; expires=Sat, 03 Dec 2022 02:27:48 GMT; HttpOnly; Max-Age=43200; Path=/; Secure"
        ]
    ]
);

TestSafeguardSessions.SubTables = {"user"};

TestSafeguardSessions.Schema = [
    sessions = CreateSchema(
        {
            {"session_id", type text},
            {"start", type datetimezone},
            {"end", type datetimezone},
            {"protocol", type text}
        }
    ),
    sessions.user = CreateSchema({{"sessions.user_id", type number}, {"user.name", type text}}),
    sessions.user_to_sessions = CreateSchema({{"session_id", type text}, {"sessions.user_id", type number}})
];

TestSafeguardSessions.Mocks = [
    AuthResponse = TestSafeguardSessions.SuccessfulAuthentication,
    SubTables = TestSafeguardSessions.SubTables,
    Schema = TestSafeguardSessions.Schema
];

TestFetchSessionsWithDateInputs = () =>
    let
        fetchResponse = FakeRawResponse(
            Json.FromRecord(
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
        ),
        expectedData = #table(
            type table [Name = any, Data = any],
            {
                {
                    "sessions",
                    #table(
                        type table [session_id = text, start = datetimezone, end = datetimezone, protocol = text],
                        {
                            {
                                "id1",
                                #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                "SSH"
                            },
                            {
                                "id2",
                                #datetimezone(2023, 1, 14, 22, 11, 33, 0, 0),
                                #datetimezone(2023, 1, 16, 2, 3, 12, 0, 0),
                                "RDP"
                            }
                        }
                    )
                },
                {
                    "sessions.user",
                    #table(
                        type table [sessions.user_id = number, user.name = text],
                        {{1, "other_username"}, {2, "username"}}
                    )
                },
                {
                    "sessions.user_to_sessions",
                    #table(type table [session_id = text, sessions.user_id = number], {{"id2", 1}, {"id1", 2}})
                }
            }
        ),
        expectedInfo = FetchInfo(
            "Success",
            "Data fetch succeeded",
            null,
            2,
            false,
            "https://dummy_url/api/audit/sessions?fields=%2A&start=2023-01-01T00%3A00%3A00.0000000%2B00%3A00&end=2023-01-15T00%3A00%3A00.0000000%2B00%3A00"
        ),
        response = FetchSessions(
            TestSafeguardSessions.URL,
            TestSafeguardSessions.AuthenticationCredentials,
            #datetimezone(2023, 1, 1, 0, 0, 0, 0, 0),
            #datetimezone(2023, 1, 15, 0, 0, 0, 0, 0),
            null,
            null,
            null,
            null,
            null,
            null,
            [
                FetchResponse = fetchResponse
            ] & TestSafeguardSessions.Mocks
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestFetchSessionsWithFilterFieldValueInputPairs = () =>
    let
        fetchResponse = FakeRawResponse(
            Json.FromRecord(
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
        ),
        expectedData = #table(
            type table [Name = any, Data = any],
            {
                {
                    "sessions",
                    #table(
                        type table [session_id = text, start = datetimezone, end = datetimezone, protocol = text],
                        {
                            {
                                "id1",
                                #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                "SSH"
                            }
                        }
                    )
                },
                {"sessions.user", #table(type table [sessions.user_id = number, user.name = text], {{1, "balabit"}})},
                {
                    "sessions.user_to_sessions",
                    #table(type table [session_id = text, sessions.user_id = number], {{"id1", 1}})
                }
            }
        ),
        expectedInfo = FetchInfo(
            "Success",
            "Data fetch succeeded",
            null,
            1,
            false,
            "https://dummy_url/api/audit/sessions?fields=%2A&q=protocol%3ASSH%20AND%20user.name%3Abalabit"
        ),
        response = FetchSessions(
            TestSafeguardSessions.URL,
            TestSafeguardSessions.AuthenticationCredentials,
            null,
            null,
            "protocol",
            "SSH",
            "user.name",
            "balabit",
            null,
            null,
            [
                FetchResponse = fetchResponse
            ] & TestSafeguardSessions.Mocks
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

TestFetchSessionsWithOnlyOneFilterValueInput = () =>
    let
        fetchResponse = FakeRawResponse(
            Json.FromRecord(
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
        ),
        expectedData = #table(
            type table [Name = any, Data = any],
            {
                {
                    "sessions",
                    #table(
                        type table [session_id = text, start = datetimezone, end = datetimezone, protocol = text],
                        {
                            {
                                "id1",
                                #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
                                #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
                                "SSH"
                            }
                        }
                    )
                },
                {"sessions.user", #table(type table [sessions.user_id = number, user.name = text], {{1, "username"}})},
                {
                    "sessions.user_to_sessions",
                    #table(type table [session_id = text, sessions.user_id = number], {{"id1", 1}})
                }
            }
        ),
        expectedInfo = FetchInfo(
            "Success", "Data fetch succeeded", null, 1, false, "https://dummy_url/api/audit/sessions?fields=%2A"
        ),
        response = FetchSessions(
            TestSafeguardSessions.URL,
            TestSafeguardSessions.AuthenticationCredentials,
            null,
            null,
            null,
            "SSH",
            null,
            null,
            null,
            null,
            [
                FetchResponse = fetchResponse
            ] & TestSafeguardSessions.Mocks
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

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
                            AuthResponse = TestSafeguardSessions.SuccessfulAuthentication
                        ]
                    )
                )
    in
        Fact("Check error is raised", expectedResult, response);

TestFetchSessionsWithInvalidFilterFieldValueInputPair = () =>
    let
        fetchResponse = FakeRawResponse("{""error"": ""value""}", [Response.Status = 400]),
        expectedData = [
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
        expectedInfo = FetchInfo(
            "Error",
            "SPS interpreted a malformed request",
            null,
            0,
            true,
            "https://dummy_url/api/audit/sessions?fields=%2A&q=apple%3Apeach"
        ),
        response = FetchSessions(
            TestSafeguardSessions.URL,
            TestSafeguardSessions.AuthenticationCredentials,
            null,
            null,
            "apple",
            "peach",
            null,
            null,
            null,
            null,
            [
                AuthResponse = TestSafeguardSessions.SuccessfulAuthentication,
                FetchResponse = fetchResponse
            ]
        )
    in
        TestResultsContentWithoutStartTime(response, expectedData, expectedInfo);

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
