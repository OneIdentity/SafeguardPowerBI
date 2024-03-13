section TestResponseHandler;

ValidateByStatusCode = SafeguardSessions.ImportFunction("ValidateByStatusCode", "ResponseHandler.pqm");

TestValidateByStatusCodeRaisesError = () =>
    let
        url = "dummy_url",
        fakeAuthResponse = FakeResponse([#"error" = "reason"], [
            Response.Status = 401,
            RequestUrl = url
        ]),
        facts = AssertError(
            "Error is raised if error response is received",
            ValidateByStatusCode,
            {fakeAuthResponse},
            [
                Reason = "Authentication Error",
                Message = "Error 4010: The username or password you have specified is invalid.",
                Detail = [
                    ManuallyHandled = true,
                    Cause = fakeAuthResponse,
                    RequestUrl = url,
                    ErrorCode = 4010
                ]
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
    facts = {TestValidateByStatusCodeRaisesError(), TestValidateByStatusCodeFallbackIsWorking()},
    report = Summarize(facts)
][report];
