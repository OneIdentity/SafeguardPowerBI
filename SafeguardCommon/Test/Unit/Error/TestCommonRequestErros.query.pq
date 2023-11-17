section CommonTestRequestErrors;

ErrorCodes = Extension.ImportFunction("ErrorCodes", "CommonRequestErrors.pqm");

TestErrorCodeListIsCorrect = () =>
    let
        expectedErrorCodeList = {400, 401, 403, 404, 500},
        fact = Fact("Error code list is correct", expectedErrorCodeList, ErrorCodes)
    in
        fact;

shared TestCommonRequestErrors.UnitTest = [
    facts = {TestErrorCodeListIsCorrect()},
    report = Summarize(facts)
][report];
