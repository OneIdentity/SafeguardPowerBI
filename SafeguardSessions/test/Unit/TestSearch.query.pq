section TestSearch;

Search = Extension.ImportModule("Search.pqm");

Search.AdvancedSearch = Search[AdvancedSearch];
Search.GetSessionsCount = Search[GetSessionsCount];
Search.OpenSnapshot = Search[OpenSnapshot];

CreateSchema = Extension.ImportFunction("CreateSchema", "SchemaUtils.pqm");

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

TestAdvancedSearchIsSuccessful = () =>
    let
        fakeResponses = [
            #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot" = TestSafeguardSessions.Response.First,
            #"http://dummy_url/dummy_url_next" = TestSafeguardSessions.Response.Next,
            #"http://dummy_url/dummy_url_final" = TestSafeguardSessions.Response.Last
        ],
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
        result = Search.AdvancedSearch(
            "dummy_url",
            [],
            "dummy_snapshot",
            "dummy_session_id",
            [
                GetPageResponseMap = fakeResponses,
                Schema = TestSafeguardSessions.Schema
            ]
        )
    in
        Fact("Advance search returns all pages", expectedData, result);

TestAdvancedSearchRaisesError = () =>
    let
        fakeResponses = [
            #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot" = TestSafeguardSessions.Response.First,
            #"http://dummy_url/dummy_url_next" = TestSafeguardSessions.Response.Next,
            #"http://dummy_url/dummy_url_final" = FakeRawResponse(
                [#"error" = "reason"], [
                    Response.Status = 404,
                    RequestUrl = "http://dummy_url/dummy_url_final"
                ]
            )
        ],
        expectedReason = "Not Found",
        expectedMessage = "Error 4040: The requested resource is not found.",
        expectedDetail = [
            ManuallyHandled = true,
            Cause = [#"error" = "reason"],
            RequestUrl = "http://dummy_url/dummy_url_final",
            ErrorCode = 4040
        ]
    in
        Fact(
            "a",
            Search.AdvancedSearch(
                "dummy_url", [], "dummy_snapshot", "dummy_session_id", [GetPageResponseMap = fakeResponses]
            ),
            "b"
        );

TestGetSessionsCountIsSuccesful = () =>
    let
        fakeCountResponse = FakeRawResponse([count = 2]),
        count = Search.GetSessionsCount(
            "dummy_url", [], "dummy_session_id", [
                GetSessionsCountResponse = fakeCountResponse
            ]
        )
    in
        Fact("Count is returned correctly", 2, count);

TestGetSessionsCountRaisesError = () =>
    let
        requestUrl = "http://dummy_url/api/audit/sessions/_count",
        fakeCountResponse = FakeRawResponse([invalid = "response"], [
            Response.Status = 200,
            RequestUrl = requestUrl
        ]),
        expectedReason = "Not Parsable Response",
        expectedMessage = "Error 10002: The source IP returned a response with missing fields.",
        expectedDetail = [
            Cause = [invalid = "response"],
            MissingField = "count",
            RequestUrl = requestUrl,
            ManuallyHandled = true,
            ErrorCode = 10002
        ]
    in
        TestErrorIsRaised(
            try
                Search.GetSessionsCount(
                    requestUrl, [], "dummy_session_id", [
                        GetSessionsCountResponse = fakeCountResponse
                    ]
                ),
            expectedReason,
            expectedMessage,
            expectedDetail
        );

TestOpenSnapshotIsSuccessful = () =>
    let
        fakeSnapshotResponse = FakeRawResponse([
            body = [snapshot = "dummy_snapshot_id"]
        ]),
        snapshot = Search.OpenSnapshot(
            "dummy_url", "dummy_session_id", [
                OpenSnapshotResponse = fakeSnapshotResponse
            ]
        )
    in
        Fact("Snapshot is returned correctly", "dummy_snapshot_id", snapshot);

TestOpenSnapshotRaisesError = () =>
    let
        AsserErrorIsRaised = (
            fakeSnapshotResponse as binary, expectedReason as text, expectedMessage as text, expectedDetail as record
        ) =>
            let
                requestUrl = "http://dummy_url/api/audit/sessions/_snapshot"
            in
                TestErrorIsRaised(
                    try
                        Search.OpenSnapshot(
                            requestUrl, "dummy_session_id", [
                                OpenSnapshotResponse = fakeSnapshotResponse
                            ]
                        ),
                    expectedReason,
                    expectedMessage,
                    expectedDetail & [RequestUrl = requestUrl]
                ),
        cases = {
            {
                FakeRawResponse([invalid = "response"]),
                "Not Parsable Response",
                "Error 10002: The source IP returned a response with missing fields.",
                [
                    Cause = [invalid = "response"],
                    MissingField = "body.snapshot", 
                    ManuallyHandled = true,
                    ErrorCode = 10002
                ]
            },
            {
                FakeRawResponse([#"error" = "reason"], [
                    Response.Status = 429
                ]),
                "Snapshot Quota Error",
                "Error 4290: Snapshot quota exceeded.",
                [
                    Cause = [#"error" = "reason"],
                    ManuallyHandled = true,
                    ErrorCode = 4290
                ]
            }
        },
        facts = ProvideDataForTest(cases, AsserErrorIsRaised)
    in
        facts;

shared Testsearch.UnitTest = [
    facts = {
        TestAdvancedSearchIsSuccessful(),
        TestAdvancedSearchRaisesError(),
        TestGetSessionsCountIsSuccesful(),
        TestGetSessionsCountRaisesError(),
        TestOpenSnapshotIsSuccessful(),
        TestOpenSnapshotRaisesError()
    },
    report = Facts.Summarize(facts)
][report];
