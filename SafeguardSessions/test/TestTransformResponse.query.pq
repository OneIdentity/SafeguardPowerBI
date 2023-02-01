section TestTransformResponse;

TransformResponse = Extension.ImportFunction("TransformResponse", "Utils.pqm");

TestResponseIsTransformedCorrectly = () =>
    let
        response = [
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
        expected_response = {
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
        expected_meta = [
            dummy_field = "dummy value"
        ],
        transformed_response = TransformResponse(response),
        facts = {
            Fact("Response is transformed correctly", expected_response, transformed_response),
            Fact("Meta is correct", expected_meta, Value.Metadata(transformed_response))
        }
    in
        facts;

shared TestTransformResponse.UnitTest = [
    facts = {TestResponseIsTransformedCorrectly()},
    report = Facts.Summarize(facts)
][report];
