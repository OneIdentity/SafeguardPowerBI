section TestAdvancedSearch;

AdvancedSearch = Extension.ImportModule("AdvancedSearch.pqm");

AdvancedSearch.AdvancedSearch = AdvancedSearch[AdvancedSearch];

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
        result = AdvancedSearch.AdvancedSearch(
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

TestAdvancedSearchWithZeroItem = () =>
    let
        fakeResponses = [
            #"http://dummy_url/api/audit/sessions?snapshot=dummy_snapshot" = TestSafeguardSessions.Response.Last,
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
            {}
        ),
        result = AdvancedSearch.AdvancedSearch(
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
        Fact("Advance search returns an empty table with schema", expectedData, result);

TestErrorIsContainedInAdvancedSearchResponse = () =>
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
        actualResponse = AdvancedSearch.AdvancedSearch(
            "dummy_url",
            [],
            "dummy_snapshot",
            "dummy_session_id",
            [
                GetPageResponseMap = fakeResponses,
                Schema = TestSafeguardSessions.Schema
            ]
        ),
        expectedReason = "Not Found",
        expectedMessage = "Error 4040: The requested resource is not found.",
        expectedDetail = [
            ManuallyHandled = true,
            Cause = [#"error" = "reason"],
            RequestUrl = "http://dummy_url/dummy_url_final",
            ErrorCode = 4040
        ],
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
            ),
            Fact(
                "Second row contains valid data",
                [
                    session_id = "id2",
                    subtable.field1 = 2,
                    subtable.field2 = "value2",
                    flatvalue1 = 2,
                    flatvalue2 = false
                ],
                actualResponse{1}
            )
        },
        errorResponse = () => actualResponse{2},
        errorFacts = AssertError(
            "Advanced search masks the error",
            errorResponse,
            {},
            [
                Reason = expectedReason,
                Message = expectedMessage,
                Detail = expectedDetail
            ]
        )
    in
        List.Combine({dataFacts, errorFacts});

shared TestAdvancedSearch.UnitTest = [
    facts = {
        TestAdvancedSearchIsSuccessful(),
        TestAdvancedSearchWithZeroItem(),
        TestErrorIsContainedInAdvancedSearchResponse()
    },
    report = Summarize(facts)
][report];
