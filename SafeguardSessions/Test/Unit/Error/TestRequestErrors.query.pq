section TestRequestErrors;

ErrorCodes = SafeguardSessions.ImportFunction("ErrorCodes", "RequestErrors.pqm");

TestErrorCodeListIsCorrect = () =>
    let
        expectedErrorCodeList = {400, 401, 403, 404, 406, 500, 429},
        fact = Fact("Error code list is correct", expectedErrorCodeList, ErrorCodes)
    in
        fact;

shared TestRequestErrors.UnitTest = [
    facts = {TestErrorCodeListIsCorrect()},
    report = Summarize(facts)
][report];
