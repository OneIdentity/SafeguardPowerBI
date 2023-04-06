section TestSchema;

SchemaTable = Extension.ImportFunction("SchemaTable", "Schema.pqm");
GetSchema = Extension.ImportFunction("GetSchema", "Schema.pqm");

shared TestRequest.UnitTest = [
    expected_sessions_table = UnitTestFramework.ImportFunction("Schema", "SessionsSchemaAsset.pqm"),
    facts = {Fact("Sessions schema matches", expected_sessions_table, GetSchema("Sessions"))},
    report = Facts.Summarize(facts)
][report];