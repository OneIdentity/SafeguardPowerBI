section TestRequestErrors;

ErrorCodes = Extension.ImportFunction("ErrorCodes", "RequestErrors.pqm");

TestErrorCodeListIsCorrect = () =>
    let
        expectedErrorCodeList = {400, 401, 403, 404, 429, 500},
        fact = Fact("Error code list is correct", expectedErrorCodeList, ErrorCodes)
    in
        fact;

shared TestRequestErrors.UnitTest = [
    facts = {TestErrorCodeListIsCorrect()},
    report = Facts.Summarize(facts)
][report];
