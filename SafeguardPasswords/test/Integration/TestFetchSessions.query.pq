section TestSafeguardSessions;

FetchInfo = Extension.ImportFunction("FetchInfo", "Utils.pqm");

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

SupportedVersions.LatestVersion = Extension.ImportFunction("LatestVersion", "SupportedVersions.pqm");

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

TestSafeguardSessions.InfoResponse = FakeRawResponse([
    body = [firmware_version = SupportedVersions.LatestVersion]
]);

TestSafeguardSessions.GetExpectedCountResponse = (optional expectedCount as number) =>
    FakeRawResponse([count = expectedCount ?? 0]);

TestSafeguardSessions.SuccessfulOpenSnapshotResponse = FakeRawResponse([
    body = [snapshot = "dummy_snapshot_id"]
]);

TestSafeguardSessions.FirstHit = [
    body = [
        start = #datetimezone(2022, 12, 31, 23, 59, 30, 0, 0),
        end = #datetimezone(2023, 1, 1, 7, 34, 11, 0, 0),
        protocol = "SSH",
        user = [name = "balabit"]
    ],
    key = "id1",
    #"meta" = []
];

TestSafeguardSessions.Response.SingleHit = FakeRawResponse(
    [
        items = {TestSafeguardSessions.FirstHit},
        #"meta" = [next = null]
    ]
);

TestSafeguardSessions.SecondHit = [
    body = [
        start = #datetimezone(2023, 1, 14, 22, 11, 33, 0, 0),
        end = #datetimezone(2023, 1, 16, 2, 3, 12, 0, 0),
        protocol = "RDP",
        user = [name = "other_username"]
    ],
    key = "id2",
    #"meta" = []
];

TestSafeguardSessions.Response.DoubleHit = FakeRawResponse(
    [
        items = {TestSafeguardSessions.FirstHit, TestSafeguardSessions.SecondHit},
        #"meta" = [next = null]
    ]
);

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
    InfoResponse = TestSafeguardSessions.InfoResponse,
    OpenSnapshotResponse = TestSafeguardSessions.SuccessfulOpenSnapshotResponse,
    Schema = TestSafeguardSessions.Schema
];

TestFetchSessionsWithOnlyOneFilterFieldInput = () =>
    let
        expectedResult = [
            HasError = true,
            Error = [
                Reason = "Filter Field Without Value",
                Message = "There is a field value missing from one or more of your filter fields.",
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
                        null,
                        [
                            AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                            InfoResponse = TestSafeguardSessions.InfoResponse
                        ]
                    )
                )
    in
        Fact("Check error is raised", expectedResult, response);

TestFetchingSessionsWithFromSPSWithUnsupportedVersion = () =>
    let
        infoResponse = FakeRawResponse([
            body = [firmware_version = "unsupported_version"]
        ]),
        expectedResult = [
            HasError = true,
            Error = [
                Reason = "Not Supported Version",
                Message = "Your version of the connector (v1.0.0+sps7.3.0) is not compatible with your SPS version (unsupported_version). For a connector version that is compatible with your SPS version, visit the official release page of the connector: https://github.com/OneIdentity/SafeguardPowerBI/releases",
                Detail = [Version = "unsupported_version", SupportedVersions = "7.3", ManuallyHandled = false],
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
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        [
                            AuthResponse = TestSafeguardSessions.SuccessfulAuthenticationResponse,
                            InfoResponse = infoResponse
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
                    null,
                    null
                },
                [
                    GetSessionsCountResponse = TestSafeguardSessions.GetExpectedCountResponse(2),
                    GetPageResponseMap = [
                        #"https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&start=2023-01-01T00%3A00%3A00.0000000%2B00%3A00&end=2023-01-15T00%3A00%3A00.0000000%2B00%3A00&snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.DoubleHit
                    ]
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
                    "Data fetch succeeded.",
                    null,
                    2,
                    false,
                    "https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&start=2023-01-01T00%3A00%3A00.0000000%2B00%3A00&end=2023-01-15T00%3A00%3A00.0000000%2B00%3A00&snapshot=dummy_snapshot_id"
                )
            },
            {
                "Fetching sessions with field-value pairs",
                {null, null, "protocol", "SSH", "user.name", "balabit", null, null, null},
                [
                    GetSessionsCountResponse = TestSafeguardSessions.GetExpectedCountResponse(1),
                    GetPageResponseMap = [
                        #"https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&q=protocol%3ASSH%20AND%20user.name%3Abalabit&snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.SingleHit
                    ]
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
                    "Data fetch succeeded.",
                    null,
                    1,
                    false,
                    "https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&q=protocol%3ASSH%20AND%20user.name%3Abalabit&snapshot=dummy_snapshot_id"
                )
            },
            {
                "Fetching sessions with only filter value",
                {null, null, null, "SSH", null, null, null, null, null},
                [
                    GetSessionsCountResponse = TestSafeguardSessions.GetExpectedCountResponse(1),
                    GetPageResponseMap = [
                        #"https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.SingleHit
                    ]
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
                    "Data fetch succeeded.",
                    null,
                    1,
                    false,
                    "https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&snapshot=dummy_snapshot_id"
                )
            },
            {
                "Fetching sessions with invalid field-value pair",
                {null, null, "apple", "peach", null, null, null, null, null},
                [
                    GetSessionsCountResponse = TestSafeguardSessions.GetExpectedCountResponse(),
                    GetPageResponseMap = [
                        #"https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&q=apple%3Apeach&snapshot=dummy_snapshot_id" = FakeRawResponse(
                            [#"error" = "value"], [Response.Status = 400]
                        )
                    ]
                ]
                    & TestSafeguardSessions.Mocks,
                [
                    Reason = "Bad Request",
                    Message = "The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                    Detail = [
                        ManuallyHandled = true,
                        Cause = [#"error" = "value"],
                        RequestUrl = "https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&q=apple%3Apeach&snapshot=dummy_snapshot_id"
                    ],
                    Message.Format = null,
                    Message.Parameters = null
                ],
                FetchInfo(
                    "Error",
                    "The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                    null,
                    0,
                    true,
                    "https://dummy_url/api/audit/sessions?fields=%2A&sort=-start_time&q=apple%3Apeach&snapshot=dummy_snapshot_id"
                )
            }
        },
        facts = ProvideDataForTest(cases, AssertFetching)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {
        TestFetchingSessions(),
        TestFetchSessionsWithOnlyOneFilterFieldInput(),
        TestFetchingSessionsWithFromSPSWithUnsupportedVersion()
    },
    report = Facts.Summarize(facts)
][report];
