section TestCustomRequestErrors;

RaiseErrorOrReturn = Extension.ImportFunction("RaiseErrorOrReturn", "RequestErrors.pqm");
ErrorCodes = Extension.ImportFunction("ErrorCodes", "RequestErrors.pqm");

TestRaiseErrorOrReturnRaisesError = () =>
    let
        url = "dummy_url",
        fakeAuthResponse = FakeResponse([#"error" = "reason"], [
            Response.Status = 401,
            RequestUrl = url
        ]),
        facts = TestErrorIsRaised(
            try RaiseErrorOrReturn(fakeAuthResponse),
            "Authentication Error",
            "Something went wrong while authenticating",
            [
                ManuallyHandled = true,
                Cause = fakeAuthResponse,
                RequestUrl = url
            ]
        )
    in
        facts;

TestRaiseErrorOrReturnFallbackIsWorking = () =>
    let
        fakeResponse = FakeResponse([key = "value"]) meta [RequestUrl = "dummy_url"],
        response = RaiseErrorOrReturn(fakeResponse),
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

TestErrorCodeListIsCorrect = () =>
    let
        expectedErrorCodeList = {400, 401, 403, 404, 429, 500},
        fact = Fact("Error code list is correct", expectedErrorCodeList, ErrorCodes)
    in
        fact;

shared TestCustomRequestErrors.UnitTest = [
    facts = {
        TestRaiseErrorOrReturnRaisesError(),
        TestRaiseErrorOrReturnFallbackIsWorking(),
        TestErrorCodeListIsCorrect()
    },
    report = Facts.Summarize(facts)
][report];
