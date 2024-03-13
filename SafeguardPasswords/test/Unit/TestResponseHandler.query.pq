section TestResponseHandler;

ValidateByStatusCode = SafeguardPasswords.ImportFunction("ValidateByStatusCode", "ResponseHandler.pqm");

TestValidateByStatusCodeRaisesError = () =>
    let
        url = "dummy_url",
        expectedReason = "invalid_request",
        expectedMessage = "Access denied.",
        errorCode = 406,

        expectedResponse = [ 
                    HasError = true, 
                    Error = [ 
                                Reason = "Not Acceptable", 
                                Message = "Error 4060: This action is not acceptable.",
                                Detail = [
                                            Cause = [
                                                        FakeError = "invalid_request",
                                                        ErrorDescription = "Access denied."
                                                    ],
                                                    RequestUrl = "dummy_url", 
                                                    RelativePath = "fake/relative/path", 
                                                    ManuallyHandled = true, 
                                                    ErrorCode = 4060 
                                            ],
                                Message.Format = null, 
                                Message.Parameters = null 
                            ]
                ],
        fakeResponse = FakeRawResponse([    FakeError = expectedReason, 
                                            ErrorDescription = expectedMessage 
                                        ], 
                                        [   Response.Status = errorCode, 
                                            RelativePath = "fake/relative/path", 
                                            RequestUrl=url
                                        ]),

        json = Json.Document(fakeResponse),

        responseWithMeta = Value.ReplaceMetadata(json, Value.Metadata(fakeResponse)),

        response = try ValidateByStatusCode(responseWithMeta),

        facts = {
            Fact("Error response is correct", expectedResponse, response)
        }
    in
        facts;        

TestValidateByStatusCodeFallbackIsWorking = () =>
    let
        fakeResponse = FakeResponse([key = "value"]) meta [RequestUrl = "dummy_url"],
        response = ValidateByStatusCode(fakeResponse),
        facts = {
            Fact("Response data correct", fakeResponse, response),
            Fact(
                "Response meta is correct",
                [
                    Content.Type = "application/json",
                    Response.Status = 200,
                    RequestUrl = "dummy_url"
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

shared TestResponseHandler.UnitTest = [
    facts = {
        TestValidateByStatusCodeRaisesError(),
        TestValidateByStatusCodeFallbackIsWorking()
    },
    report = Summarize(facts)
][report];
