section TestCommonResponseHandler;

GetDataFromResponse = SafeguardCommon.ImportFunction("GetDataFromResponse", "CommonResponseHandler.pqm");

fakeResponse = FakeResponse(
    [
        body = [
            svc1 = [protocol = "ssh"]
        ],
        #"meta" = [next = "the/next/link"]
    ],
    [
        Content.Type = "application/json",
        Response.Status = 200,
        RequestUrl = "dummy_url"
    ]
);

TestGetDataFromResponse = () =>
    let
        AssertDataAndMeta = (
            description as text,
            response as record,
            path as text,
            expectedResponseWithMeta as record,
            optional separator as text
        ) =>
            let
                data = GetDataFromResponse(response, path, separator), dataMeta = Value.Metadata(data)
            in
                Fact(description, expectedResponseWithMeta, [Data = data, Meta = dataMeta]),
        cases = {
            {
                "Returns one-level deep data with meta from response",
                fakeResponse,
                "meta",
                [
                    Data = [next = "the/next/link"],
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ]
            },
            {
                "Returns multiple-level deep data from response",
                fakeResponse,
                "body.svc1.protocol",
                [
                    Data = "ssh",
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ]
            },
            {
                "Returns data from response when path is specified with custom separator",
                fakeResponse,
                "body/svc1/protocol",
                [
                    Data = "ssh",
                    Meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"]
                ],
                "/"
            }
        },
        facts = ProvideDataForTest(cases, AssertDataAndMeta)
    in
        facts;

TestGetDataFromResponseRaisesError = () =>
    let
        AssertGettingDataFromResponseError = (description as text, path as text) =>
            AssertError(
                description,
                GetDataFromResponse,
                {fakeResponse, path},
                "Not Parsable Response",
                "Error 10002: The source IP returned a response with missing fields.",
                [
                    ManuallyHandled = true,
                    Cause = fakeResponse,
                    MissingField = path,
                    RequestUrl = "dummy_url",
                    ErrorCode = 10002
                ]
            ),
        cases = {
            {"Raises error if first part of the path is not found in response", ""},
            {"Raises error if inner part of the path is not found in response", "body.svc.dummy"},
            {
                "Raises error when path not splitted due to different separator what path includes and retrieval not finds the unsplitted field",
                "body/svc1/protocol"
            }
        },
        facts = ProvideDataForTest(cases, AssertGettingDataFromResponseError)
    in
        facts;

shared TestCommonResponseHandler.UnitTest = [
    facts = {TestGetDataFromResponse(), TestGetDataFromResponseRaisesError()},
    report = Summarize(facts)
][report];
