section TestSafeguardSessions;

Yes = SafeguardSessions.ImportFunction("Yes", "Constants.pqm");
No = SafeguardSessions.ImportFunction("No", "Constants.pqm");

TestSafeguardSessions.SpsIp = "0.0.0.0";

TestSafeguardSessions.AuthenticationCredentials = [
    Username = "dummy",
    Password = "pwd"
];

TestSafeguardSessions.LocalNow = DateTimeZone.LocalNow();
TestSafeguardSessions.LocalNowPlusOneHour = DateTimeZone.LocalNow() + #duration(0,1,0,0);

TestQueryBuildWithPossibleNullValues = () =>
    let
        expectedQuery = [
            qInput = {{null, null} , {null, null} , {null, null} } ,
            from = null,
            to = null
        ],
        params = FetchSessions(
            TestSafeguardSessions.SpsIp,
            TestSafeguardSessions.AuthenticationCredentials,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            [
                ReturnParams = true
            ]
        ),
        facts = {
            Fact("The spsIp is correct", TestSafeguardSessions.SpsIp , params[SpsIp]),
            Fact("The credentials is correct", TestSafeguardSessions.AuthenticationCredentials, params[Credentials]),
            Fact("The query data is correct", expectedQuery, params[Query]),
            Fact("The skipVersionCheck value is correct", null, params[SkipVersionCheck])
        }
    in
        facts;

TestQueryBuildWithValues = () =>
    let
        expectedQuery = [
            qInput = {{"mockField", "mockValue"} , {"mockField2", "mockValue2"} , {"mockField3", "mockValue3"} } ,
            from = TestSafeguardSessions.LocalNow ,
            to = TestSafeguardSessions.LocalNowPlusOneHour
        ],
        params = FetchSessions(
            TestSafeguardSessions.SpsIp,
            TestSafeguardSessions.AuthenticationCredentials,
            TestSafeguardSessions.LocalNow ,
            TestSafeguardSessions.LocalNowPlusOneHour,
            "mockField",
            "mockValue",
            "mockField2",
            "mockValue2",
            "mockField3",
            "mockValue3",
            Yes,
            [
                ReturnParams = true
            ]
        ),
        facts = {
            Fact("The spsIp is correct", TestSafeguardSessions.SpsIp , params[SpsIp]),
            Fact("The credentials is correct", TestSafeguardSessions.AuthenticationCredentials, params[Credentials]),
            Fact("The query data is correct", expectedQuery, params[Query]),
            Fact("The skipVersionCheck value is correct", Yes, params[SkipVersionCheck])
        }
    in
        facts;

shared TestSafeguardSessions.IntegrationTest = [
    facts = {
        TestQueryBuildWithPossibleNullValues(),
        TestQueryBuildWithValues()
    },
    report = Summarize(facts)
][report];