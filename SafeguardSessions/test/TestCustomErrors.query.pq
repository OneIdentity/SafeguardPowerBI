section TestCustomErrors;

RaiseErrorOrReturn = Extension.ImportFunction("RaiseErrorOrReturn", "CustomErrors.pqm");
ErrorCodes = Extension.ImportFunction("ErrorCodes", "CustomErrors.pqm");

TestRaiseErrorOrReturnRaisesError = () =>
    let
        fake_auth_response = FakeResponse("{""error"": ""reason""}", [
            Response.Status = 401
        ]),
        facts = TestErrorIsRaised(
            try RaiseErrorOrReturn(fake_auth_response),
            "Authentication Error",
            "Something went wrong while authenticating",
            fake_auth_response
        )
    in
        facts;

TestRaiseErrorOrReturnRaisesErrorWithDetails = () =>
    let
        fake_auth_response = FakeResponse("{}", [
            Response.Status = 401
        ]),
        details = "dummy details",
        facts = TestErrorIsRaised(
            try RaiseErrorOrReturn(fake_auth_response, details),
            "Authentication Error",
            "Something went wrong while authenticating",
            "dummy details"
        )
    in
        facts;

TestRaiseErrorOrReturnFallbackIsWorking = () =>
    let
        fake_response = FakeResponse("{""key"": ""value""}"),
        response = RaiseErrorOrReturn(fake_response),
        facts = {
            Fact("Response data correct", fake_response, response),
            Fact(
                "Response meta is correct",
                [
                    Content.Type = "application/json",
                    Response.Status = 200
                ],
                Value.Metadata(response)
            )
        }
    in
        facts;

TestErrorCodeListIsCorrect = () =>
    let
        expected_error_code_list = {400, 401, 404, 429, 500},
        fact = Fact("Error code list is correct", expected_error_code_list, ErrorCodes)
    in
        fact;

shared TestCustomErrors.UnitTest = [
    facts = {
        TestRaiseErrorOrReturnRaisesError(),
        TestRaiseErrorOrReturnRaisesErrorWithDetails(),
        TestRaiseErrorOrReturnFallbackIsWorking(),
        TestErrorCodeListIsCorrect()
    },
    report = Facts.Summarize(facts)
][report];
