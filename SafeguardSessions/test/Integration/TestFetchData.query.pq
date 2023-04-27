section TestSafeguardSessions.FetchData;

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

TestSafeguardSessions.URL = "dummy_url";
TestSafeguardSessions.SessionId = "e8e5f0a0d3367043150187f81df3484e91e365d5";

TestSafeguardSession.GetExpectedCountResponse = (optional expectedCount as number) =>
    FakeRawResponse([count = expectedCount ?? 0]);

TestSafeguardSession.SuccessfulOpenSnapshotResponse = FakeRawResponse([
    body = [snapshot = "dummy_snapshot_id"]
]);

TestSafeguardSessions.Response.First = FakeRawResponse(
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
            ]
        },
        #"meta" = [next = "/dummy_url_next"]
    ]
);

TestSafeguardSessions.Response.Next = FakeRawResponse(
    [
        items = {
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
        #"meta" = [next = "/dummy_url_final"]
    ]
);

TestSafeguardSessions.Response.Last = FakeRawResponse([
    items = {},
    #"meta" = [next = null]
]);

TestSafeguardSessions.Schema = [
    Sessions = CreateSchema(
        {
            {"session_id", type text},
            {"subtable.field1", type number},
            {"subtable.field2", type text},
            {"flatvalue1", type number},
            {"flatvalue2", type logical}
        }
    )
];

TestFetchDataIsSuccessful = () =>
    let
        AssertFetching = (
            description as text, fakeResponses as record, expectedData as table, expectedMeta as record
        ) =>
            let
                response = FetchData(
                    TestSafeguardSessions.URL,
                    [],
                    TestSafeguardSessions.SessionId,
                    [
                        GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(2),
                        OpenSnapshotResponse = TestSafeguardSession.SuccessfulOpenSnapshotResponse,
                        GetPageResponseMap = fakeResponses,
                        Schema = TestSafeguardSessions.Schema
                    ]
                ),
                facts = {
                    Fact(Text.Format("#{0}: data is fetched correctly", {description}), expectedData, response),
                    Fact(Text.Format("#{0}: meta is correct", {description}), expectedMeta, Value.Metadata(response))
                }
            in
                facts,
        cases = {
            {
                "Exact response is fetched",
                [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
                    #"http://dummy_url/dummy_url_next" = TestSafeguardSessions.Response.Next,
                    #"http://dummy_url/dummy_url_final" = TestSafeguardSessions.Response.Last
                ],
                #table(
                    type table [
                        session_id = text,
                        subtable.field1 = number,
                        subtable.field2 = text,
                        flatvalue1 = number,
                        flatvalue2 = logical
                    ],
                    {{"id1", 1, "value1", 1, true}, {"id2", 2, "value2", 2, false}}
                ),
                [
                    RequestUrl = "http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id",
                    Count = 2
                ]
            },
            {
                "Response with missing field is fetched",
                [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
                    #"http://dummy_url/dummy_url_next" = FakeRawResponse(
                        [
                            items = {
                                [
                                    body = [
                                        subtable = [field1 = 2, field2 = "value2"],
                                        flatvalue2 = false
                                    ],
                                    key = "id2",
                                    #"meta" = []
                                ]
                            },
                            #"meta" = [next = "/dummy_url_final"]
                        ]
                    ),
                    #"http://dummy_url/dummy_url_final" = TestSafeguardSessions.Response.Last
                ],
                #table(
                    type table [
                        session_id = text,
                        subtable.field1 = number,
                        subtable.field2 = text,
                        flatvalue1 = number,
                        flatvalue2 = logical
                    ],
                    {{"id1", 1, "value1", 1, true}, {"id2", 2, "value2", null, false}}
                ),
                [
                    RequestUrl = "http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id",
                    Count = 2
                ]
            },
            {
                "Response with extra field is fetched",
                [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
                    #"http://dummy_url/dummy_url_next" = FakeRawResponse(
                        [
                            items = {
                                [
                                    body = [
                                        subtable = [
                                            field1 = 2,
                                            field2 = "value2",
                                            extra_field = "it_will_be_removed"
                                        ],
                                        flatvalue1 = 2,
                                        flatvalue2 = false
                                    ],
                                    key = "id2",
                                    #"meta" = []
                                ]
                            },
                            #"meta" = [next = "/dummy_url_final"]
                        ]
                    ),
                    #"http://dummy_url/dummy_url_final" = TestSafeguardSessions.Response.Last
                ],
                #table(
                    type table [
                        session_id = text,
                        subtable.field1 = number,
                        subtable.field2 = text,
                        flatvalue1 = number,
                        flatvalue2 = logical
                    ],
                    {{"id1", 1, "value1", 1, true}, {"id2", 2, "value2", 2, false}}
                ),
                [
                    RequestUrl = "http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id",
                    Count = 2
                ]
            }
        },
        facts = ProvideDataForTest(cases, AssertFetching)
    in
        facts;

