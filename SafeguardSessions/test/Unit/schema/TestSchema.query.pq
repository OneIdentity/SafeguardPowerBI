section TestSchema;

SchemaTable = Extension.ImportFunction("SchemaTable", "Schema.pqm");
GetSchema = Extension.ImportFunction("GetSchema", "Schema.pqm");

ExpectedSessionsSchema = UnitTestFramework.ImportFunction("Schema", "SessionsSchemaAsset.pqm");

shared TestRequest.UnitTest = [
    facts = {Fact("Sessions schema matches", ExpectedSessionsSchema, GetSchema("Sessions"))},
    report = Facts.Summarize(facts)
][report];
