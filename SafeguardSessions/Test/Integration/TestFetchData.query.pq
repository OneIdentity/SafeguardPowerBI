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
        AssertFetchingFailure = (
            statusCode as number, expectedReason as text, expectedMessage as text, expectedErrorCode as number
        ) =>
            let
                params = {
                    TestSafeguardSessions.URL,
                    [],
                    TestSafeguardSessions.SessionId,
                    [
                        GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(0),
                        OpenSnapshotResponse = TestSafeguardSession.SuccessfulOpenSnapshotResponse,
                        GetPageResponseMap = fakeResponses
                    ]
                },
                fakeResponses = [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = FakeRawResponse(
                        [#"error" = "reason"], [
                            Response.Status = statusCode
                        ]
                    )
                ],
                expectedErrorRecord = [
                    Reason = expectedReason,
                    Message = expectedMessage,
                    Detail = [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id",
                        ErrorCode = expectedErrorCode
                    ]
                ],
                caseName = Text.Format("Error is raised for status code [#StatusCode]", [StatusCode = statusCode])
            in
                AssertError(caseName, FetchData, params, expectedErrorRecord),
        cases = {
            {
                400,
                "Bad Request",
                "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                4000
            },
            {
                401,
                "Authentication Error",
                "Error 4010: The username or password you have specified is invalid.",
                4010
            },
            {
                403,
                "Authorization Error",
                "Error 4030: You are not authorized to access the specified resource.",
                4030
            },
            {404, "Not Found", "Error 4040: The requested resource is not found.", 4040},
            {429, "Snapshot Quota Error", "Error 4290: Snapshot quota exceeded.", 4290},
            {500, "Server Error", "Error 5000: The source IP responded with a server error.", 5000}
        },
        facts = ProvideDataForTest(cases, AssertFetchingFailure)
    in
        facts;

TestErrorIsContainedWhenAdvancedSearchSuccessiveResponseFails = () =>
    let
        AssertErrorIsContained = (
            statusCode as number, expectedReason as text, expectedMessage as text, expectedErrorCode as number
        ) =>
            let
                fakeResponses = [
                    #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot_id" = TestSafeguardSessions.Response.First,
                    #"http://dummy_url/dummy_url_next" = FakeRawResponse(
                        [#"error" = "reason"], [
                            Response.Status = statusCode
                        ]
                    )
                ],
                actualResponse = FetchData(
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
                dataFacts = {
                    Fact(
                        "First row contains valid data",
                        [
                            session_id = "id1",
                            subtable.field1 = 1,
                            subtable.field2 = "value1",
                            flatvalue1 = 1,
                            flatvalue2 = true
                        ],
                        actualResponse{0}
                    )
                },
                errorResponse = () => actualResponse{1},
                errorFacts = AssertError(
                    "Advanced search masks the error",
                    errorResponse,
                    {},
                    [
                        Reason = expectedReason,
                        Message = expectedMessage,
                        Detail = [
                            ManuallyHandled = true,
                            Cause = [#"error" = "reason"],
                            RequestUrl = "http://dummy_url/dummy_url_next",
                            ErrorCode = expectedErrorCode
                        ]
                    ]
                )
            in
                List.Combine({dataFacts, errorFacts}),
        cases = {
            {
                400,
                "Bad Request",
                "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                4000
            },
            {
                401,
                "Authentication Error",
                "Error 4010: The username or password you have specified is invalid.",
                4010
            },
            {
                403,
                "Authorization Error",
                "Error 4030: You are not authorized to access the specified resource.",
                4030
            },
            {404, "Not Found", "Error 4040: The requested resource is not found.", 4040},
            {429, "Snapshot Quota Error", "Error 4290: Snapshot quota exceeded.", 4290},
            {500, "Server Error", "Error 5000: The source IP responded with a server error.", 5000}
        },
        facts = ProvideDataForTest(cases, AssertErrorIsContained)
    in
        facts;

TestFetchDataRaisesErrorWhenCountRequestFails = () =>
    let
        AssertFetchingFailure = (
            statusCode as number, expectedReason as text, expectedMessage as text, expectedErrorCode as number
        ) =>
            let
                fakeCountResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ]),
                expectedErrorRecord = [
                    Reason = expectedReason,
                    Message = expectedMessage,
                    Detail = [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions/_count",
                        ErrorCode = expectedErrorCode
                    ]
                ],
                params = {
                    TestSafeguardSessions.URL,
                    [],
                    TestSafeguardSessions.SessionId,
                    [
                        GetSessionsCountResponse = fakeCountResponse
                    ]
                },
                caseName = Text.Format("Error is raised for status code [#StatusCode]", [StatusCode = statusCode])
            in
                AssertError(caseName, FetchData, params, expectedErrorRecord),
        cases = {
            {
                400,
                "Bad Request",
                "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                4000
            },
            {
                401,
                "Authentication Error",
                "Error 4010: The username or password you have specified is invalid.",
                4010
            },
            {
                403,
                "Authorization Error",
                "Error 4030: You are not authorized to access the specified resource.",
                4030
            },
            {404, "Not Found", "Error 4040: The requested resource is not found.", 4040},
            {429, "Snapshot Quota Error", "Error 4290: Snapshot quota exceeded.", 4290},
            {500, "Server Error", "Error 5000: The source IP responded with a server error.", 5000}
        },
        facts = ProvideDataForTest(cases, AssertFetchingFailure)
    in
        facts;

