section TestSchema;

GetSchema = SafeguardSessions.ImportFunction("GetSchema", "Schema.pqm");

ExpectedSessionsSchema = UnitTestFramework.ImportFunction("Schema", "SessionsSchemaAsset.pqm");

shared TestRequest.UnitTest = [
    facts = {Fact("Sessions schema matches", ExpectedSessionsSchema, GetSchema("Sessions"))},
    report = Summarize(facts)
][report];
