section TestCommonResponseHandler;

GetDataFromResponse = Extension.ImportFunction("GetDataFromResponse", "CommonResponseHandler.pqm");

TestGetDataFromResponse = () =>
    let
        fakeResponse = FakeResponse([
            body = [
                svc1 = [protocol = "ssh"]
            ],
            #"meta" = [next = "the/next/link"]
        ]) meta [RequestUrl = "dummy_url"],
        GetDataAndMeta = (response as record, path as text, optional separator as text) =>
            let
                data = GetDataFromResponse(response, path, separator), dataMeta = Value.Metadata(data)
            in
                [Data = data, Meta = dataMeta],
        AssertDataAndMeta = (
            description as text,
            expected_response_with_meta as record,
            response as record,
            path as text,
            optional separator as text
        ) =>
            let
                data = GetDataFromResponse(response, path, separator), dataMeta = Value.Metadata(data)
            in
                Fact(description, expected_response_with_meta, [Data = data, Meta = dataMeta]),
        validCases = {
            {
                "Returns one-level deep data with meta from response",
                [
                    Data = [next = "the/next/link"],
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ],
                fakeResponse,
                "meta"
            },
            {
                "Returns multiple-level deep data from response",
                [
                    Data = "ssh",
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ],
                fakeResponse,
                "body.svc1.protocol"
            },
            {
                "Returns data from response when path is specified with custom separator",
                [
                    Data = "ssh",
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ],
                fakeResponse,
                "body/svc1/protocol",
                "/"
            }
        },
        errorCases = {
            {
                "Raises error if first part of the path is not found in response",
                [
                    HasError = true,
                    Error = [
                        Reason = "Not Parsable Response",
                        Message = "Error 10002: The source IP returned a response with missing fields.",
                        Detail = [
                            ManuallyHandled = true,
                            Cause = fakeResponse,
                            MissingField = "",
                            RequestUrl = "dummy_url",
                            ErrorCode = 10002
                        ],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try GetDataFromResponse(fakeResponse, "")
            },
            {
                "Raises error if inner part of the path is not found in response",
                [
                    HasError = true,
                    Error = [
                        Reason = "Not Parsable Response",
                        Message = "Error 10002: The source IP returned a response with missing fields.",
                        Detail = [
                            ManuallyHandled = true,
                            Cause = fakeResponse,
                            MissingField = "body.svc.dummy",
                            RequestUrl = "dummy_url",
                            ErrorCode = 10002
                        ],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try GetDataFromResponse(fakeResponse, "body.svc.dummy")
            },
            {
                "Raises error when path not splitted due to different separator what path includes and retrieval not finds the unsplitted field",
                [
                    HasError = true,
                    Error = [
                        Reason = "Not Parsable Response",
                        Message = "Error 10002: The source IP returned a response with missing fields.",
                        Detail = [
                            ManuallyHandled = true,
                            Cause = fakeResponse,
                            MissingField = "body/svc1/protocol",
                            RequestUrl = "dummy_url",
                            ErrorCode = 10002
                        ],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try GetDataFromResponse(fakeResponse, "body/svc1/protocol", ".")
            }
        },
        validFacts = ProvideDataForTest(validCases, AssertDataAndMeta),
        errorFacts = ProvideDataForTest(errorCases, Fact),
        facts = {validFacts, errorFacts}
    in
        facts;

shared TestCommonResponseHandler.UnitTest = [
    facts = {TestGetDataFromResponse()},
    report = Facts.Summarize(facts)
][report];