TestFetchDataWithInvalidTypeForField = () =>
    let
        fakeResponses = [
            #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
            #"http://dummy_url/dummy_url_next" = FakeRawResponse(
                [
                    items = {
                        [
                            body = [
                                subtable = [
                                    field1 = 2,
                                    field2 = "value2"
                                ],
                                flatvalue1 = 2,
                                flatvalue2 = "this is not logical"
                            ],
                            key = "id2",
                            #"meta" = []
                        ]
                    },
                    #"meta" = [next = "/dummy_url_final"]
                ]
            ),
            #"http://dummy_url/dummy_url_final" = TestSafeguardSessions.Response.Last
        ],
        response = FetchData(
            TestSafeguardSessions.URL,
            [],
            TestSafeguardSessions.SessionId,
            [
                GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(2),
                OpenSnapshotResponse = TestSafeguardSession.SuccessfulOpenSnapshotResponse,
                GetPageResponseMap = fakeResponses,
                Schema = TestSafeguardSessions.Schema
            ]
        ),
        cellValue = try response{[session_id = "id2"]}[flatvalue2],
        withErrorsReplaced = Table.ReplaceErrorValues(response, {"flatvalue2", "error_replaced"}),
        facts = {
            Fact("Cell has error", true, cellValue[HasError]),
            Fact(
                "The rest of the response is correct",
                #table(
                    type table [
                        session_id = text,
                        subtable.field1 = number,
                        subtable.field2 = text,
                        flatvalue1 = number,
                        flatvalue2 = logical
                    ],
                    {{"id1", 1, "value1", 1, true}, {"id2", 2, "value2", 2, "error_replaced"}}
                ),
                withErrorsReplaced
            )
        }
    in
        facts;

TestFetchDataRaisesErrorWhenAdvancedSearchInitialResponseFails = () =>
    let
        AssertErrorIsRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeResponses = [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = FakeRawResponse(
                        [#"error" = "reason"], [
                            Response.Status = statusCode
                        ]
                    )
                ],
                facts = TestErrorIsRaised(
                    try
                        FetchData(
                            TestSafeguardSessions.URL,
                            [],
                            TestSafeguardSessions.SessionId,
                            [
                                GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(0),
                                OpenSnapshotResponse = TestSafeguardSession.SuccessfulOpenSnapshotResponse,
                                GetPageResponseMap = fakeResponses
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id"
                    ]
                )
            in
                facts,
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "The username or password is invalid"},
            {403, "Authorization Error", "You are not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsRaised)
    in
        facts;

TestFetchDataRaisesErrorWhenAdvancedSearchSuccessiveResponseFails = () =>
    let
        AssertErrorIsRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeResponses = [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
                    #"http://dummy_url/dummy_url_next" = FakeRawResponse(
                        [#"error" = "reason"], [
                            Response.Status = statusCode
                        ]
                    )
                ],
                facts = TestErrorIsRaised(
                    try
                        FetchData(
                            TestSafeguardSessions.URL,
                            [],
                            TestSafeguardSessions.SessionId,
                            [
                                GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(2),
                                OpenSnapshotResponse = TestSafeguardSession.SuccessfulOpenSnapshotResponse,
                                GetPageResponseMap = fakeResponses
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/dummy_url_next"
                    ]
                )
            in
                facts,
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "The username or password is invalid"},
            {403, "Authorization Error", "You are not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsRaised)
    in
        facts;

TestFetchDataRaisesErrorWhenCountRequestFails = () =>
    let
        AssertErrorIsRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeCountResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ]),
                facts = TestErrorIsRaised(
                    try
                        FetchData(
                            TestSafeguardSessions.URL,
                            [],
                            TestSafeguardSessions.SessionId,
                            [
                                GetSessionsCountResponse = fakeCountResponse
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions/_count"
                    ]
                )
            in
                facts,
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "The username or password is invalid"},
            {403, "Authorization Error", "You are not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsRaised)
    in
        facts;

TestFetchDataRaisesErrorWhenSnapshotRequestFails = () =>
    let
        AssertErrorIsRaised = (statusCode as number, expectedReason as text, expectedMessage as text) =>
            let
                fakeSnapshotResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ]),
                facts = TestErrorIsRaised(
                    try
                        FetchData(
                            TestSafeguardSessions.URL,
                            [],
                            TestSafeguardSessions.SessionId,
                            [
                                GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(2),
                                OpenSnapshotResponse = fakeSnapshotResponse
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions/_snapshot"
                    ]
                )
            in
                facts,
        cases = {
            {400, "Bad Request", "SPS interpreted a malformed request"},
            {401, "Authentication Error", "The username or password is invalid"},
            {403, "Authorization Error", "You are not authorized to access the given resource"},
            {404, "Not Found", "The requested resource cannot be found"},
            {429, "Snapshot Quota Error", "Snapshot quota exceeded"},
            {500, "General Error", "SPS responded with server error"}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsRaised)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {
        TestFetchDataIsSuccessful(),
        TestFetchDataWithInvalidTypeForField(),
        TestFetchDataRaisesErrorWhenAdvancedSearchInitialResponseFails(),
        TestFetchDataRaisesErrorWhenAdvancedSearchSuccessiveResponseFails(),
        TestFetchDataRaisesErrorWhenCountRequestFails(),
        TestFetchDataRaisesErrorWhenSnapshotRequestFails()
    },
    report = Facts.Summarize(facts)
][report];
