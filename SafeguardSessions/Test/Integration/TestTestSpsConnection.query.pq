section TestSafeguardSessions.TestSpsConnection;

Yes = Extension.ImportFunction("Yes", "Constants.pqm");
No = Extension.ImportFunction("No", "Constants.pqm");

TestSafeguardSessions.SpsURL = "dummy_url";

TestSafeguardSessionsContentsSignature = () =>
    Fact(
        "Signature of SafeguardSessions.Contents is correct",
        [
            spsIP = type text,
            skipVersionCheck = type nullable text,
            from = type nullable datetimezone,
            to = type nullable datetimezone,
            filterField1 = type nullable text,
            filterValue1 = type nullable text,
            filterField2 = type nullable text,
            filterValue2 = type nullable text,
            filterField3 = type nullable text,
            filterValue3 = type nullable text
        ],
        Type.FunctionParameters(Value.Type(SafeguardSessions.Contents))
    );

TestTestSpsConnectionSignature = () =>
    let
        AssertSignature = (case as text, dataSourcePath as record, expectedSignature as list) =>
            Fact(
                Text.Format("#[Case]: Signature is correct", [Case = case]),
                expectedSignature,
                TestSpsConnection(Json.FromValue(dataSourcePath))
            ),
        cases = {
            {
                "Version check is performed by default",
                [
                    spsIP = TestSafeguardSessions.SpsURL,
                    skipVersionCheck = null
                ],
                {"SafeguardSessions.Contents", "dummy_url", null, null, null, null, null, null, null, null, null}
            },
            {
                "Version check is performed",
                [
                    spsIP = TestSafeguardSessions.SpsURL,
                    skipVersionCheck = No
                ],
                {"SafeguardSessions.Contents", "dummy_url", "No", null, null, null, null, null, null, null, null}
            },
            {
                "Version check is skipped",
                [
                    spsIP = TestSafeguardSessions.SpsURL,
                    skipVersionCheck = Yes
                ],
                {"SafeguardSessions.Contents", "dummy_url", "Yes", null, null, null, null, null, null, null, null}
            },
            {
                "Extra parameters are omitted",
                [
                    spsIP = TestSafeguardSessions.SpsURL,
                    skipVersionCheck = Yes,
                    from = DateTimeZone.FromText("2023-11-03T12:39:00+02:00"),
                    to = DateTimeZone.FromText("2023-12-04T13:44:00+02:00"),
                    filterField1 = "filterField1",
                    filterValue1 = "filterValue2",
                    filterField2 = "filterField2",
                    filterValue2 = "filterValue2",
                    filterField3 = "filterField3",
                    filterValue3 = "filterValue3"
                ],
                {"SafeguardSessions.Contents", "dummy_url", "Yes", null, null, null, null, null, null, null, null}
            }
        },
        facts = ProvideDataForTest(cases, AssertSignature)
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {TestSafeguardSessionsContentsSignature(), TestTestSpsConnectionSignature()},
    report = Facts.Summarize(facts)
][report];
