section TestUtils;

Utils.FetchInfo = SafeguardSessions.ImportFunction("FetchInfo", "Utils.pqm");

TestFetchInfoContentWithoutStartTime =  UnitTestFramework.ImportFunction("TestFetchInfoContentWithoutStartTime", "Asserts.pqm");

TestFetchInfoContainsConnectorVersion = () =>
    let
        actualInfo = Utils.FetchInfo("dummy_status", "dummy_message", null, 0, false, "dummy_url"),
        expectedInfo = #table(
            type table [Url = any, ConnectorVersion = any, Status = any, ExpectedCount = any, Message = any, Failed = any],
            {{"dummy_url", "v2.0.2sps8.1.0", "dummy_status", 0, "dummy_message", false}}
        )
    in
        TestFetchInfoContentWithoutStartTime(expectedInfo, actualInfo);

shared TestUtils.UnitTest = [
    facts = {TestFetchInfoContainsConnectorVersion()},
    report = Summarize(facts)
][report];
