section TestResponseHandler;

ValidateByStatusCode = Extension.ImportFunction("ValidateByStatusCode", "ResponseHandler.pqm");

TestValidateByStatusCodeRaisesError = () =>
    let
        url = "dummy_url",
        expectedReason = "invalid_request",
        expectedMessage = "Access denied.",
        errorCode = 401,

        expectedResponse = [ 
                    HasError = true, 
                    Error = [ 
                                Reason = "Authentication Error", 
                                Message = "Error 4010: The username or password you have specified is invalid.", 
                                Detail = [
                                            Cause = [
                                                        fakeError = "invalid_request",
                                                        error_description = "Access denied."
                                                    ],
                                                    RequestUrl = "dummy_url", 
                                                    RelativePath = "fake/relative/path", 
                                                    ManuallyHandled = true, 
                                                    ErrorCode = 4010 
                                            ],
                                Message.Format = null, 
                                Message.Parameters = null 
                            ]
                ],
        fakeResponse = FakeRawResponse([    fakeError = expectedReason, 
                                            error_description = expectedMessage 
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

TestValidateBy406StatusCodeRaisesError = () =>
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
                                                        fakeError = "invalid_request",
                                                        error_description = "Access denied."
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
        fakeResponse = FakeRawResponse([    fakeError = expectedReason, 
                                            error_description = expectedMessage 
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
        TestValidateBy406StatusCodeRaisesError(),
        TestValidateByStatusCodeFallbackIsWorking()
    },
    report = Facts.Summarize(facts)
][report];
