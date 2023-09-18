section TestResponseHandler;

ValidateByStatusCode = Extension.ImportFunction("ValidateByStatusCode", "ResponseHandler.pqm");

TestValidateByStatusCodeRaisesError = () =>
    let
        url = "dummy_url",
        fakeAuthResponse = FakeResponse([#"error" = "reason"], [
            Response.Status = 401,
            RequestUrl = url
        ]),
        facts = TestErrorIsRaised(
            try ValidateByStatusCode(fakeAuthResponse),
            "Authentication Error",
            "Error 4010: The username or password you have specified is invalid.",
            [
                ManuallyHandled = true,
                Cause = fakeAuthResponse,
                RequestUrl = url,
                ErrorCode = 4010
            ]
        )
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
    report = Facts.Summarize(facts)
][report];
