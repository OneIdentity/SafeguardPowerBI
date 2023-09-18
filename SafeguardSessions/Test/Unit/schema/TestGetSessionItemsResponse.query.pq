section TestGetSessionItemsResponse;

SchemaUtils.GetSessionItemsResponse = Extension.ImportFunction("GetSessionItemsResponse", "SchemaUtils.pqm");

TestItemsResponseIsReturnedCorrectly = () =>
    let
        AssertTransformation = (
            description as text, response as nullable record, expectedResponse as list, expectedMeta as record
        ) as list =>
            let
                transformedResponse = SchemaUtils.GetSessionItemsResponse(response)
            in
                {
                    Fact(
                        Text.Format("#{0} is transformed correctly", {description}),
                        expectedResponse,
                        transformedResponse
                    ),
                    Fact(
                        Text.Format("#{0} meta is correct", {description}),
                        expectedMeta,
                        Value.Metadata(transformedResponse)
                    )
                },
        cases = {
            {
                "Simple response",
                [
                    items = {
                        [
                            body = [field1 = 1, field2 = "2"],
                            key = "dummy_id_1",
                            #"meta" = []
                        ],
                        [
                            body = [field1 = 2, field2 = "3"],
                            key = "dummy_id_2",
                            #"meta" = []
                        ],
                        [
                            body = [field3 = 3, field4 = "4"],
                            key = "dummy_id_3",
                            #"meta" = []
                        ]
                    },
                    #"meta" = [
                        dummy_field = "dummy value"
                    ]
                ],
                {
                    [
                        session_id = "dummy_id_1",
                        field1 = 1,
                        field2 = "2"
                    ],
                    [
                        session_id = "dummy_id_2",
                        field1 = 2,
                        field2 = "3"
                    ],
                    [
                        session_id = "dummy_id_3",
                        field3 = 3,
                        field4 = "4"
                    ]
                },
                [
                    dummy_field = "dummy value"
                ]
            },
            {"Null response", null, {}, []},
            {"Empty response", [], {}, []}
        },
        facts = ProvideDataForTest(cases, AssertTransformation)
    in
        facts;

shared TestGetSessionItemsResponse.UnitTest = [
    facts = {TestItemsResponseIsReturnedCorrectly()},
    report = Facts.Summarize(facts)
][report];