TestFetchDataRaisesErrorWhenSnapshotRequestFails = () =>
    let
        AssertFetchingFailure = (
            statusCode as number, expectedReason as text, expectedMessage as text, expectedErrorCode as number
        ) =>
            let
                fakeSnapshotResponse = FakeRawResponse([#"error" = "reason"], [
                    Response.Status = statusCode
                ]),
                expectedErrorRecord = [
                    Reason = expectedReason,
                    Message = expectedMessage,
                    Detail = [
                        ManuallyHandled = true,
                        Cause = [#"error" = "reason"],
                        RequestUrl = "http://dummy_url/api/audit/sessions/_snapshot",
                        ErrorCode = expectedErrorCode
                    ]
                ],
                params = {
                    TestSafeguardSessions.URL,
                    [],
                    TestSafeguardSessions.SessionId,
                    [
                        GetSessionsCountResponse = TestSafeguardSession.GetExpectedCountResponse(2),
                        OpenSnapshotResponse = fakeSnapshotResponse
                    ]
                },
                caseName = Text.Format("Error is raised for status code [#StatusCode]", [StatusCode = statusCode])
            in
                AssertError(caseName, FetchData, params, expectedErrorRecord),
        cases = {
            {
                400,
                "Bad Request",
                "Error 4000: The source IP interpreted a malformed request. Your filter parameter(s) might be invalid.",
                4000
            },
            {
                401,
                "Authentication Error",
                "Error 4010: The username or password you have specified is invalid.",
                4010
            },
            {
                403,
                "Authorization Error",
                "Error 4030: You are not authorized to access the specified resource.",
                4030
            },
            {404, "Not Found", "Error 4040: The requested resource is not found.", 4040},
            {429, "Snapshot Quota Error", "Error 4290: Snapshot quota exceeded.", 4290},
            {500, "Server Error", "Error 5000: The source IP responded with a server error.", 5000}
        },
        facts = ProvideDataForTest(cases, AssertFetchingFailure)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {
        TestFetchDataIsSuccessful(),
        TestFetchDataWithInvalidTypeForField(),
        TestFetchDataRaisesErrorWhenAdvancedSearchInitialResponseFails(),
        TestErrorIsContainedWhenAdvancedSearchSuccessiveResponseFails(),
        TestFetchDataRaisesErrorWhenCountRequestFails(),
        TestFetchDataRaisesErrorWhenSnapshotRequestFails()
    },
    report = Summarize(facts)
][report];
