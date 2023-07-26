section TestResponseHandler;

NotParsableResponse = Extension.ImportFunction("NotParsableResponse", "RequestErrors.pqm");
GetDataFromResponse = Extension.ImportFunction("GetDataFromResponse", "ResponseHandler.pqm");
ValidateByStatusCode = Extension.ImportFunction("ValidateByStatusCode", "ResponseHandler.pqm");

TestValidateByStatusCodeRaisesError = () =>
    let
        url = "dummy_url",
        fake_auth_response = FakeResponse([#"error" = "reason"], [
            Response.Status = 401,
            RequestUrl = url
        ]),
        facts = TestErrorIsRaised(
            try ValidateByStatusCode(fake_auth_response),
            "Authentication Error",
            "Error 4010: The username or password you have specified is invalid.",
            [
                ManuallyHandled = true,
                Cause = fake_auth_response,
                RequestUrl = url,
                ErrorCode = 4010
            ]
        )
    in
        facts;

TestValidateByStatusCodeFallbackIsWorking = () =>
    let
        fake_response = FakeResponse([key = "value"]) meta [RequestUrl = "dummy_url"],
        response = ValidateByStatusCode(fake_response),
        facts = {
            Fact("Response data correct", fake_response, response),
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

TestGetDataFromResponse = () =>
    let
        fake_response = FakeResponse([
            body = [
                svc1 = [protocol = "ssh"]
            ],
            #"meta" = [next = "the/next/link"]
        ]) meta [RequestUrl = "dummy_url"],
        cases = {
            {
                "Returns one-level deep data from response",
                [
                    next = "the/next/link"
                ],
                GetDataFromResponse(fake_response, "meta")
            },
            {
                "Returns multiple-level deep data from response",
                "ssh",
                GetDataFromResponse(fake_response, "body.svc1.protocol")
            },
            {
                "Returns data from response when path is specified with custom separator",
                "ssh",
                GetDataFromResponse(fake_response, "body/svc1/protocol", "/")
            },
            {
                "Raises error if path not found in response",
                [
                    HasError = true,
                    Error = [
                        Reason = "Not Parsable Response",
                        Message = "Error 10002: The source IP returned a response with missing fields.",
                        Detail = [
                            ManuallyHandled = true,
                            Cause = fake_response,
                            MissingField = "",
                            RequestUrl = "dummy_url",
                            ErrorCode = 10002 
                        ],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try GetDataFromResponse(fake_response, "")
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
                            Cause = fake_response,
                            MissingField = "body/svc1/protocol",
                            RequestUrl = "dummy_url",
                            ErrorCode = 10002
                        ],
                        Message.Format = null,
                        Message.Parameters = null
                    ]
                ],
                try GetDataFromResponse(fake_response, "body/svc1/protocol", ".")
            }
        },
        facts = ProvideDataForTest(cases, Fact)
    in
        facts;

shared TestResponseHandler.UnitTest = [
    facts = {
        TestValidateByStatusCodeRaisesError(),
        TestValidateByStatusCodeFallbackIsWorking(),
        TestGetDataFromResponse()
    },
    report = Facts.Summarize(facts)
][report];
