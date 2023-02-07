section TestCustomErrors;

RaiseErrorOrReturn = Extension.ImportFunction("RaiseErrorOrReturn", "CustomErrors.pqm");
ErrorCodes = Extension.ImportFunction("ErrorCodes", "CustomErrors.pqm");

TestRaiseErrorOrReturnRaisesError = () =>
    let
        url = "dummy_url",
        fake_auth_response = FakeResponse("{""error"": ""reason""}", [
            Response.Status = 401,
            RequestUrl = url
        ]),
        facts = TestErrorIsRaised(
            try RaiseErrorOrReturn(fake_auth_response),
            "Authentication Error",
            "Something went wrong while authenticating",
            [
                Cause =  fake_auth_response,
                RequestUrl = url
            ]
        )
    in
        facts;

TestRaiseErrorOrReturnFallbackIsWorking = () =>
    let
        fake_response = FakeResponse("{""key"": ""value""}") meta [RequestUrl = "dummy_url"],
        response = RaiseErrorOrReturn(fake_response),
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

TestErrorCodeListIsCorrect = () =>
    let
        expected_error_code_list = {400, 401, 403, 404, 429, 500},
        fact = Fact("Error code list is correct", expected_error_code_list, ErrorCodes)
    in
        fact;

shared TestCustomErrors.UnitTest = [
    facts = {
        TestRaiseErrorOrReturnRaisesError(),
        TestRaiseErrorOrReturnFallbackIsWorking(),
        TestErrorCodeListIsCorrect()
    },
    report = Facts.Summarize(facts)
][report];
